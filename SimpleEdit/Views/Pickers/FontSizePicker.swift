import SwiftUI

// TODO: Add dynamic type font sizes
struct FontSizePicker: View {
    @FocusState private var isFieldFocused: Bool
    @Binding var fontSize: Double?
    
    static let validRange: ClosedRange<Double> = 1 ... 300
    
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
        formatter.maximum = validRange.upperBound as NSNumber
        formatter.minimum = validRange.lowerBound as NSNumber
        return formatter
    }()
    
    var body: some View {
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
        Stepper(
            "Font size",
            value: fontSizeBinding,
            in: 8 ... Self.validRange.upperBound
        ).labelsHidden()
    }
}

#Preview {
    HStack {
        FontSizePicker(fontSize: .constant(nil))
    }
}
