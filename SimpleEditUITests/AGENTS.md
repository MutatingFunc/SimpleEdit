# AGENTS.md: SimpleEditUITests

UI tests for SimpleEdit, written with XCTest and the Robot pattern. Project-wide guidance is in [../AGENTS.md](../AGENTS.md).

## Running

- Use the Xcode MCP: `RunSomeTests` with `targetName` `SimpleEditUITests` and a `testIdentifier` such as `SettingsUITests/testSettingsFontPickerFontSizeAndClose()`, or `RunAllTests`. Select the `SimpleEditUITests` scheme with `XcodeSwitchScheme`; its test plan is [SimpleEditUITests.xctestplan](SimpleEditUITests.xctestplan).
- The target uses `TEST_TARGET_NAME = SimpleEdit`, which `XCUIApplication()` needs to find the app.
- The test plan runs tests in **random order**, with test timeouts enabled. Tests must not depend on each other.
- Parallel testing is currently off, so runs use the real simulator. Parallel clones run headless, are not shown in Device Hub, and use a lot of memory. Jamie wants to keep using clones when possible, so ask if they cause trouble.
- Before a run, shut down any booted clones with `xcrun simctl --set ~/Library/Developer/XCTestDevices shutdown <udid>` (list with `xcrun simctl --set ~/Library/Developer/XCTestDevices list devices`).
- Do not kill simulator processes or `CoreSimulatorService`. Killing the service orphaned the clone set once (runs failed with "No matching device … Clone 1 of iPhone 18 Pro") and only restarting Xcode fixed it. Use `simctl shutdown` and ask Jamie before anything stronger. If simulators wedge, `xpcproxy_sim` processes pile up in `U` state, and a reboot is the reliable fix.
- A fresh simulator or clone has no save location until the document browser's Browse tab and "On My iPhone/iPad" location are opened. `DocumentPickerRobot.init` does this.
- The document browser can take about 10 seconds to appear. Waits in the robots are sized for that.

## Layout

- `Tests`: `LaunchUITests`, `SettingsUITests`, `EditorUITests`. Few, broad tests, so each one pays for a single app launch. Add flows to an existing test before adding a new one.
- `Robots`: stateless structs, one per screen: `AppRobot`, `DocumentPickerRobot`, `EditorRobot`, `RevertConfirmationRobot`, `SettingsRobot`, `FontPickerRobot`. `init()` asserts the screen is showing; methods return the next robot, so tests read as chains, e.g. `AppRobot().launch().tapSettings().close()`.
- Generic foundation (`Robot`, `PushedRobot`, `PoppableRobot`, `PresentedRobot`, `perform`, `takeScreenshot`, `scrollTo`, `wait(for:)`, `withActivity`, `HomeScreenRobot`, `SystemSettingsRobot`, and the global `app`) lives in the local package `../../Packages/RobotsUITesting`, not in this folder. Add generic helpers there, and per-screen robots here.
- `MemberImportVisibility` is on: a file that uses package members, such as `close()` from `PresentedRobot`, needs `import RobotsUITesting`.
- Robots are `@MainActor`, and the test classes carry an explicit `@MainActor`. Making the UI test target default to MainActor was tried and broke `XCTestCase` subclasses.
- Name robot actions for what they do (`verifyKeyboardIsShown(_:)`, not `verifyKeyboard(isShown:)`).

## Conventions

- Test classes set `continueAfterFailure = false` in `setUpWithError` and leave `tearDownWithError` empty. Do not add `app.terminate()`: `app.launch()` already terminates a running instance. Jamie wants to be asked, with the symptom explained, before this changes.
- Waits poll on the main actor (`wait(for:)` takes a closure or key path, e.g. `\.exists`) instead of using predicate expectations, to stay main-actor safe.
- Do not hardcode screen coordinates. Tests must hold on every simulator size, so query by identifier, label or element state.

## Quirks learned the hard way

1. **Duplicate launch-screen buttons (iPhone).** "New Text File" and "Settings" each appear twice in the accessibility tree: the real button and a small hidden duplicate behind the Recents panel. `firstMatch` can return the duplicate, so taps hit nothing (`Computed hit point {-1, -1}`). `DocumentPickerRobot` picks the element whose `isHittable` is true, re-resolved on every poll.
2. **The number pad is a popover on iPad.** Its full-window `PopoverDismissRegion` makes every element beneath it, including the text field's Clear button, report `isHittable == false`. `SettingsRobot.clearFontSize()` taps the button's centre through `coordinate(withNormalizedOffset:)`, relative to its frame.
3. **Collection views only create visible cells.** Saved documents accumulate in the simulator's "On My iPhone/iPad" folder, so a document may be off screen and does not exist in the hierarchy until scrolled to. `DocumentPickerRobot.openDocument(named:)` scrolls first and waits afterwards.
4. **New documents are numbered.** Files are named `Untitled.txt`, `Untitled 2.txt`, and so on. Read the name from the editor's navigation bar (`EditorRobot.filename`). The browser identifies a cell as `<name>, <extension>`, e.g. `Untitled 4, txt`.
5. **Settings persist.** `@AppStorage` survives relaunches within a simulator, so a failed run can leave a font size behind. `SettingsRobot.resetFontSize()` clears it at the start of the font test.
6. **An empty font size field reports an empty `value`.** "System" is only its `placeholderValue`.
7. **The browser remembers its last location.** Whether the sidebar's "On My iPhone/iPad" cell exists depends on that, so `DocumentPickerRobot.init` taps it only if present.
8. **Closing a document you reopened from the browser shows the full-screen document browser** (nav bar with a `Create Document` button), not the launch screen, so the launch buttons are not hittable then. See Status.
9. **Stale test bundles.** After deleting or adding a file, wait a few seconds, rebuild with `BuildProject` and `buildForTesting: true`, and check the log compiled the file. A run straight after can still execute the old bundle, including tests from deleted files.
10. **Failure details.** A failure does not always export a UI hierarchy attachment, so fall back on the activity log: `xcrun xcresulttool get test-results activities --path <xcresult> --test-id '<Class/test()>'`, and export attachments with `xcresulttool export attachments`. The xcresult copy the MCP tool returns is incomplete; use the one in `~/Library/Developer/Xcode/DerivedData/SimpleEdit-*/Logs/Test`. To see the screen, print `app.debugDescription` from a temporary test, and delete it afterwards.

## Device layout differences in system UI

System UI is laid out differently per device, so identifiers and containers that work on one device can be missing on another. Query by identifier from `app`, not from a container such as `navigationBars`, and match identifier suffixes where only a prefix is stable. Found by exporting the failure's UI hierarchy (quirk 10).

| Element | iPhone 18 Pro / iPad | iPhone Duo (window 466 × 678 pt) |
|---|---|---|
| Document browser "More" menu (Select, Select All, Delete) | Button `OverflowBarButtonItem`. | Button `BottomOverflowBarButtonItem`, label "More", in a side toolbar. `DocumentPickerRobot.overflowButton` matches the suffix `OverflowBarButtonItem`. |
| Editor toolbar buttons (`BackButton`, "Dismiss Keyboard", More) | Inside the `NavigationBar` element, so `navigationBar.buttons[…]` finds them. | A separate vertical toolbar on the trailing edge (x ≈ 399), outside the `NavigationBar`, which holds only the title button (identifier and label are the file name). `navigationBar.buttons["BackButton"]` finds nothing; `EditorRobot` queries `app.buttons[…]`. |
| Editor "Edit mode" button | Inside the `NavigationBar`. | Not in the hierarchy seen with the keyboard up, which listed only BackButton, Dismiss Keyboard and More. It may be in the More menu; not verified. |

The iPhone 18 Pro / iPad column is what the robots were first written against, and has not been re-inspected.

## Choosing the device

Switching the scheme with `XcodeSwitchScheme` resets the run destination to the scheme's default (iPhone 18 Pro), so switch the scheme first, then the destination with `XcodeSwitchRunDestination` (`displayTitle`), and confirm the device in the run's console log (`Installing on <device>`). The destination was also seen back on iPhone 18 Pro after a switch to iPhone Duo had succeeded, following runs that timed out (cause unconfirmed), so check the log every time.

## Status (2026-10-08)

| Test | State |
|---|---|
| `LaunchUITests/testNewTextFileOpensEditorAndAcceptsTyping` | Passes on iPhone 18 Pro. |
| `SettingsUITests/testSettingsFontPickerFontSizeAndClose` | Passes on iPhone 18 Pro. Its steps passed on iPad Pro 13-inch (M5) as three separate tests before consolidation. |
| `EditorUITests/testTextIsSavedOnCloseAndLoadedOnOpen` | Fails. Reopening works, but `DocumentPickerRobot.init` fails after closing a reopened document (quirk 8). |
| `EditorUITests/testRevertRestoresLastOpenedTextAndEditModeControlsEditing` | Fails. The Revert confirmation never appears, probably an app problem (see "Known issue" in [../AGENTS.md](../AGENTS.md)). Reopen and the steps before Revert work. |

Edit mode and keyboard checks in the second editor test have not run, because the test stops at Revert.
