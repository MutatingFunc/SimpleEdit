import XCTest
import RobotsUITesting

struct AppRobot: Robot {

    /// Launches the app with no documents, so every test starts from the same state, and its first new file is `Untitled.txt`.
    ///
    /// The system is told to ignore saved UI state, because the app would otherwise reopen the full-screen document browser
    /// after a previous session closed a document, which covers the launch screen's buttons.
    func launch() -> DocumentPickerRobot {
        let picker: DocumentPickerRobot = perform {
            app.launchArguments = ["-ApplePersistenceIgnoreState", "YES"]
            app.launch()
        }
        return picker.deleteAllDocuments()
    }
    
}
