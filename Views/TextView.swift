import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    @FocusState.Binding var focused: Bool
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.text = text
        view.dataDetectorTypes = .all
        view.keyboardDismissMode = .interactive
        updateUIView(view, context: context)
        return view
    }
    
    func updateUIView(_ view: UITextView, context: Context) {
        setIfNeeded(&view.text, to: text)
        setIfNeeded(&view.isEditable, to: context.environment.editMode?.wrappedValue.isEditing == true)
        setIfNeeded(&view.directionalPressGestureRecognizer.isEnabled, to: !view.isEditable)
        setIfNeeded(&view.font, to: context.environment.uiFont)
        setIfNeeded(&view.keyboardType, to: context.environment.keyboardType)
        view.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, focused: $focused)
    }
    
    func setIfNeeded<T: Equatable>(_ value: inout T, to newValue: T) {
        if value != newValue {
            value = newValue
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        @FocusState.Binding var focused: Bool
        init(text: Binding<String>, focused: FocusState<Bool>.Binding) {
            self._text = text
            self._focused = focused
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            focused = true
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            focused = false
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(text: .constant("Hello world!"), focused: FocusState<Bool>().projectedValue)
            .previewDisplayName("Standard TextView")
        TextView(text: .constant("https://example.com"), focused: FocusState<Bool>().projectedValue)
            .previewDisplayName("Data detection")
        TextView(text: .constant(String(repeating: "Hello world! ", count: 1000)), focused: FocusState<Bool>().projectedValue)
            .previewDisplayName("Long TextView")
        TextView(text: State(initialValue: "123").projectedValue, focused: FocusState<Bool>().projectedValue)
            .environment(\.editMode, .constant(.active))
            .previewDisplayName("Editable TextView")
    }
}
