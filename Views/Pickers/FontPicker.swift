import SwiftUI

struct FontPicker: View {
    @Binding var fontFamily: String?
    @Environment(\.presentationMode) @Binding var presentationMode
    @State private var isShowingNativePicker = false
    
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
        let picker = FontPickerVC(fontFamily: fontFamilyBinding)
#if targetEnvironment(macCatalyst)
        Menu("Font") {
            Button {
                isShowingNativePicker.toggle()
            } label: {
                Text("Other")
            }.sheet(isPresented: $isShowingNativePicker) {
                picker
            }
            Button("System") {
                fontFamily = nil
            }
        }
#else
        picker
            .edgesIgnoringSafeArea(.top) // Bottom doesn't inset properly
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 0)
                        .background(.bar)
                    Divider()
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    Divider()
                    HStack {
                        Button {
                            fontFamily = nil
                            presentationMode.dismiss()
                        } label: {
                            Text("System")
                                .frame(maxWidth: .infinity)
                        }.buttonStyle(.borderedProminent)
                        Button {
                            presentationMode.dismiss()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        }.buttonStyle(.bordered)
                    }
                    .padding(12)
                    .background(.bar)
                    .background {
                        Color.clear
                            .shadow(radius: 1, x: 0, y: 0)
                    }
                }
            }.navigationTitle("Font")
#endif
    }
}

struct FontPickerVC: UIViewControllerRepresentable {
    @Binding var fontFamily: UIFontDescriptor?
    
    func makeUIViewController(context: Context) -> UIFontPickerViewController {
        let picker = UIFontPickerViewController(configuration: .init())
        picker.delegate = context.coordinator
        context.coordinator.dismiss = {context.environment.presentationMode.wrappedValue.dismiss()}
        return picker
    }
    
    func updateUIViewController(_ picker: UIFontPickerViewController, context: Context) {
        picker.delegate = context.coordinator
        context.coordinator.dismiss = {context.environment.presentationMode.wrappedValue.dismiss()}
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

struct FontPicker_Previews: PreviewProvider {
    struct Container: View {
        @State private var fontFamily: String?
        
        var body: some View {
            VStack {
                FontPicker(fontFamily: $fontFamily)
                Divider()
                Text("\(fontFamily)" as String)
            }
        }
    }
    static var previews: some View {
        Container()
    }
}
