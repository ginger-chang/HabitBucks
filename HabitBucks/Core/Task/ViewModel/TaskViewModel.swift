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
    @Published var inactiveBonusTaskList: [TaskItem]?
    @Published var inactiveDailyTaskList: [TaskItem]?
    @Published var inactiveWeeklyTaskList: [TaskItem]?
    
    private var uid: String
    private var db = Firestore.firestore()
    private var itemNameToId: Dictionary<String, String> = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    static var shared = TaskViewModel()
    
    init() {
        self.activeBonusTaskList = [TaskItem.MOCK_BONUS_TASK_1]
        self.activeOnceTaskList = []
        self.activeDailyTaskList = []
        self.activeWeeklyTaskList = []
        self.inactiveBonusTaskList = []
        self.inactiveDailyTaskList = []
        self.inactiveWeeklyTaskList = []
        self.uid = ""
    }
    
    // This is called only when the user creates an account & need to set up documents
    // TODO: need to set up new bonus task as well
    func createTasks() async {
        // creating tasks (once * 1, daily * 1, weekly * 1)
        var taskIdArray: [String] = []
        do {
            let id1 = try await storeTaskItemToFirestore(item: TaskItem.DEFAULT_ONCE_TASK)
            let id2 = try await storeTaskItemToFirestore(item: TaskItem.DEFAULT_DAILY_TASK)
            let id3 = try await storeTaskItemToFirestore(item: TaskItem.DEFAULT_WEEKLY_TASK)
            taskIdArray.append(id1)
            taskIdArray.append(id2)
            taskIdArray.append(id3)
            itemNameToId[TaskItem.DEFAULT_ONCE_TASK.name] = id1
            itemNameToId[TaskItem.DEFAULT_DAILY_TASK.name] = id2
            itemNameToId[TaskItem.DEFAULT_WEEKLY_TASK.name] = id3
        } catch {
            print("DEBUG: createTasks() failed, \(error.localizedDescription)")
        }
        // creating user_tasks
        db.collection("user_tasks").document(uid).setData([
            "bonus_status": false, // Replace with the desired boolean value
            "task_item_list": taskIdArray
        ]) { error in
            if let error = error {
                print("DEBUG: Error adding user tasks doc: \(error)")
            }
        }
        DispatchQueue.main.async {
            self.activeOnceTaskList = [TaskItem.DEFAULT_ONCE_TASK]
            self.activeDailyTaskList = [TaskItem.DEFAULT_DAILY_TASK]
            self.activeWeeklyTaskList = [TaskItem.DEFAULT_WEEKLY_TASK]
        }
    }
    
    func asyncSetup() async {
        print("task async setup called")
        // set up subscription to uid
        await AuthViewModel.shared.$currentUser
            .sink { [weak self] newUser in
                self?.uid = newUser?.id ?? ""
            }
            .store(in: &cancellables)
        // check if document doesn't exist, create one
        let collection = db.collection("user_tasks")
        let documentReference = collection.document(self.uid)
        documentReference.getDocument { (document, error) in
            if let error = error {
                print("DEBUG: failed to fetch user_tasks doc with error \(error.localizedDescription)")
            } else {
                // Check if the document exists
                if let document = document, document.exists {
                    // Document exists -> update coins field (and view)
                    Task {
                        await self.fetchTaskList()
                    }
                } else {
                    // Document does not exist -> create new shop
                    Task {
                        await self.createTasks()
                    }
                }
            }
        }
    }
    
    // update the self.shopItemList variable based on database
    func fetchTaskList() async {
        print("fetch task list")
        let docRef = self.db.collection("user_tasks").document(self.uid)
        print("task got uid \(self.uid)")
        docRef.getDocument { (document, error) in
            if let error = error {
                print("DEBUG: task view model fetch task item list failed \(error.localizedDescription)")
            } else if let document = document, document.exists {
                Task {
                    // TODO: fetch bonus
                    let taskIdList = document.get("task_item_list") as? [String]
                    var newActiveOnceList: [TaskItem] = []
                    var newActiveDailyList: [TaskItem] = []
                    var newActiveWeeklyList: [TaskItem] = []
                    var newInactiveDailyList: [TaskItem] = []
                    var newInactiveWeeklyList: [TaskItem] = []
                    for taskItemId in taskIdList ?? [] {
                        let taskItemDocRef = self.db.collection("task_items").document(taskItemId)
                        try await taskItemDocRef.getDocument { (doc, error) in
                            if let error = error {
                                print("DEBUG: fetch shop item list failed - can't get item \(error.localizedDescription)")
                            } else if let doc = doc, doc.exists {
                                let itemEmoji = doc.get("emoji") as? String ?? "❌"
                                let itemName = doc.get("name") as? String ?? "Error"
                                let itemReward = doc.get("reward") as? Int ?? 0
                                let itemType = doc.get("type") as? String ?? "Error"
                                let itemCountGoal = doc.get("count_goal") as? Int ?? 1
                                let itemCountCur = doc.get("count_cur") as? Int ?? 0
                                let itemUpdate = doc.get("update") as? [Bool] ?? []
                                let itemView = doc.get("view") as? [Bool] ?? []
                                let item = TaskItem(emoji: itemEmoji, name: itemName, reward: itemReward, type: itemType, count_goal: itemCountGoal, count_cur: itemCountCur, update: itemUpdate, view: itemView)
                                if (itemCountCur == itemCountGoal) { // INACTIVE
                                    if (itemType == "daily") {
                                        newInactiveDailyList.append(item)
                                        self.inactiveDailyTaskList = newInactiveDailyList.sorted{ $0.name < $1.name }
                                    } else if (itemType == "weekly") {
                                        newInactiveWeeklyList.append(item)
                                        self.inactiveWeeklyTaskList = newInactiveWeeklyList.sorted{ $0.name < $1.name }
                                    }
                                } else { // ACTIVE
                                    if (itemType == "once") {
                                        newActiveOnceList.append(item)
                                        self.activeOnceTaskList = newActiveOnceList.sorted{ $0.name < $1.name }
                                    } else if (itemType == "daily") {
                                        newActiveDailyList.append(item)
                                        self.activeDailyTaskList = newActiveDailyList.sorted{ $0.name < $1.name }
                                    } else if (itemType == "weekly") {
                                        newActiveWeeklyList.append(item)
                                        self.activeWeeklyTaskList = newActiveWeeklyList.sorted{ $0.name < $1.name }
                                    }
                                }
                                self.itemNameToId[item.name] = taskItemId
                                print(self.activeWeeklyTaskList)
                            } else {
                                print("DEBUG: fetch task item doesn't exist")
                            }
                        }
                    }
                }
            } else {
                // Document does not exist
                print("DEBUG: fetch shop item user shop doesn't exist")
            }
        }
    }
    
    func addTask(item: TaskItem) async {
        print("add task: \(item)")
        // add locally
        DispatchQueue.main.async {
            if (item.type == "once") {
                self.activeOnceTaskList?.append(item)
                self.activeOnceTaskList = self.activeOnceTaskList?.sorted{ $0.name < $1.name }
            } else if (item.type == "daily") {
                self.activeDailyTaskList?.append(item)
                self.activeDailyTaskList = self.activeDailyTaskList?.sorted{ $0.name < $1.name }
            } else if (item.type == "weekly") {
                self.activeWeeklyTaskList?.append(item)
                self.activeWeeklyTaskList = self.activeWeeklyTaskList?.sorted{ $0.name < $1.name }
            }
        }
        // add to firestore & append to firestore array
        do {
            let id = try await storeTaskItemToFirestore(item: item)
            itemNameToId[item.name] = id
            let docRef = self.db.collection("user_tasks").document(self.uid)
            try await docRef.updateData([
                "task_item_list": FieldValue.arrayUnion([id])
            ])
        } catch {
            print("DEBUG: fail to append task id to firestore, \(error.localizedDescription)")
        }
    }
    
    // count_cur + 1
    func completeTask(item: TaskItem) {
        let newItem = TaskItem(emoji: item.emoji, name: item.name, reward: item.reward, type: item.type, count_goal: item.count_goal, count_cur: item.count_cur + 1, update: item.update, view: item.view)
        print("newItem: \(newItem)")
        CoinManager.shared.addCoins(n: item.reward)
        // TODO: update firestore entry
        try? updateTaskItemInFirestore(oldItem: item, newItem: newItem)
        updateListEntry(oldItem: item, newItem: newItem)
    }
    
    // count_cur = 0
    func resetTask(item: TaskItem) {
        print("reset task!! \(item.name)")
        let newItem = TaskItem(emoji: item.emoji, name: item.name, reward: item.reward, type: item.type, count_goal: item.count_goal, count_cur: 0, update: item.update, view: item.view)
        CoinManager.shared.minusCoins(n: item.reward * item.count_cur)
        try? updateTaskItemInFirestore(oldItem: item, newItem: newItem)
        updateListEntry(oldItem: item, newItem: newItem)
    }
    
    func updateListEntry(oldItem: TaskItem, newItem: TaskItem) {
        if (newItem.count_cur == newItem.count_goal) {
            if (newItem.type == "once") {
                if var list = self.activeOnceTaskList {
                    list.removeAll { $0 == oldItem }
                    self.activeOnceTaskList = list.sorted{ $0.name < $1.name }
                }
            } else if (newItem.type == "daily") {
                if var list = self.activeDailyTaskList {
                    list.removeAll { $0 == oldItem }
                    self.activeDailyTaskList = list.sorted{ $0.name < $1.name }
                }
                self.inactiveDailyTaskList?.append(newItem)
                self.inactiveDailyTaskList = self.inactiveDailyTaskList?.sorted{ $0.name < $1.name }
            } else if (newItem.type == "weekly") {
                if var list = self.activeWeeklyTaskList {
                    list.removeAll { $0 == oldItem }
                    self.activeWeeklyTaskList = list.sorted{ $0.name < $1.name }
                }
                self.inactiveWeeklyTaskList?.append(newItem)
                self.inactiveWeeklyTaskList = self.inactiveWeeklyTaskList?.sorted{ $0.name < $1.name }
            }
        } else if (oldItem.count_cur == oldItem.count_goal && newItem.count_cur != newItem.count_goal) {
            // reset
            if (newItem.type == "daily") {
                if var list = self.inactiveDailyTaskList {
                    list.removeAll { $0 == oldItem }
                    self.inactiveDailyTaskList = list.sorted{ $0.name < $1.name }
                }
                self.activeDailyTaskList?.append(newItem)
            } else if (newItem.type == "weekly") {
                if var list = self.inactiveWeeklyTaskList {
                    list.removeAll { $0 == oldItem }
                    self.inactiveWeeklyTaskList = list.sorted{ $0.name < $1.name }
                }
                self.activeWeeklyTaskList?.append(newItem)
                self.activeWeeklyTaskList = self.activeWeeklyTaskList?.sorted{ $0.name < $1.name }
            }
        } else {
            if (newItem.type == "once") {
                if var list = self.activeOnceTaskList {
                    list.removeAll { $0 == oldItem }
                    list.append(newItem)
                    self.activeOnceTaskList = list.sorted{ $0.name < $1.name }
                }
            } else if (newItem.type == "daily") {
                if var list = self.activeDailyTaskList {
                    list.removeAll { $0 == oldItem }
                    list.append(newItem)
                    self.activeDailyTaskList = list.sorted{ $0.name < $1.name }
                }
            } else if (newItem.type == "weekly") {
                if var list = self.activeWeeklyTaskList {
                    list.removeAll { $0 == oldItem }
                    list.append(newItem)
                    self.activeWeeklyTaskList = list.sorted{ $0.name < $1.name }
                }
            }
        }
    }
    
    // returns id of the document
    func storeTaskItemToFirestore(item: TaskItem) async throws -> String {
        let encodedTaskItem = try Firestore.Encoder().encode(item)
        let itemId = try await db.collection("task_items").addDocument(data: encodedTaskItem)
        return itemId.documentID
    }
    
    // whenever task is modified in some way
    // try not to use async, see coin manager
    // first check if oldName exists -> if yes, then directly get id from itemNameToId
    // else delete old entry from dict, and add new name
    func updateTaskItemInFirestore(oldItem: TaskItem, newItem: TaskItem) throws -> String {
        if (newItem.type == "once" && newItem.count_cur == newItem.count_goal) {
            // get id of the shop_item from the dict
            let itemId = itemNameToId[oldItem.name]
            let docRef = Firestore.firestore().collection("task_items").document(itemId ?? "")
            docRef.delete { error in
                if let error = error {
                    print("DEBUG: Error deleting task item doc: \(error)")
                }
            }
            // remove the id from user shop doc
            let userTaskDocRef = db.collection("user_tasks").document(self.uid)
            Task {
                try await userTaskDocRef.updateData([
                  "task_item_list": FieldValue.arrayRemove([itemId])
                ])
            }
        } else {
            let encodedNewItem = try Firestore.Encoder().encode(newItem)
            db.collection("task_items").document(self.itemNameToId[oldItem.name] ?? "").setData(encodedNewItem) { error in
                if let error = error {
                    print("DEBUG: Error adding user shop document: \(error)")
                }
            }
        }
        return ""
    }

    // separated the day by 4am
    // TODO: not sure if this is working
    func getYYYYMMDD() -> String {
        let currentDate = Date()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        
        // Set the custom start time (4am in this case)
        let customStartTime = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: startOfDay) ?? startOfDay
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let formattedDateString = dateFormatter.string(from: customStartTime)
        
        return formattedDateString
    }
    
    func printDebug() {
        print("---------------")
        print("active list:")
        print("\(self.activeBonusTaskList) \(self.activeOnceTaskList) \(self.activeDailyTaskList) \(self.activeWeeklyTaskList)")
        print("inactive list:")
        print("\(self.inactiveBonusTaskList) \(self.inactiveDailyTaskList) \(self.inactiveWeeklyTaskList)")
        print("---------------")
    }
}
