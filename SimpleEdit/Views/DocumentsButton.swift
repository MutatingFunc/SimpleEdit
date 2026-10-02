import SwiftUI

struct DocumentsButton: View {
    @Binding var isFileImporterShown: Bool
    @Binding var error: (any Error)?
    
    var isErrorShown: Binding<Bool> {
        Binding {
            error != nil
        } set: { newValue in
            if !newValue {
                error = nil
            }
        }
    }
    
    var body: some View {
        Button { 
            isFileImporterShown.toggle()
        } label: {
            Label("Documents", systemImage: "doc")
        }.alert(isPresented: isErrorShown, error: error.map(ImportError.init)) { 
            Button {
                error = nil
            } label: {
                Text("OK")
            }
        }
    }
    
    struct ImportError: LocalizedError {
        var rawValue: any Error
        var errorDescription: String? {
            (rawValue as? any LocalizedError)?.localizedDescription
        }
    }
    
}
