//
//  ToDoRow.swift
//  ToDoList
//
//  Created by Quang Minh Nguyen on 21/8/2024.
//

import SwiftUI

struct ToDoRow: View {
    @Binding var item: ToDoItem
    @ObservedObject var viewModel: ToDoViewModel
    
    @FocusState private var isEditingTaskFocused: Bool
    @State private var showingEditAlert: Bool = false
    @Binding var editingTask: ToDoItem?
    @Binding var editMode: EditMode
    
    var body: some View {
        HStack {
            if editMode == .active, editingTask?.id == item.id {
                TextField("Edit task", text: Binding(
                    get: { item.title },
                    set: { newTitle in
                        if newTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                            showingEditAlert = true
                        } else {
                            viewModel.updateTaskTitle(item: item, newTitle: newTitle)
                            editingTask = nil
                        }
                    })
                )
                
                
            } else {
                Text(item.title)
            }
            Spacer()
        }
    }
    
}

//#Preview {
//    let item = ToDoItem(title: "Predefined Task", isCompleted: true)
//    let viewModel = ToDoViewModel()
//    return ToDoRow(item: .constant(item), viewModel: viewModel)
//}

//#Preview {
//        let item2 = ToDoItem(title: "Predefined Task 2", isCompleted: false)
//        let viewModel = ToDoViewModel()
//        return ToDoRow(item: .constant(item2), viewModel: viewModel)
//}


