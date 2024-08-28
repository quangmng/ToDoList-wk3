//
//  TaskModel.swift
//  ToDoList
//
//  Created by Quang Minh Nguyen on 21/8/2024.
//


import Foundation

struct ToDoItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}
