import SwiftUI

// TODO: Add dynamic type font sizes
struct FontSizePicker: View {
    @FocusState private var isFieldFocused: Bool
    @Binding var fontSize: Double? {
        didSet {
            if let fontSize = fontSize {
                if fontSize < 1 {
                    self.fontSize = 1
                } else if fontSize > 300 {
                    self.fontSize = 300
                }
            }
        }
    }
    
    var fontSizeBinding: Binding<Double> {
        Binding {
            fontSize ?? 0
        } set: { newValue in
            fontSize = newValue <= 0 ? nil : newValue
        }
    }
    
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.maximumIntegerDigits = 3
        formatter.maximum = 300
        formatter.minimum = 1
        return formatter
    }()
    
    var body: some View {
        #if !targetEnvironment(macCatalyst)
        TextField(
            "Font size",
            value: $fontSize,
            formatter: Self.formatter,
            prompt: Text("System")
        )
            .multilineTextAlignment(.trailing)
            .keyboardType(.numberPad)
            .accessibilityLabel("Font size")
            .focused($isFieldFocused)
            .background {
                Button("Font size") {
                    isFieldFocused = true
                }
                .keyboardShortcut("s")
                .hidden()
            }
        #endif
        Stepper(
            "Font size",
            value: fontSizeBinding,
            in: 0 ... (99 as Double)
        ).labelsHidden()
    }
}

struct FontSizePicker_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            FontSizePicker(fontSize: .constant(nil))
        }
    }
}
