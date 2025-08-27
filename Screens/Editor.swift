import SwiftUI

struct Editor: View {
    @Binding var document: SimpleEditDocument
    @State private var activeSearch = ""
    @State private var isRevertShown = false
    @State private var isSettingsShown = false
    @State private var editMode = false
    @State private var fontPickerShown = false
    @State private var fontSizePickerShown = false
    @FocusState private var isEditorFocused
    @AppStorage("fontFamily") private var fontFamily: String?
    @AppStorage("fontSize") private var fontSize: Double?
    @AppStorage("keyboardType") private var keyboardType = UIKeyboardType.default
    @Environment(\.undoManager) private var undoManager
    @Environment(\.horizontalSizeClass) private var hSize
    
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
            .toolbar(id: "Editor") {
                Group {
                    ToolbarItem(id: "FontFamily") {
                        Button {
                            fontPickerShown.toggle()
                        } label: {
                            FontPickerLabel()
                        }.popover(isPresented: $fontPickerShown) {
                            FontPicker(fontFamily: $fontFamily)
                        }
                    }
                    ToolbarItem(id: "FontSize") {
                        Menu {
                            Section("Font size") {
                                FontSizePicker(fontSize: $fontSize)
                                Button {
                                    fontSize = nil
                                } label: {
                                    Label("Reset to System", systemImage: "undo")
                                }
                            }
                        } label: {
                            FontSizePickerLabel()
                        }
                    }
                    ToolbarItem(id: "KeyboardPicker") {
                        Menu {
                            KeyboardPicker(keyboard: $keyboardType)
                                .pickerStyle(.inline)
                        } label: {
                            KeyboardPickerLabel()
                        }
                    }
                }.defaultCustomization(.hidden)
            }
            .toolbar {
                if isEditorFocused {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isEditorFocused = false
                        } label: {
                            Label("Done", systemImage: "keyboard.chevron.compact.down")
                        }.keyboardShortcut(.cancelAction)
                    }
                    ToolbarSpacer(placement: .topBarTrailing)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditModeToggle(isEditing: $editMode)
                }
                ToolbarItem(placement: .topBarTrailing) {
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
    
    @Namespace private var ns
    var editorSettingsButton: some View {
        Button {
            isEditorFocused = false
            isSettingsShown.toggle()
        } label: {
            Label("Settings", systemImage: "gearshape")
        }
        .popover(isPresented: $isSettingsShown) {
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
                EditModeToggle(isEditing: $editMode)
            }
        }
        .environment(\.isPresentedInPopover, hSize != .compact)
        .frame(idealWidth: 480, idealHeight: 512)
    }
}

struct EditModeToggle: View {
    @Binding var isEditing: Bool
    
    var body: some View {
        Toggle(isOn: $isEditing) {
            Label("Edit mode", systemImage: "pencil")
        }.keyboardShortcut("e")
    }
}

struct Editor_Previews: PreviewProvider {
    struct Container: View {
        @State private var document = SimpleEditDocument(text: "https://example.com")
        
        var body: some View {
            NavigationView {
                Editor(document: $document)
                    .toolbarRole(.editor)
            }.navigationViewStyle(.stack)
        }
    }
    static var previews: some View {
        Container()
    }
}
