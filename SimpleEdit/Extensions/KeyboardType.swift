import SwiftUI

private enum UIKeyboardTypeKey: EnvironmentKey {
    static let defaultValue: UIKeyboardType = .default
}
extension EnvironmentValues {
    var keyboardType: UIKeyboardType {
        get {self[UIKeyboardTypeKey.self]}
        set {self[UIKeyboardTypeKey.self] = newValue}
    }
}

extension View {
    func uiKeyboardType(_ type: UIKeyboardType) -> some View {
        self.keyboardType(type)
            .environment(\.keyboardType, type)
    }
}
