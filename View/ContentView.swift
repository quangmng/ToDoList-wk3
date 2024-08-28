//
//  ContentView.swift
//  ToDoList
//
//  Created by Quang Minh Nguyen on 21/8/2024.
//


import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ToDoViewModel
    @State private var showingNewTaskEntry = false
    @State private var newTaskTitle: String = ""
    @State private var isComplete = false
    @State private var editMode = EditMode.inactive
    @State private var editingTask: ToDoItem? = nil
    @FocusState private var isEditingTaskFocused: Bool  // FocusState for TextField
    @State private var showingAlert = false  // State to manage the alert for new task
    @State private var showingEditAlert = false  // State to manage the alert for editing
    @State private var taskToDelete: ToDoItem? = nil  // State to track the task to delete
    @State private var triggerSearch: Bool = false // New state to trigger search
    
    var body: some View {
        NavigationStack{
            List {
                Section{
                    // New Task Entry TextField
                    if showingNewTaskEntry {
                        TextField("Enter your task", text: $newTaskTitle)
                            .focused($isEditingTaskFocused)
                            .onSubmit {
                                if newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                                    showingAlert = true  // Trigger alert if task name is empty
                                } else {
                                    let newTask = ToDoItem(title: newTaskTitle, isCompleted: isComplete)
                                    viewModel.addTask(newTask)
                                    newTaskTitle = ""
                                    showingNewTaskEntry = false
                                }
                            }
                            .alert("You must enter a task name", isPresented: $showingAlert) {
                                Button("OK", role: .cancel) {
                                    isEditingTaskFocused = true  // Refocus the TextField after dismissing the alert
                                }
                            }
                    }
                }
                
                // Filtered task list based on search text
                ForEach(viewModel.searchResults.filter { task in
                    viewModel.searchEntry.isEmpty || task.title.localizedCaseInsensitiveContains(viewModel.searchEntry)
                }) { task in
                    HStack {
                        if editMode == .active, editingTask?.id == task.id {
                            TextField("Edit task", text: Binding(
                                get: { task.title },
                                set: { newTitle in
                                    viewModel.updateTaskTitle(item: task, newTitle: newTitle)
                                })
                            )
                            .focused($isEditingTaskFocused)  // Focus the TextField when needed
                            .onSubmit {
                                if task.title.trimmingCharacters(in: .whitespaces).isEmpty {
                                    showingEditAlert = true  // Trigger alert if task name is empty during editing
                                } else {
                                    editingTask = nil
                                }
                            }
                            .alert("You must enter a task name", isPresented: $showingEditAlert) {
                                Button("OK", role: .cancel) {
                                    isEditingTaskFocused = true  // Refocus the TextField after dismissing the alert
                                }
                            }
                        } else {
                            Text(task.title)
                        }
                        Spacer()
                    }
                    .onTapGesture {
                        if editMode == .active {
                            withAnimation {
                                editingTask = task
                            }
                        }
                    }
                    .transition(.move(edge: .top))
                    .contextMenu(ContextMenu(menuItems: {
                        Button(action: {
                            editMode = .active
                            withAnimation {
                                editingTask = task
                                isEditingTaskFocused = true  // Activate the keyboard and focus the TextField
                            }
                        }) {
                            Label("Edit task name", systemImage: "square.and.pencil")
                        }
                        Button(action:{
                            editMode = .active
                        }) {
                            Label("Reorder task", systemImage:"arrow.up.and.down.text.horizontal")
                            
                        }
                        Divider()
                        Button(role: .destructive) {
                            taskToDelete = task  // Set the task to be deleted
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }))
                }
                .onDelete(perform: viewModel.delete)
                .onMove(perform: viewModel.move)
            }
            .animation(.bouncy, value: viewModel.tasks)
            // Conditionally show the search bar
            .if(!showingNewTaskEntry && editMode == .inactive) {
                $0.searchable(text: $viewModel.searchEntry, prompt: "Search Tasks")
                
            }
            .navigationTitle("Remindr by qmng")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .disabled(isEditingTaskFocused)  // Disable "Done" button when a task is being edited
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    switch editMode {
                    case .inactive:
                        return AnyView(Button(action: {
                            withAnimation{
                                showingNewTaskEntry = true
                            }
                        }) { Image(systemName: "plus.circle.fill") }
                            .font(.system(size:18)))
                    default:
                        return AnyView(EmptyView())
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .alert("Delete Task", isPresented: Binding<Bool>(
                get: { taskToDelete != nil },
                set: { if !$0 { taskToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let task = taskToDelete {
                        viewModel.deleteTask(task)
                    }
                    taskToDelete = nil  // Clear the taskToDelete after deletion
                }
                Button("Cancel", role: .cancel) {
                    taskToDelete = nil  // Clear the taskToDelete if cancelled
                }
            } message: {
                Text("Are you sure you want to delete this task?")
            }
        }
        .onAppear {
            // Listen for quick actions
            NotificationCenter.default.addObserver(forName: .quickActionTriggered, object: nil, queue: .main) { notification in
                if let actionType = notification.object as? QuickAction {
                    handleQuickAction(actionType)
                }
            }
        }
    }
    
    private func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .newTaskAction:
            showingNewTaskEntry = true
        case .searchAction:
            triggerSearch = true
        }
    }
}

extension View {
    // Custom modifier to conditionally apply a view modifier
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ToDoViewModel())
    }
}
