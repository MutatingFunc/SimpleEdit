import SwiftUI
import UniformTypeIdentifiers

@Observable
final class SimpleEditDocument: Document, Transferable {
    static let readableContentTypes = [UTType.plainText, .data]
    static let defaultFileName = "Untitled.txt"
    
    struct Contents: Sendable {
        var originalText: String
        var text: String
        var filename: String
        var contentType: UTType
        var isSafelyEditable: Bool {
            contentType == .plainText
        }
        
        mutating func revert() {
            text = originalText
        }
        
        func writeToFile(in fileURL: URL) throws -> URL {
            let url = fileURL.appending(component: filename)
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        }
        
        init(text: String, filename: String = SimpleEditDocument.defaultFileName, contentType: UTType = .plainText) {
            self.originalText = text
            self.text = text
            self.filename = filename
            self.contentType = contentType
        }
    }
    var contents: Contents
    init(contents: Contents) { self.contents = contents }
    
    func reader(configuration: sending ReadConfiguration) -> sending FileWrapperDocumentReader<Contents> {
        FileWrapperDocumentReader(configuration) { [contentType = configuration.contentType] fileWrapper in
            guard let data =
                fileWrapper.regularFileContents else {
                throw CocoaError(.fileReadCorruptFile)
            }
            let text = String(decoding: data, as: UTF8.self)
            return Contents(
                text: text,
                filename: fileWrapper.filename ?? fileWrapper.preferredFilename ?? Self.defaultFileName,
                contentType: contentType
            )
        }
    }
    
    func writer(configuration: sending WriteConfiguration) -> sending FileWrapperDocumentWriter<Contents> {
        FileWrapperDocumentWriter(configuration) { snapshot, _ in
            let fileWrapper = FileWrapper(
                regularFileWithContents: Data(snapshot.text.utf8)
            )
            fileWrapper.filename = snapshot.filename
            return fileWrapper
        }
    }
    
    @MainActor
    func snapshot(contentType: UTType) async throws -> sending Contents { contents }
    
    @MainActor
    func apply(snapshot: sending Contents, previous: sending Contents?) async throws {
        contents = snapshot
    }
    
    /// Import
    convenience init(url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw CocoaError(.fileReadNoPermission)
        }
        defer { url.stopAccessingSecurityScopedResource() }
        let contents = try String(contentsOf: url, encoding: .utf8)
        self.init(
            contents: .init(
                text: contents,
                filename: url.lastPathComponent,
                contentType: UTType(filenameExtension: url.pathExtension) ?? .data
            )
        )
    }
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .plainText) { doc in
            SentTransferredFile(
                try doc.contents.writeToFile(
                    in: try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                )
            )
        } importing: { received in
            try SimpleEditDocument(url: received.file)
        }

    }
}

