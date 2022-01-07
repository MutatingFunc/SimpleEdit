import SwiftUI

struct DocumentsButton: View {
    @Binding var isFileImporterShown: Bool
    @Binding var error: Error?
    
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
        var rawValue: Error
        var errorDescription: String? {
            (rawValue as? LocalizedError)?.localizedDescription
        }
    }
    
}
