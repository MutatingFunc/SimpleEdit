import XCTest
import RobotsUITesting

/// The text editor for an open document.
struct EditorRobot: Robot {

    init() {
        XCTAssert(textView.wait(for: \.exists, timeout: 15), "Text view not found")
    }
    
    private var textView: XCUIElement {
        app.textViews.firstMatch
    }
    
    private var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }
    
    /// Queried from the app, as on iPhone Duo the toolbar buttons sit in a side toolbar outside the navigation bar.
    private var backButton: XCUIElement {
        app.buttons["BackButton"].firstMatch
    }
    
    private var editModeButton: XCUIElement {
        app.buttons["Edit mode"].firstMatch
    }
    
    /// The document's file name, which is the navigation bar's title, and the title menu's button.
    private var filename: String {
        navigationBar.identifier
    }
    
    func typeText(_ text: String) -> Self {
        perform {
            textView.tap()
            textView.typeText(text)
        }
    }
    
    func verifyText(_ expected: String) -> Self {
        perform {
            XCTAssert(
                textView.wait(for: { $0.value as? String == expected }),
                "Expected text \(expected), found \(String(describing: textView.value))"
            )
        }
    }
    
    /// Closes the document, which saves it, and returns to the document picker.
    func close() -> DocumentPickerRobot {
        perform {
            backButton.tap()
        }
    }
    
    /// Opens the title menu and chooses Revert.
    func tapRevert() -> RevertConfirmationRobot {
        perform {
            // On iPad the confirmation popover can open behind the keyboard, where it cannot be seen or tapped.
            let dismissKeyboardButton = app.buttons["Dismiss Keyboard"].firstMatch
            if dismissKeyboardButton.exists {
                dismissKeyboardButton.tap()
                XCTAssert(app.keyboards.firstMatch.wait(for: { !$0.exists }), "Keyboard did not dismiss")
            }
            navigationBar.buttons[filename].tap()
            app.buttons["Revert"].firstMatch.tap()
        }
    }
    
    func setEditMode(_ enabled: Bool) -> Self {
        perform {
            if editModeButton.isSelected != enabled {
                editModeButton.tap()
            }
            XCTAssert(editModeButton.wait(for: { $0.isSelected == enabled }), "Edit mode did not turn \(enabled ? "on" : "off")")
        }
    }
    
    /// Taps the text, which brings up the keyboard only when the document is editable.
    func tapText() -> Self {
        perform {
            textView.tap()
        }
    }
    
    func verifyKeyboardIsShown(_ isShown: Bool) -> Self {
        perform {
            XCTAssert(
                app.keyboards.firstMatch.wait(for: { $0.exists == isShown }),
                "Expected keyboard \(isShown ? "shown" : "hidden")"
            )
        }
    }
    
}
