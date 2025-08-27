import SwiftUI

struct KeyboardPicker: View {
    @Binding var keyboard: UIKeyboardType
    
    var body: some View {
        Picker(selection: $keyboard) {
            // Update upper bound when adding a new keyboard case to the switch below
            ForEach(0 ..< 12) { row in
                Text(keyboardTypeName(forRow: row))
                    .tag(UIKeyboardType(rawValue: row)!)
            }
        } label: {
            KeyboardPickerLabel()
        }
    }
    
    func keyboardTypeName(forRow row: Int) -> String {
        switch UIKeyboardType(rawValue: row)! {
        case .asciiCapable: return "ASCII"
        case .asciiCapableNumberPad: return "ASCII numpad"
        case .decimalPad: return "Decimal pad"
        case .default: return "Default"
        case .emailAddress: return "Email address"
        case .namePhonePad: return "Name phone pad"
        case .numberPad: return "Number pad"
        case .numbersAndPunctuation: return "Numbers and punctuation"
        case .phonePad: return "Phone pad"
        case .twitter: return "Twitter"
        case .URL: return "URL"
        case .webSearch: return "Web search"
        @unknown case _: return "[unknown type]"
        }
    }
}

struct KeyboardPickerLabel: View {
    var body: some View {
        Label("Keyboard", systemImage: "keyboard.badge.ellipsis")
    }
}

struct KeyboardPicker_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardPicker(keyboard: .constant(.default))
    }
}
