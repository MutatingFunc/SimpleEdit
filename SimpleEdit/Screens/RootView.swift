import SwiftUI
import UniformTypeIdentifiers

// An alternative to the document picker. Not currently used.
struct RootView: View {
    @State var document = SimpleEditDocument(text: "")
    @State private var isFileImporterShown = false
    @State private var importError: (any Error)?
    
    var body: some View {
        NavigationStack {
            Editor(document: $document)
                .fileImporter(
                    isPresented: $isFileImporterShown, 
                    allowedContentTypes: [.plainText], 
                    onCompletion: importDocument
                )
                .toolbar { 
                    ToolbarItem(id: "documents", placement: .navigationBarLeading) { 
                        DocumentsButton(
                            isFileImporterShown: $isFileImporterShown,
                            error: $importError
                        )
                    }
                }
        }
    }
    
    func importDocument(_ result: Result<URL, any Error>) {
        do {
            importError = nil
            self.document = try SimpleEditDocument(url: try result.get())
        } catch {
            self.importError = error
        }
    }
}
