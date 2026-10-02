import XCTest

@MainActor
final class LaunchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
    
    }
    
    /// The launch screen offers New Text File and Settings, which creating `DocumentPickerRobot` asserts on every launch,
    /// and a new text file opens an editor which accepts typing.
    func testNewTextFileOpensEditorAndAcceptsTyping() {
        _ = AppRobot()
            .launch()
            .tapNewTextFile()
            .typeText("Hello")
            .verifyText("Hello")
    }
    
}
