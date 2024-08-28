//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by Quang Minh Nguyen on 21/8/2024.
//

import SwiftUI

@main
struct ToDoListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = ToDoViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ToDoViewModel())
                .environmentObject(viewModel)
                .defaultAppStorage(UserDefaults(suiteName: "group.au.quang.ToDoList.shared")!)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        guard let actionType = QuickAction(rawValue: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        NotificationCenter.default.post(name: .quickActionTriggered, object: actionType)
        completionHandler(true)
    }
}

enum QuickAction: String {
    case newTaskAction = "NewTaskAction"
    case searchAction = "SearchAction"
}

extension Notification.Name {
    static let quickActionTriggered = Notification.Name("quickActionTriggered")
}
