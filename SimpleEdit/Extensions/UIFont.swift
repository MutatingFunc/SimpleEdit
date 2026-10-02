import SwiftUI

private enum UIFontKey: EnvironmentKey {
    static let defaultValue = UIFont.preferredFont(forTextStyle: .body)
}

extension EnvironmentValues {
    var uiFont: UIFont {
        get {self[UIFontKey.self]}
        set {self[UIFontKey.self] = newValue}
    }
}

extension View {
    func uiFont(_ uiFont: UIFont) -> some View {
        self.environment(\.uiFont, uiFont)
    }
}

extension View {
    func font(family: String?, size: Double?) -> some View {
        self
            .font(
                family.map {
                    .custom($0, size: size ?? 14)
                } ?? size.map {
                    .system(size: $0)
                }
            )
            .uiFont(
                family.flatMap { family -> UIFont? in
                        .init(name: family, size: size ?? UIFont.systemFontSize)
                } ?? size.map { size -> UIFont in
                        .systemFont(ofSize: size)
                } ?? .preferredFont(forTextStyle: .body)
            )
    }
}
