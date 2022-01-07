import SwiftUI
import UniformTypeIdentifiers

struct SimpleEditDocument: FileDocument {
    static let readableContentTypes: [UTType] = [.plainText, .data]
    static let defaultFileName = "Untitled.txt"
    
    let originalText: String
    var text: String
    var filename: String
    var isSafelyEditable: Bool
    
    enum LoadError: String, LocalizedError {
        case incorrectContentType = "Incorrect file type"
        case noFileContentsFound = "File content not recognised"
        var errorDescription: String? { rawValue }
    }
    
    init(text: String = "", filename: String = Self.defaultFileName, isSafelyEditable: Bool = true) {
        self.originalText = text
        self.text = text
        self.filename = filename
        self.isSafelyEditable = isSafelyEditable
    }
    
    init(data: Data, filename: String = Self.defaultFileName, isSafelyEditable: Bool = true) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.init(
            text: text, 
            filename: filename, 
            isSafelyEditable: isSafelyEditable
        )
    }
    
    init(url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw CocoaError(.fileReadNoPermission)
        }
        let contents = try String(contentsOf: url)
        url.stopAccessingSecurityScopedResource()
        self.init(
            text: contents, 
            filename: url.lastPathComponent, 
            isSafelyEditable: UTType(filenameExtension: url.pathExtension) == .plainText
        )
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let contents = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        try self.init(
            data: contents, 
            filename: configuration.file.filename 
            ?? configuration.file.preferredFilename
            ?? Self.defaultFileName,
            isSafelyEditable: configuration.contentType == .plainText
        )
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
    
    mutating func revert() {
        self.text = originalText
    }
}
