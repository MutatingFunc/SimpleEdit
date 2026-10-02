import XCTest

@MainActor
final class EditorUITests: XCTestCase {

    /// The first document created from an empty launch, since `AppRobot.launch()` deletes any existing documents.
    private let filename = "Untitled.txt"
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
    
    }
    
    /// Closing a document saves it, and opening it loads what was saved, across repeated edits.
    func testTextIsSavedOnCloseAndLoadedOnOpen() {
        _ = AppRobot()
            .launch()
            .tapNewTextFile()
            .typeText("Hello")
            .close()
            .openDocument(named: filename)
            .verifyText("Hello")
            .typeText(" world")
            .close()
            .openDocument(named: filename)
            .verifyText("Hello world")
    }
    
    /// Revert restores the text from when the document was last opened, not from when it was created,
    /// and the edit mode toggle controls whether the text can be edited.
    ///
    /// The typed text is digits, not word fragments, because the software keyboard completes a partial word
    /// (" extra" became "extraordinary " on iPad), which varies by device and corrupts the expected text.
    func testRevertRestoresLastOpenedTextAndEditModeControlsEditing() {
        _ = AppRobot()
            .launch()
            .tapNewTextFile()
            .typeText("Saved")
            .close()
            .openDocument(named: filename)
            .typeText(" 1")
            .verifyText("Saved 1")
            .tapRevert()
            .cancel()
            .verifyText("Saved 1")
            .tapRevert()
            .revert()
            .verifyText("Saved")
            // Reopening makes the saved text the new baseline.
            .typeText(" 2")
            .close()
            .openDocument(named: filename)
            .typeText("!")
            .verifyText("Saved 2!")
            .tapRevert()
            .revert()
            .verifyText("Saved 2")
            // Edit mode off stops the text being edited, and on allows it again.
            .setEditMode(false)
            .tapText()
            .verifyKeyboardIsShown(false)
            .setEditMode(true)
            .tapText()
            .verifyKeyboardIsShown(true)
    }
    
}
