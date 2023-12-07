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
    @Published var activeBonusTaskList: [TaskItem]?
    @Published var activeOnceTaskList: [TaskItem]?
    @Published var activeDailyTaskList: [TaskItem]?
    @Published var activeWeeklyTaskList: [TaskItem]?
    
    static var shared = TaskViewModel()
    
    init() {
        self.activeBonusTaskList = [TaskItem.MOCK_BONUS_TASK_1]
        self.activeOnceTaskList = [TaskItem.MOCK_ONCE_TASK_1, TaskItem.MOCK_ONCE_TASK_2]
        self.activeDailyTaskList = [TaskItem.MOCK_DAILY_TASK_1, TaskItem.MOCK_DAILY_TASK_2]
        self.activeWeeklyTaskList = [TaskItem.MOCK_WEEKLY_TASK_1, TaskItem.MOCK_WEEKLY_TASK_2]
    }
}
