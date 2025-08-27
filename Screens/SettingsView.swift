import SwiftUI
import About

struct SettingsView<AdditionalContent: View>: View {
    @Binding var fontFamily: String?
    @Binding var fontSize: Double?
    @Binding var keyboardType: UIKeyboardType
    @ViewBuilder var additionalContent: () -> AdditionalContent
    @Environment(\.dismiss) private var dismiss
    
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
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "xmark.circle")
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AboutLink(
                        app: .simpleEdit,
                        features: [],
                        tips: [
                            IAPProduct(id: "James.SimpleEdit.SmallTip", image: Image(systemName: "face.smiling")),
                            IAPProduct(id: "James.SimpleEdit.MediumTip", image: Image(systemName: "cup.and.heat.waves")),
                            IAPProduct(id: "James.SimpleEdit.LargeTip", image: Image(systemName: "heart.square")),
                        ]
                    )
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
        Section {
            systemSettingsLink
        }
    }
    
    @ViewBuilder
    var systemSettingsLink: some View {
        let destination = URL(string: UIApplication.openSettingsURLString)
        Link(destination: destination ?? URL(string: "about:blank")!) {
            LabeledContent {
                Image(systemName: "arrow.up.forward.app")
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            } label: {
                Label("System Settings", systemImage: "gear")
            }
        }.disabled(destination == nil)
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
