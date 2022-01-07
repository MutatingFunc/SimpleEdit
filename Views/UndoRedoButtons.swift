import SwiftUI

struct UndoButton: View {
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        Button {
            undoManager?.undo()
        } label: {
            Label("Undo", systemImage: "undo")
        }.disabled(undoManager?.canUndo != true)
    }
}

struct RedoButton: View {
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        Button {
            undoManager?.redo()
        } label: {
            Label("Redo", systemImage: "redo")
        }.disabled(undoManager?.canRedo != true)
    }
}
