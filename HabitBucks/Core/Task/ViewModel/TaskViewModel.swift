//
//  TaskViewModel.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
    @Published var activeTaskList: [TaskItem]?
    
    static var shared = TaskViewModel()
    
    init() {
        self.activeTaskList = [TaskItem.MOCK_BONUS_TASK_1, TaskItem.MOCK_ONCE_TASK_1, TaskItem.MOCK_ONCE_TASK_2, TaskItem.MOCK_DAILY_TASK_1, TaskItem.MOCK_DAILY_TASK_2, TaskItem.MOCK_WEEKLY_TASK_1, TaskItem.MOCK_WEEKLY_TASK_2]
    }
}
