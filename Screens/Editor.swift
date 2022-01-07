import SwiftUI

struct Editor: View {
    @Binding var document: SimpleEditDocument
    @State private var activeSearch = ""
    @State private var isRevertShown = false
    @State private var isSettingsShown = false
    @State private var editMode = false
    @FocusState private var isEditorFocused
    @AppStorage("fontFamily") private var fontFamily: String?
    @AppStorage("fontSize") private var fontSize: Double?
    @AppStorage("keyboardType") private var keyboardType = UIKeyboardType.default
    @Environment(\.undoManager) private var undoManager
    @Environment(\.presentationMode) @Binding var presentationMode
    
    var body: some View {
        TextView(text: $document.text)
            .focused($isEditorFocused)
            .onAppear {
                isEditorFocused = true
                editMode = document.isSafelyEditable
            }
            .environment(\.editMode, .constant(editMode ? .active : .inactive))
            .font(family: fontFamily, size: fontSize)
            .uiKeyboardType(keyboardType)
            .toolbar {
                ToolbarItem(id: "revert", placement: .navigationBarLeading) {
                    revertButton
                }
                ToolbarItem(id: "editMode", placement: .navigationBarTrailing) {
                    editModeToggle
                        .toggleStyle(PlainButtonToggleStyle())
                }
                ToolbarItem(id: "preferences", placement: .navigationBarTrailing) {
                    editorSettingsButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(document.filename)
    }
    
    var revertButton: some View {
        Button {
            isRevertShown = true
        } label: {
            Label("Revert", systemImage: "backward")
        }
        .keyboardShortcut("r")
        .confirmationDialog("Revert file content to state when last opened?", isPresented: $isRevertShown) { 
            Button(role: .destructive) {
                document.revert()
            } label: { 
                Text("Revert to last opened")
            }
            Button(role: .cancel) {} label: {
                Text("Cancel")
            }.keyboardShortcut(.cancelAction)
        }
    }
    
    var editorSettingsButton: some View {
        Button {
            isEditorFocused = false
            isSettingsShown.toggle()
        } label: {
            Label("Preferences", systemImage: "textformat")
        }
        .keyboardShortcut(",")
        .sheet(isPresented: $isSettingsShown) { 
            settings
        }
    }
    
    var settings: some View {
        SettingsView(
            fontFamily: $fontFamily,
            fontSize: $fontSize,
            keyboardType: $keyboardType
        ) {
            Section("Session") {
                editModeToggle
            }
        }
    }
    
    @ViewBuilder
    var editModeToggle: some View {
        Toggle(isOn: $editMode) {
            Label("Edit mode", systemImage: "pencil")
                .symbolVariant(editMode ? .none : .slash)
        }.keyboardShortcut("e")
    }
}

/// Doesn't auto-apply fill when on
struct PlainButtonToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
        }
    }
}

struct Editor_Previews: PreviewProvider {
    struct Container: View {
        @State private var document = SimpleEditDocument(text: "https://example.com")
        
        var body: some View {
            NavigationView {
                Editor(document: $document)
            }.navigationViewStyle(.stack)
        }
    }
    static var previews: some View {
        Container()
    }
}
