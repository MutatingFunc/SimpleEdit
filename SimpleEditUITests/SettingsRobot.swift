import XCTest
import RobotsUITesting

struct SettingsRobot<Parent: Robot>: PresentedRobot {

    init() {
        XCTAssert(fontSizeField.wait(for: \.exists), "Font size field not found")
        XCTAssert(fontRow.wait(for: \.exists), "Font row not found")
    }
    
    private var fontRow: XCUIElement {
        app.buttons["Font"].firstMatch
    }
    
    private var fontSizeField: XCUIElement {
        app.textFields["Font size"].firstMatch
    }
    
    private var clearButton: XCUIElement {
        fontSizeField.buttons["Clear text"].firstMatch
    }
    
    func tapFont() -> FontPickerRobot<Self> {
        perform {
            fontRow.tap()
        }
    }
    
    func enterFontSize(_ text: String) -> Self {
        perform {
            fontSizeField.tap()
            fontSizeField.typeText(text)
        }
    }
    
    /// Taps the field's native clear button, which only appears while the field is being edited.
    func clearFontSize() -> Self {
        perform {
            fontSizeField.tap()
            // On iPad the number pad is a popover, whose full-window dismiss region absorbs the next tap and makes the clear
            // button not hittable. Tapping the field again dismisses the popover and keeps the field focused.
            if !clearButton.wait(for: \.isHittable, timeout: 1) {
                fontSizeField.tap()
            }
            XCTAssert(clearButton.wait(for: \.isHittable), "Clear button not found")
            clearButton.tap()
        }
    }
    
    /// Empties the font size if a previous run left one stored, as `@AppStorage` persists between launches.
    func resetFontSize() -> Self {
        perform {
            let value = fontSizeField.value as? String ?? ""
            if !value.isEmpty, value != fontSizeField.placeholderValue {
                _ = clearFontSize()
            }
        }
    }
    
    func verifyFontSize(_ expected: String) -> Self {
        perform {
            XCTAssert(
                fontSizeField.wait(for: { $0.value as? String == expected }),
                "Expected font size \(expected), found \(String(describing: fontSizeField.value))"
            )
        }
    }
    
    /// An empty field reports no value, and shows its "System" prompt as the placeholder.
    func verifyFontSizeIsSystem() -> Self {
        perform {
            XCTAssert(
                fontSizeField.wait(for: { ($0.value as? String ?? "").isEmpty }),
                "Expected an empty font size, found \(String(describing: fontSizeField.value))"
            )
            XCTAssertEqual(fontSizeField.placeholderValue, "System")
        }
    }
    
}
