import SwiftUI

struct StoredSettingsView: View {
    @AppStorage("fontFamily") private var fontFamily: String?   
    @AppStorage("fontSize") private var fontSize: Double?
    @AppStorage("keyboardType") private var keyboardType = UIKeyboardType.default
    
    var body: some View {
        SettingsView(
            fontFamily: $fontFamily, 
            fontSize: $fontSize, 
            keyboardType: $keyboardType
        ) {
            EmptyView()
        }
    }
}
