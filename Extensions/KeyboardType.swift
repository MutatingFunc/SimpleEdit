import SwiftUI

extension UIKeyboardType: @retroactive EnvironmentKey {
    public static let defaultValue = Self.default
}
extension EnvironmentValues {
    var keyboardType: UIKeyboardType {
        get {self[UIKeyboardType.self]}
        set {self[UIKeyboardType.self] = newValue}
    }
}

extension View {
    func uiKeyboardType(_ type: UIKeyboardType) -> some View {
        self.keyboardType(type)
            .environment(\.keyboardType, type)
    }
}
