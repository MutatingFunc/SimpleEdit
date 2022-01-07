import SwiftUI
import Combine

// TODO: Doesn't work, not reloaded on canUndo/canRedo change

struct UndoButton: View {
    @Environment(\.undoManager) var undoManager
    @State private var canUndo = false
    
    var body: some View {
        Button {
            undoManager?.undo()
        } label: {
            Label("Undo", systemImage: "arrow.uturn.backward")
        }
        .disabled(undoManager?.canUndo != true)
    }
    
    private func update() {
        canUndo = undoManager?.canUndo == true
    }
}

struct RedoButton: View {
    @Environment(\.undoManager) var undoManager
    @State private var canRedo = false
    
    var body: some View {
        Button {
            undoManager?.redo()
        } label: {
            Label("Redo", systemImage: "arrow.uturn.forward")
        }
        .disabled(undoManager?.canRedo != true)
    }
    
    private func update() {
        canRedo = undoManager?.canRedo == true
    }
}
