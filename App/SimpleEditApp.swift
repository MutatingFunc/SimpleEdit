import SwiftUI

@main
struct SimpleEditApp: App {
    @State private var showSettings = false
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    
    var body: some Scene {
        DocumentGroup(newDocument: SimpleEditDocument(text: "")) { config in
            let editor = Editor(document: config.$document)
            if let fileURL = config.fileURL {
                editor
                    .navigationDocument(fileURL)
            } else {
                editor
            }
        }.commands {
            ToolbarCommands()
            SharedCommands(openSettings: openSettings)
            EditorCommands()
        }
        
        DocumentGroupLaunchScene("SimpleEdit") {
            NewDocumentButton("New Text File")
                .keyboardShortcut("n")
            Button {
                openSettings()
            } label: {
                Label("Settings", systemImage: "gearshape")
            }
            .labelStyle(.titleOnly)
            .sheet(isPresented: $showSettings) {
                StoredSettingsView()
            }
        } background: {
            let tintColor = Color(red: 0x00/0xFF, green: 0x14/0xFF, blue: 0xC5/0xFF)
            LinearGradient(colors: [tintColor.opacity(0.25), tintColor.opacity(0.5), tintColor.opacity(0.5)], startPoint: .top, endPoint: .bottom)
        }.commands {
            SharedCommands(openSettings: openSettings)
        }
        
        WindowGroup("Settings", id: "Settings") {
            StoredSettingsView()
                .environment(\.isSettingsWindow, true)
        }.defaultSize(width: 320, height: 480)
    }
    
    func openSettings() {
        if supportsMultipleWindows {
            openWindow(id: "Settings")
        } else {
            showSettings = true
        }
    }
}

struct SharedCommands: Commands {
    var openSettings: () -> ()
    
    var body: some Commands {
        ToolbarCommands()
        CommandGroup(replacing: .appSettings) {
            Button("Settings") {
                openSettings()
            }.keyboardShortcut(",")
        }
    }
}
