import SwiftUI

struct SettingsView<AdditionalContent: View>: View {
    @Binding var fontFamily: String?
    @Binding var fontSize: Double?
    @Binding var keyboardType: UIKeyboardType
    @ViewBuilder var additionalContent: () -> AdditionalContent
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    enum Focus: String, Hashable {
        case additionalContent
        case font
        case fontSize
        case keyboard
    }
    
    var body: some View {
        NavigationView {
            List {
                content
            }
            .navigationTitle("Preferences")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.dismiss()
                    }
                    .keyboardShortcut(",")
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    var content: some View {
        additionalContent()
        Section("App") {
            fontPicker
            fontSizePicker
            KeyboardPicker(keyboard: $keyboardType)
                .keyboardShortcut("k")
        }
    }
    
    var fontPicker: some View {
        NavigationLink { 
            FontPicker(fontFamily: $fontFamily)
                .navigationBarTitleDisplayMode(.inline)
        } label: { 
            HStack {
                let currentValue = fontFamily ?? "System"
                Label("Font", systemImage: "textformat.alt")
                    .accessibilityValue(currentValue)
                Spacer()
                Text(currentValue)
                    .font(fontFamily.map{.custom($0, size: 16)})
                    .padding(.vertical, 6)
                    .accessibilityHidden(true)
                    .foregroundColor(.secondary)
            }
        }.keyboardShortcut("f")
    }
    
    var fontSizePicker: some View {
        HStack {
            Label("Font size", systemImage: "textformat.size")
                .accessibilityHidden(true)
            FontSizePicker(fontSize: $fontSize)
        }
    }
}

struct EditorSettings_Previews: PreviewProvider {
    struct Container: View {
        @State private var editMode = true
        @State private var fontFamily: String?
        @State private var fontSize: Double?
        @State private var keyboardType = UIKeyboardType.default
        
        var body: some View {
            SettingsView(
                fontFamily: $fontFamily,
                fontSize: $fontSize,
                keyboardType: $keyboardType
            ) {
                Toggle("Edit mode", isOn: $editMode)
            }
        }
    }
    static var previews: some View {
        Container()
    }
}
