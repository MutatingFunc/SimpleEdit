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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TextView(text: $document.text, focused: $isEditorFocused)
            .ignoresSafeArea(.container, edges: .vertical)
            .focused($isEditorFocused)
            .onAppear {
                isEditorFocused = true
                editMode = document.isSafelyEditable
            }
            .environment(\.editMode, .constant(editMode ? .active : .inactive))
            .font(family: fontFamily, size: fontSize)
            .uiKeyboardType(keyboardType)
        
            .toolbar {
                let dismissButton = Button {
                    if isEditorFocused {
                        isEditorFocused = false
                    } else {
                        dismiss()
                    }
                } label: {
                    if isEditorFocused {
                        Label("Done", systemImage: "keyboard.chevron.compact.down")
                    } else {
                        Label("Close", systemImage: "xmark.circle")
                    }
                }.keyboardShortcut(.cancelAction)
                if #available(iOS 18.2, *) {
                    ToolbarItem(id: "dismiss", placement: .navigationBarLeading) {
                        if isEditorFocused {
                            dismissButton
                        }
                    }
                } else {
                    ToolbarItem(id: "dismiss", placement: .navigationBarLeading) {
                        if #available(iOS 18.0, *) {
                            dismissButton
                        } else if isEditorFocused {
                            dismissButton
                        }
                    }
                }
                ToolbarItem(id: "editMode", placement: .navigationBarTrailing) {
                    editModeToggle
                        .toggleStyle(.button)
                }
                ToolbarItem(id: "preferences", placement: .navigationBarTrailing) {
                    editorSettingsButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(document.filename)
            .toolbarTitleMenu {
                RenameButton()
                Button {
                    document.revert()
                } label: {
                    revertLabel
                }
            }
    }
    
    var revertButton: some View {
        Button {
            isRevertShown = true
        } label: {
            revertLabel
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
    var revertLabel: some View {
        Label("Revert", systemImage: "chevron.left.to.line")
    }
    
    var editorSettingsButton: some View {
        Button {
            isEditorFocused = false
            isSettingsShown.toggle()
        } label: {
            Label("Preferences", systemImage: "textformat")
        }
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
