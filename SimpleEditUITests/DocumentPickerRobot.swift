import XCTest
import RobotsUITesting

/// The document picker shown when the app starts.
struct DocumentPickerRobot: Robot {

    init() {
        // Closing a document which was opened from the browser shows the full-screen browser, which covers the launch
        // screen, so its buttons are not hittable. Each condition re-resolves its buttons on every poll, as the tappable
        // ones may only appear once the screen settles.
        XCTAssert(
            app.wait(for: { _ in self.isLaunchScreenShown || self.isFullBrowserShown }, timeout: 30),
            "Neither the launch screen nor the document browser was found"
        )
        // A fresh simulator has no save location until the Browse tab has been opened, which "New Text File" needs.
        // The document browser can take around 10s to launch.
        let isLaunchScreen = isLaunchScreenShown
        if browseButton.wait(for: { _ in self.browseButton.isHittable }, timeout: isLaunchScreen ? 30 : 3) {
            browseButton.tap()
        } else {
            XCTAssert(!isLaunchScreen, "Browse tab not found")
        }
        // New files are saved to the browser's current location, so open the device's local one ("On My iPhone/iPad").
        // The browser remembers its last location, so it may already be inside one, in which case there is no sidebar.
        XCTAssert(
            onMyDeviceLocation.wait(for: { _ in self.onMyDeviceLocation.exists || self.openLocationFiles.exists }, timeout: 15),
            "Neither the On My device location nor an open location was found"
        )
        if onMyDeviceLocation.exists {
            onMyDeviceLocation.tap()
        }
    }
    
    private var openLocationFiles: XCUIElement {
        app.collectionViews["File View"]
    }
    
    private var isLaunchScreenShown: Bool {
        newTextFileButton.isHittable && settingsButton.isHittable
    }
    
    /// The browser embedded in the launch screen is inset from the window, while the full-screen browser spans it.
    private var isFullBrowserShown: Bool {
        let navigationBar = app.navigationBars["FullDocumentManagerViewControllerNavigationBar"]
        return navigationBar.exists && navigationBar.frame.width >= app.frame.width
    }
    
    /// The browser's "More" menu, which is `OverflowBarButtonItem` in the navigation bar on most devices, and
    /// `BottomOverflowBarButtonItem` in the bottom toolbar on iPhone Duo.
    private var overflowButton: XCUIElement {
        app.buttons.matching(NSPredicate(format: "identifier ENDSWITH %@", "OverflowBarButtonItem")).firstMatch
    }
    
    private var browseButton: XCUIElement {
        tappableButton(labelled: "Browse")
    }
    
    private var onMyDeviceLocation: XCUIElement {
        app.cells
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "DOC.sidebar.item.On My"))
            .firstMatch
    }
    
    private var newTextFileButton: XCUIElement {
        tappableButton(labelled: "New Text File")
    }
    
    private var settingsButton: XCUIElement {
        tappableButton(labelled: "Settings")
    }
    
    /// The launch scene exposes each button twice: the real one, and a small duplicate hidden behind the recents panel.
    /// `firstMatch` can resolve to the duplicate, whose taps hit nothing, so select the one that can be tapped.
    private func tappableButton(labelled label: String) -> XCUIElement {
        let buttons = app.buttons.matching(identifier: label)
        return buttons.allElementsBoundByIndex.first(where: \.isHittable) ?? buttons.firstMatch
    }
    
    func tapSettings() -> SettingsRobot<Self> {
        perform {
            settingsButton.tap()
        }
    }
    
    func tapNewTextFile() -> EditorRobot {
        perform {
            newTextFileButton.tap()
        }
    }
    
    /// Deletes every document in the open location, through the browser's Select mode, so a test starts from a known state.
    @discardableResult
    func deleteAllDocuments() -> Self {
        perform {
            XCTAssert(openLocationFiles.wait(for: \.exists, timeout: 15), "File list not found")
            // The list fills in some seconds after it appears, with no sign that it is loading, so an empty list is only treated as
            // empty after a wait. Skipping an existing document makes the next New Text File fail with a name collision.
            guard documentCells.wait(for: { $0.count > 0 }, timeout: 6) else { return }
            overflowButton.tap()
            app.buttons["Select"].firstMatch.tap()
            app.buttons["Select All"].firstMatch.tap()
            app.buttons["Delete"].firstMatch.tap()
            XCTAssert(documentCells.wait(for: { $0.count == 0 }, timeout: 15), "Documents were not deleted")
            // The browser leaves Select mode once the deletion has finished. Creating a document before then can collide with
            // the file that is still being deleted ("Unable to Import Document").
            XCTAssert(app.buttons["Select All"].wait(for: { !$0.exists }, timeout: 15), "The browser did not leave Select mode")
            sleep(5)
        }
    }
    
    /// The documents in the open location, which are every cell except the one that creates a document.
    private var documentCells: XCUIElementQuery {
        openLocationFiles.cells.matching { $0.identifier != "Create Document" }
    }
    
    /// Opens a saved document, scrolling to it if needed.
    func openDocument(named filename: String) -> EditorRobot {
        perform {
            let url = URL(filePath: filename)
            // The browser identifies documents as "<name>, <extension>".
            let cell = app.cells.matching(identifier: "\(url.deletingPathExtension().lastPathComponent), \(url.pathExtension)").firstMatch
            XCTAssert(openLocationFiles.wait(for: \.exists, timeout: 15), "File list not found")
            // The collection view only creates cells for the rows on screen, so the cell does not exist until it is scrolled to.
            XCTAssert(cell.scrollTo(in: openLocationFiles, swipeLimit: 30, until: \.isHittable), "\(filename) not found")
            XCTAssert(cell.waitUntilStationary(), "The file list did not stop scrolling")
            cell.tap()
        }
    }
    
}
