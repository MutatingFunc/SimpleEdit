import Testing
import Foundation
import UniformTypeIdentifiers
@testable import SimpleEdit

struct SimpleEditDocumentTests {
    @Test func newDocumentUsesDefaults() {
        let document = SimpleEditDocument(text: "Hello")
        #expect(document.text == "Hello")
        #expect(document.originalText == "Hello")
        #expect(document.filename == SimpleEditDocument.defaultFileName)
        #expect(document.isSafelyEditable)
    }

    @Test func editingDoesNotChangeTheOriginalText() {
        var document = SimpleEditDocument(text: "original")
        document.text = "edited"
        #expect(document.originalText == "original")
    }

    @Test func revertRestoresTheTextTheDocumentWasOpenedWith() {
        var document = SimpleEditDocument(text: "original")
        document.text = "edited"
        document.revert()
        #expect(document.text == "original")
    }

    @Test func utf8DataIsDecoded() throws {
        let document = try SimpleEditDocument(data: Data("héllo ✓".utf8))
        #expect(document.text == "héllo ✓")
        #expect(document.originalText == "héllo ✓")
    }

    @Test func dataInitializerKeepsFilenameAndEditability() throws {
        let document = try SimpleEditDocument(
            data: Data("x".utf8),
            filename: "notes.md",
            isSafelyEditable: false
        )
        #expect(document.filename == "notes.md")
        #expect(!document.isSafelyEditable)
    }

    @Test(arguments: [
        [0xFF, 0xFE, 0xFD],
        [0xC3, 0x28],
    ] as [[UInt8]])
    func invalidUTF8Throws(bytes: [UInt8]) {
        #expect {
            try SimpleEditDocument(data: Data(bytes))
        } throws: { error in
            (error as? CocoaError)?.code == .fileReadCorruptFile
        }
    }

    @Test func emptyDataIsAnEmptyDocument() throws {
        let document = try SimpleEditDocument(data: Data())
        #expect(document.text.isEmpty)
    }

    @Test func plainTextIsReadable() {
        #expect(SimpleEditDocument.readableContentTypes.contains(.plainText))
    }
}
