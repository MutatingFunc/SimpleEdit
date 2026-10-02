# AGENTS.md

Guidance for AI coding agents working in this repository. Testing guidance lives beside the tests:

- [SimpleEditUITests/AGENTS.md](SimpleEditUITests/AGENTS.md): UI tests, the Robot pattern, simulator and Xcode quirks.
- [SimpleEditTests/AGENTS.md](SimpleEditTests/AGENTS.md): unit tests (Swift Testing), and why they do not link yet.

SimpleEdit is a plain-text document editor for iPhone and iPad (SwiftUI app lifecycle, Swift 6, deployment target 26.6). iOS only: `SUPPORTS_MACCATALYST = NO`; it runs on Mac as "Designed for iPad" (`SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = YES`).

Dependencies:

- [About](https://github.com/MutatingFunc/About) (resolved 4.1.4): `AboutLink` in the settings toolbar.
- `RobotsUITesting`: a local package at `../../Packages/RobotsUITesting`, linked by the `SimpleEditUITests` target only.

## Build and run

Prefer the Xcode MCP tools (`BuildProject`, `RunProject`, `GetBuildLog`) over `xcodebuild` or the simulator MCP. The agent is not approved for Xcode's tools until `XcodeOpenWorkspace` has been called for the project. Get the workspace identifier from `XcodeListWorkspaces`; it changes with each Xcode window or restart.

```bash
xcodebuild -project SimpleEdit.xcodeproj -scheme SimpleEdit -destination 'generic/platform=iOS Simulator' build
```

- **Schemes:** `SimpleEdit` (the app; its test action uses `SimpleEditUITests/SimpleEditUITests.xctestplan`), `SimpleEditUITests` (UI tests) and `SimpleEditTests` (unit tests, with `SimpleEditTests/SimpleEditTests.xctestplan`, serial) are shared. `SimpleEdit (no debugger)` is a user-only scheme (in `xcuserdata`): run the app with it outside tests, because launching under the debugger can hang on a white screen for minutes, and `RunProject` with `attachDebugger` has timed out. Jamie also switches the active scheme in Xcode, so check it with `XcodeListSchemes` before a build or test run, and switch with `XcodeSwitchScheme`: tests for another target fail with "not found in test plan", and a build on the `SimpleEditTests` scheme currently fails at link time.
- **Compiler settings** (project level): Swift 6 mode, complete strict concurrency, default actor isolation `nonisolated`, approachable concurrency, and the upcoming features `ExistentialAny`, `InternalImportsByDefault` and `MemberImportVisibility`. `SWIFT_TREAT_WARNINGS_AS_ERRORS` is `YES`, though concurrency warnings in test code have been seen to build anyway, so do not rely on it.
- **Synchronized folders:** adding or deleting a file under `SimpleEdit/`, `SimpleEditTests/` or `SimpleEditUITests/` can take several seconds for Xcode to notice. A build straight after can fail with "Build input file cannot be found", or use a stale binary. Wait a few seconds and build again, then check the build log shows the changed file compiled.

## Project conventions

- Folders are synchronized with the target (`PBXFileSystemSynchronizedRootGroup`), so new files need no project edits.
- Build settings live at project level. Do not add per-target overrides for deployment target, Swift version or isolation. Change project settings through Xcode or the Xcode MCP, not by hand-editing `project.pbxproj`. Adding a package reference is a project change too: ask Jamie to add it in Xcode.
- Default actor isolation is `nonisolated`; `@MainActor` is explicit throughout.
- The repository must stay out of iCloud Drive; syncing corrupted `.git` state during rebases.
- Commits are SSH-signed through 1Password and prompt the user for approval each time.

## Architecture

- **Document model:** `SimpleEditApp` is a `DocumentGroup` over `SimpleEditDocument`, a `nonisolated` `FileDocument`. It reads `.plainText` and `.data`. `originalText` backs `revert()`: it is set when the document is opened, so Revert restores the text from when the file was last opened, not from when it was created. `isSafelyEditable` is false when the file was not opened as plain text, which keeps the editor read-only.
- **Launch screen:** `DocumentGroupLaunchScene` provides the "New Text File" and "Settings" buttons. The settings sheet is attached there. Comments note the launch scene breaks "Open In" on iOS 18 and 26.
- **Editor is UIKit-driven:** `Editor` (SwiftUI shell and toolbar) hosts `TextView`, a `UIViewRepresentable` around `UITextView`. `updateUIView` writes properties through `setIfNeeded` to avoid redundant updates. Font and keyboard type reach the UIKit view through custom environment values (`uiFont` in `Extensions/UIFont.swift`, `keyboardType` in `Extensions/KeyboardType.swift`), read from `context.environment`. Edit mode comes from the SwiftUI `editMode` environment.
- **Editor navigation bar:** the title is a menu (`toolbarTitleMenu`) with Rename and Revert. Back closes and saves the document. Toolbar items: Dismiss Keyboard (while focused), Edit mode, Settings (a popover).
- **Settings:** values persist in `@AppStorage` under `fontFamily`, `fontSize` and `keyboardType`. `StoredSettingsView` wires storage to `SettingsView`, which takes bindings and is reused as a popover (from `Editor`) and a sheet (from the launch scene), distinguished by the `isPresentedInPopover` and `isSettingsWindow` environment flags.
- **Font size range:** `FontSizePicker.validRange` (1...300) is the single definition. The text field's `NumberFormatter` and the stepper bound use it, and `Editor` clamps the stored value where the font is applied. `FontPicker` wraps `UIFontPickerViewController` (`FontPickerVC`).
- **`KeyboardPicker`** lists `UIKeyboardType` raw values `0 ..< 12`; raise that bound and add a name when the SDK adds a case.
- **Native clear button:** `SimpleEditApp.init` sets `UITextField.appearance().clearButtonMode = .whileEditing`, which applies to every `TextField` in the app.
- **Unused code:** `RootView.swift` has no callers, and `DocumentsButton.swift` is used only by `RootView`; `UndoRedoButtons.swift` has no callers. Undo/redo and find-in-file were scoped and deferred: the buttons read SwiftUI's environment undo manager, not the `UITextView`'s.

## Known issue

- **Revert confirmation:** `Editor.revertButton` attaches `.confirmationDialog` to a button inside `toolbarTitleMenu`. In simulator UI tests, choosing Revert from the title menu never showed the dialog (polled for 8s, keyboard up and down). The likely cause is that the menu content is dismissed along with the presentation, but this is unconfirmed on a device and no app change has been made.

## Settings window findings

The settings `WindowGroup` in `SimpleEditApp.swift` is commented out. Tried and rejected: requesting a prominent placement through a `UIHostingSceneDelegate` crashed the app after the scene connected, and `defaultSize` does not set the initial window size on iPadOS (the window opens full screen). SwiftUI window-placement modifiers are largely macOS/visionOS only.
