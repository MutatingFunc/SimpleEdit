import SwiftUI
import UniformTypeIdentifiers

struct Editor: View {
    var document: SimpleEditDocument
    @State private var activeSearch = ""
    @State private var isRevertShown = false
    @State private var isSettingsShown = false
    @State private var editMode = false
    @State private var fontPickerShown = false
    @FocusState private var isEditorFocused
    @AppStorage("fontFamily") private var fontFamily: String?
    @AppStorage("fontSize") private var fontSize: Double?
    @AppStorage("keyboardType") private var keyboardType = UIKeyboardType.default
    @Environment(\.undoManager) private var undoManager
    @Environment(\.verticalSizeClass) private var vSize
    @Environment(\.horizontalSizeClass) private var hSize
    
    var body: some View {
        @Bindable var document = document
        TextView(text: $document.contents.text, focused: $isEditorFocused)
            .ignoresSafeArea(.container, edges: .vertical)
            .focused($isEditorFocused)
            .onAppear {
                isEditorFocused = true
                editMode = document.contents.isSafelyEditable
            }
            .onChange(of: document.contents.text) { oldValue, _ in
                undoManager?.registerUndo(withTarget: document) { document in
                    document.contents.text = oldValue
                }
            }
            .environment(\.editMode, .constant(editMode ? .active : .inactive))
            .font(family: fontFamily, size: fontSize.map {
                min(max($0, FontSizePicker.validRange.lowerBound), FontSizePicker.validRange.upperBound)
            })
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
                            Label("Dismiss Keyboard", systemImage: "keyboard.chevron.compact.down")
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
            .toolbarTitleMenu {
                RenameButton()
                revertButton
            }
            // Attached to the editor, not to the button in the title menu, which is dismissed along with its presentation.
            .confirmationDialog("Revert file content to state when last opened?", isPresented: $isRevertShown) {
                Button(role: .destructive) {
                    document.contents.revert()
                } label: {
                    Text("Revert to last opened")
                }
                Button(role: .cancel) {}
                    .keyboardShortcut(.cancelAction)
            }
    }
    
    var revertButton: some View {
        Button {
            isRevertShown = true
        } label: {
            revertLabel
        }
        .keyboardShortcut("r")
    }
    var revertLabel: some View {
        Label("Revert", systemImage: "chevron.left.to.line")
    }
    
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
        .environment(\.isPresentedInPopover, hSize != .compact && vSize != .compact)
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

#Preview {
    @Previewable @State var document = SimpleEditDocument(
        contents: .init(
            text: "https://example.com",
            contentType: .plainText
        )
    )
    NavigationStack {
        Editor(document: document)
            .toolbarRole(.editor)
    }
}
