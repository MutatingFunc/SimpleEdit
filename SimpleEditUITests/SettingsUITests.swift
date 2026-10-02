import XCTest
import RobotsUITesting

@MainActor
final class SettingsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
    
    }
    
    /// Settings opens, the font picker can be cancelled, the font size can be entered and cleared back to System,
    /// and Settings closes, in a single launch.
    func testSettingsFontPickerFontSizeAndClose() {
        _ = AppRobot()
            .launch()
            .tapSettings()
            .tapFont()
            .tapCancel()
            .resetFontSize()
            .enterFontSize("20")
            .verifyFontSize("20")
            .clearFontSize()
            .verifyFontSizeIsSystem()
            .close()
    }
    
}
