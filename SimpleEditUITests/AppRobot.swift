import XCTest
import RobotsUITesting

struct AppRobot: Robot {

    func launch() -> DocumentPickerRobot {
        app.launchArguments = ["-ApplePersistenceIgnoreState", "YES"]
        app.launch()
        return DocumentPickerRobot().deleteAllDocuments()
    }
    
}
