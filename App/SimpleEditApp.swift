import SwiftUI

//let settingsActivity = Bundle.main.bundleIdentifier! + ".settings"

@main
struct SimpleEditApp: App {
    var body: some Scene {
        // Remove WindowGroup when running
//        WindowGroup {
//            RootView()
//        }
        DocumentGroup(newDocument: SimpleEditDocument(text: "")) { config in
            Editor(document: config.$document)
        }
        .commands {
//            CommandGroup(after: .appSettings) {
//                Button("Toggle edit mode") {
//                    editMode?.toggle()
//                }
//            }
//            CommandGroup(replacing: .appSettings) {
//                Button("Preferences") {
//                    let options = UIWindowScene.ActivationRequestOptions()
//                    options.preferredPresentationStyle = .prominent
//                                    let activity = NSUserActivity(activityType: settingsActivity)
//                                    activity.targetContentIdentifier = settingsActivity
//                                    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: options) { error in
//                        print(error)
//                    }
//                }.keyboardShortcut("p")
//            }
        }
    }
}
