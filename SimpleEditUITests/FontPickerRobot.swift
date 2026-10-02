import XCTest
import RobotsUITesting

struct FontPickerRobot<Parent: Robot>: PushedRobot {

    init() {
        XCTAssert(cancelButton.wait(for: \.exists), "Cancel button not found")
        XCTAssert(systemButton.wait(for: \.exists), "System button not found")
    }
    
    private var cancelButton: XCUIElement {
        app.buttons["Cancel"].firstMatch
    }
    
    private var systemButton: XCUIElement {
        app.buttons["System"].firstMatch
    }
    
    func tapCancel() -> Parent {
        perform {
            cancelButton.tap()
        }
    }
    
    func tapSystem() -> Parent {
        perform {
            systemButton.tap()
        }
    }
    
}
