import XCTest
import RobotsUITesting

/// The dialog asking whether to revert the document to its state when last opened.
struct RevertConfirmationRobot: Robot {

    init() {
        XCTAssert(revertButton.wait(for: \.exists), "Revert confirmation not shown")
    }
    
    private var revertButton: XCUIElement {
        app.buttons["Revert to last opened"].firstMatch
    }
    
    private var dismissRegion: XCUIElement {
        app.otherElements["PopoverDismissRegion"].firstMatch
    }
    
    private var cancelButton: XCUIElement {
        app.buttons["Cancel"].firstMatch
    }
    
    func revert() -> EditorRobot {
        perform {
            revertButton.tap()
        }
    }
    
    /// Cancels the dialog. Presented as a popover, as it is on iPhone and iPad here, it has no Cancel button,
    /// and is dismissed by tapping outside it.
    func cancel() -> EditorRobot {
        perform {
            if cancelButton.exists {
                cancelButton.tap()
            } else {
                dismissRegion.tap()
            }
            XCTAssert(revertButton.wait(for: { !$0.exists }), "Revert confirmation did not close")
        }
    }
    
}
