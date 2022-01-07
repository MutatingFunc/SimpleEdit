import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.backgroundColor = .clear
        view.text = text
        view.dataDetectorTypes = .all
        updateUIView(view, context: context)
        return view
    }
    
    func updateUIView(_ view: UITextView, context: Context) {
        setIfNeeded(&view.isEditable, to: context.environment.editMode?.wrappedValue.isEditing == true)
        setIfNeeded(&view.directionalPressGestureRecognizer.isEnabled, to: !view.isEditable)
        if context.environment.isFocused, !view.isFirstResponder {
            view.becomeFirstResponder()
        }
        setIfNeeded(&view.font, to: context.environment.uiFont)
        setIfNeeded(&view.keyboardType, to: context.environment.keyboardType)
        view.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    func setIfNeeded<T: Equatable>(_ value: inout T, to newValue: T) {
        if value != newValue {
            value = newValue
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            self._text = text
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(text: .constant("Hello world!"))
            .previewDisplayName("Standard TextView")
        TextView(text: .constant("https://example.com"))
            .previewDisplayName("Data detection")
        TextView(text: .constant(String(repeating: "Hello world! ", count: 1000)))
            .previewDisplayName("Long TextView")
        TextView(text: State(initialValue: "123").projectedValue)
            .environment(\.editMode, .constant(.active))
            .previewDisplayName("Editable TextView")
    }
}
