//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Quang Minh Nguyen on 21/8/2024.
//

import Foundation
import Combine
import SwiftUI

class ToDoViewModel: ObservableObject {
    @Published var tasks: [ToDoItem]
    @Published var removeTasks: [ToDoItem]
    @Published var searchEntry: String
    @Published var newTask: String
    @Published var editMode: EditMode = .inactive
    @Published var editingTask: ToDoItem? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsKey = "tasks"
    
    init(
        tasks: [ToDoItem] = [],
        removeTasks: [ToDoItem] = [],
        searchEntry: String = "",
        newTask: String = ""
    ) {
        self.tasks = tasks
        self.removeTasks = removeTasks
        self.searchEntry = searchEntry
        self.newTask = newTask
        loadTasks()
    }
    
    var searchResults: [ToDoItem] {
        guard !searchEntry.isEmpty else { return tasks }
        return tasks.filter { task in
            task.title.lowercased().contains(searchEntry.lowercased())
        }
    }
    
    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks(tasks)
    }
    
    func move(source: IndexSet, destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
    }
    
    func addTask(_ task: ToDoItem) {
        tasks.insert(task, at: 0)
        saveTasks(tasks)
    }
    
    func updateTaskTitle(item: ToDoItem, newTitle: String) {
        if let index = tasks.firstIndex(where: { $0.id == item.id }) {
            tasks[index].title = newTitle
            saveTasks(tasks)
        }
    }
    
    func deleteTask(_ task: ToDoItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            saveTasks(tasks)
        }
    }
    
    func toggleTaskCompletion(for item: ToDoItem) {
        if let index = tasks.firstIndex(where: { $0.id == item.id }) {
            print("Before toggle: \(tasks[index].isCompleted)") //debug purposes
            tasks[index].isCompleted.toggle()
            print("After toggle: \(tasks[index].isCompleted)")
            saveTasks(tasks)
        }
    }

    private func saveTasks(_ tasks: [ToDoItem]) {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedTasks = try? JSONDecoder().decode([ToDoItem].self, from: data) {
            tasks = savedTasks
        }
    }
}
