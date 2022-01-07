import SwiftUI

struct RootView: View {
    @State var document = SimpleEditDocument(text: "")
    @State private var isFileImporterShown = false
    @State private var importError: Error?
    
    var body: some View {
        NavigationView {
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
        .navigationViewStyle(.stack)
    }
    
    func importDocument(_ result: Result<URL, Error>) {
        do {
            importError = nil
            self.document = try SimpleEditDocument(url: try result.get())
        } catch {
            self.importError = error
        }
    }
}
