import SwiftUI

struct FontPicker: View {
    @Binding var fontFamily: String?
    @Environment(\.dismiss) private var dismiss
    
    var fontFamilyBinding: Binding<UIFontDescriptor?> {
        Binding {
            fontFamily.map {
                UIFontDescriptor(fontAttributes: [.family: $0])
            }
        } set: {
            fontFamily = $0?.fontAttributes[.family] as? String
        }
    }
    
    var body: some View {
        FontPickerVC(fontFamily: fontFamilyBinding)
            .ignoresSafeArea(edges: .vertical) // Bottom doesn't inset properly
            .safeAreaBar(edge: .bottom, spacing: 0) {
                HStack {
                    Button {
                        fontFamily = nil
                        dismiss()
                    } label: {
                        Text("System")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.glass)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 4)
            }.navigationTitle("Font")
    }
}

struct FontPickerVC: UIViewControllerRepresentable {
    @Binding var fontFamily: UIFontDescriptor?
    
    func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let picker = UIFontPickerViewController(configuration: .init())
        picker.delegate = context.coordinator
        let dismiss = context.environment.dismiss
        context.coordinator.dismiss = { dismiss() }
        return picker
    }
    
    func updateUIViewController(_ picker: UIFontPickerViewController, context: Context) {
        picker.delegate = context.coordinator
        let dismiss = context.environment.dismiss
        context.coordinator.dismiss = { dismiss() }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(fontFamily: $fontFamily)
    }
    
    class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        @Binding var fontFamily: UIFontDescriptor?
        var dismiss: () -> ()
        init(
            fontFamily: Binding<UIFontDescriptor?>,
            dismiss: @escaping () -> () = {}
        ) {
            self._fontFamily = fontFamily
            self.dismiss = dismiss
        }
        
        func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            if let descriptor = viewController.selectedFontDescriptor {
                fontFamily = descriptor
            }
            dismiss()
        }
        func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var fontFamily: String?
    FontPicker(fontFamily: $fontFamily)
}
