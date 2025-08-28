import SwiftUI

struct EditorCommands: Commands {
    @FocusedBinding(\.editMode) var isEditing: Bool?

    var body: some Commands {
        CommandGroup(before: .saveItem) {
            let boolBinding = Binding<Bool>(
                get: { isEditing ?? false },
                set: { isEditing = $0 }
            )
            EditModeToggle(isEditing: boolBinding)
                .disabled(isEditing == nil)
        }
    }
}
