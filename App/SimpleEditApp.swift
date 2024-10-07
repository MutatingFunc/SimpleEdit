import SwiftUI

//let settingsActivity = Bundle.main.bundleIdentifier! + ".settings"

@main
struct SimpleEditEntryPoint {
    static func main() {
        if #available(iOS 18.0, *) {
            SimpleEditApp.main()
        } else {
            SimpleEditApp_Legacy.main()
        }
    }
}

struct SimpleEditApp_Legacy: App {
    @State private var showSettings = false
    
    var body: some Scene {
        DocumentGroup(newDocument: SimpleEditDocument(text: "")) { config in
            NavigationStack {
                let editor = Editor(document: config.$document)
                if let fileURL = config.fileURL {
                    editor
                        .navigationDocument(fileURL)
                } else {
                    editor
                }
            }
        }
    }
}

struct SimpleEditApp: App {
    @State private var showSettings = false
    
    var body: some Scene {
        DocumentGroup(newDocument: SimpleEditDocument(text: "")) { config in
            NavigationStack {
                let editor = Editor(document: config.$document)
                if let fileURL = config.fileURL {
                    editor
                        .navigationDocument(fileURL)
                } else {
                    editor
                }
            }
        }
        
        if #available(iOS 18.0, *) {
            DocumentGroupLaunchScene {
                NewDocumentButton("New Text File")
                Button {
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .labelStyle(.titleOnly)
                .sheet(isPresented: $showSettings) {
                    StoredSettingsView()
                }
            } background: {
                ZStack {
                    Rectangle().fill(.windowBackground)
                    let tintColor = Color(red: 0x00/0xFF, green: 0x14/0xFF, blue: 0xC5/0xFF)
                    LinearGradient(colors: [tintColor.opacity(0.25), tintColor.opacity(0.5)], startPoint: .top, endPoint: .center)
                        .overlay {
                            VStack(spacing: 0) {
                                Color.clear
                                Rectangle().fill(.windowBackground)
                            }
                        }
                }
            }.commands {
                SharedCommands(showSettings: $showSettings)
            }
        }
    }
}

struct SharedCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Binding var showSettings: Bool
    
    var body: some Commands {
        if supportsMultipleWindows {
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    showSettings = true
                }.keyboardShortcut(",")
            }
        }
    }
}
