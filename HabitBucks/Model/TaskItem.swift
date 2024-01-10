//
//  TaskItem.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
//

import Foundation

struct TaskItem: Codable, Identifiable {
    var id = UUID()
    let emoji: String
    let name: String
    let reward: Int
    let type: String // "bonus" "once" "daily" "weekly"
    let count_goal: Int
    let count_cur: Int
    let update: [Bool]
    let view: [Bool]
    // let active: Bool
    
    /**
            SETTINGS
                1. once & bonus: all update = false, all view = true
                2. daily: all update = true, all view = true
                3. weekly: update = all false except one, all view = true & else
                4. check active status by count_goal = count_cur
     "finish on assigned day -> daily?"
     "auto-reset"
     */
    
    
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        return lhs.emoji == rhs.emoji && lhs.name == rhs.name && lhs.reward == rhs.reward && lhs.type == rhs.type
    }
}

extension TaskItem {
    static var MOCK_DAILY_TASK_1 = TaskItem(emoji: "🚰", name: "Drink water", reward: 2, type: "daily", count_goal: 6, count_cur: 2,
                                            update: [true, true, true, true, true, true, true], view: [true, true, true, true, true, true, true])
    static var MOCK_DAILY_TASK_2 = TaskItem(emoji: "🛌", name: "Make bed", reward: 5, type: "daily", count_goal: 1, count_cur: 0,
                                            update: [true, true, true, true, true, true, true], view: [true, true, true, true, true, true, true])
    static var MOCK_WEEKLY_TASK_1 = TaskItem(emoji: "👨‍👩‍👦", name: "Call parents_mock", reward: 10, type: "weekly", count_goal: 3, count_cur: 1,
                                             update: [true, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
    static var MOCK_WEEKLY_TASK_2 = TaskItem(emoji: "🏋️", name: "Go to gym", reward: 25, type: "weekly", count_goal: 2, count_cur: 1,
                                             update: [false, true, false, false, false, false, false], view: [false, true, false, false, false, true, false])
    static var MOCK_ONCE_TASK_1 = TaskItem(emoji: "📝", name: "Finish paper rough draft", reward: 18, type: "once", count_goal: 1, count_cur: 1,
                                           update: [false, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
    static var MOCK_ONCE_TASK_2 = TaskItem(emoji: "💻", name: "Fix computer", reward: 12, type: "once", count_goal: 1, count_cur: 0,
                                           update: [false, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
    static var MOCK_BONUS_TASK_1 = TaskItem(emoji: "🧙‍♀️", name: "Today's Bonus Task: Play a personality test", reward: 5, type: "bonus", count_goal: 1, count_cur: 0,
                                            update: [false, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
    static var BONUS_1 = TaskItem(emoji: "💌", name: "Bonus Task: Tell someone you appreciate them", reward: 10, type: "bonus", count_goal: 1, count_cur: 0,
                                  update: [false, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
    static var DEFAULT_ONCE_TASK = TaskItem(emoji: "📱", name: "Learn to use HabitBucks (Profile > How to use)", reward: 15, type: "once", count_goal: 1, count_cur: 0,
                                            update: [false, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
    static var DEFAULT_DAILY_TASK = TaskItem(emoji: "🥛", name: "Drink 2 cups of milk", reward: 5, type: "daily", count_goal: 2, count_cur: 0,
                                             update: [true, true, true, true, true, true, true], view: [true, true, true, true, true, true, true])
    static var DEFAULT_WEEKLY_TASK = TaskItem(emoji: "👨‍👩‍👦", name: "Call parents", reward: 10, type: "weekly", count_goal: 3, count_cur: 0,
                                              update: [true, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
}
