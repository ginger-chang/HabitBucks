//
//  TaskViewModel.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
// Next time: 1/23

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import Combine

protocol TaskFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class TaskViewModel: ObservableObject {
    @Published var activeBonusTaskList: [TaskItem]? // colorful
    @Published var activeOnceTaskList: [TaskItem]?
    @Published var activeDailyTaskList: [TaskItem]?
    @Published var activeWeeklyTaskList: [TaskItem]?
    @Published var inactiveBonusTaskList: [TaskItem]? // gray
    @Published var inactiveDailyTaskList: [TaskItem]?
    @Published var inactiveWeeklyTaskList: [TaskItem]?
    @Published var sleepingTaskList: [TaskItem]? // not shown
    @Published var bonusStatus: Bool
    // true = active; false = inactive
    
    private var uid: String
    private var db = Firestore.firestore()
    var itemNameToId: Dictionary<String, String> = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    static var shared = TaskViewModel()
    
    init() {
        print("init task vm")
        self.activeBonusTaskList = []
        self.activeOnceTaskList = []
        self.activeDailyTaskList = []
        self.activeWeeklyTaskList = []
        self.inactiveBonusTaskList = []
        self.inactiveDailyTaskList = []
        self.inactiveWeeklyTaskList = []
        self.sleepingTaskList = []
        self.uid = ""
        self.bonusStatus = true
    }
    
    func checkUpdate() {
        let currentDate = currentLocalTime()
        print("cur date is \(currentDate)")
        let nu = needUpdate(date: currentDate)
        print("need update is \(nu)")
        if (nu > 0) {
            Task {
                print("in task update")
                await update(currentDate: currentDate, daysSince: nu)
            }
        }
    }
    
    func needUpdate(date: Date) -> Int {
        if let lastUpdate = UserDefaults.standard.object(forKey: "lastUpdate") as? Date {
            // last update exists
            let last4am = last4AM(date: date) // date object
            print("last update is \(lastUpdate), last4am is \(last4am)")
            if (lastUpdate < last4am) {
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.day], from: lastUpdate, to: last4am)
                if let days = dateComponents.day {
                    return min(abs(days) + 1, 7) // + 6 % 7
                } else {
                    return 1
                }
            }
            return 0
        } else {
            return 1
        }
    }
    
    func updateSince(updateArray: [Bool], daysSince: Int, currentDay: Int) -> Bool {
        var rtn = false
        var cd = currentDay
        for _ in 0..<daysSince {
            rtn = rtn || updateArray[cd]
            cd = (cd + 6) % 7
        }
        return rtn
    }
    
    func resetLastUpdate() {
        let currentDate = currentLocalTime()
        UserDefaults.standard.set(currentDate, forKey: "lastUpdate")
    }
    
    // Update (reset): for daily & weekly & bonus
    func update(currentDate: Date, daysSince: Int) async {
        print("update!")
        UserDefaults.standard.set(currentDate, forKey: "lastUpdate")
        // go through every single task item, set up "new" active/inactive/sleeping arrays, then reset self.xxx
        // 1. view (control which arrs tasks should be in) 2. update (reset tasks)
        let currentDay = getDay(date: currentDate)
        print("today is \(currentDay)")
        
        // UPDATES first - this will make sure all entries in self.xxx is the new, updated version
        if let taskArray = self.activeDailyTaskList {
            for task in taskArray {
                resetTask(item: task, minusCoin: false) // all update
            }
        }
        if let taskArray = self.inactiveDailyTaskList {
            for task in taskArray {
                resetTask(item: task, minusCoin: false) // all update
            }
        }
        if let taskArray = self.activeWeeklyTaskList {
            for task in taskArray {
                if (updateSince(updateArray: task.update, daysSince: daysSince, currentDay: currentDay)) {
                    resetTask(item: task, minusCoin: false)
                }
            }
        }
        if let taskArray = self.inactiveWeeklyTaskList {
            for task in taskArray {
                if (updateSince(updateArray: task.update, daysSince: daysSince, currentDay: currentDay)) {
                    resetTask(item: task, minusCoin: false)
                }
            }
        }
        if let taskArray = self.sleepingTaskList {
            for task in taskArray {
                if (updateSince(updateArray: task.update, daysSince: daysSince, currentDay: currentDay)) {
                    updateSleeping(item: task)
                }
            }
        }
        // VIEWS later
        updateView(currentDate: currentDate)
        
        await updateBonus()
    }
    
    func updateSleeping(item: TaskItem) {
        let newItem = TaskItem(emoji: item.emoji, name: item.name, reward: item.reward, type: item.type, count_goal: item.count_goal, count_cur: 0, update: item.update, view: item.view)
        try? updateTaskItemInFirestore(oldItem: item, newItem: newItem)
        if var list = self.sleepingTaskList {
            list.removeAll{ $0 == item }
            list.append(newItem)
            self.sleepingTaskList = list
        }
        
    }
    
    func updateView(currentDate: Date) {
        let currentDay = getDay(date: currentDate)

        // setting up new lists
        var newActiveDailyTaskList : [TaskItem] = []
        var newActiveWeeklyTaskList : [TaskItem] = []
        var newInactiveWeeklyTaskList : [TaskItem] = []
        var newSleepingTaskList : [TaskItem] = []
        
        if let taskArray = self.activeDailyTaskList {
            for task in taskArray {
                if (task.view[currentDay]) {
                    newActiveDailyTaskList.append(task) // show
                } else {
                    newSleepingTaskList.append(task) // don't show
                }
            }
        }
        if let taskArray = self.inactiveDailyTaskList {
            for task in taskArray {
                if (task.view[currentDay]) {
                    newActiveDailyTaskList.append(task) // show
                } else {
                    newSleepingTaskList.append(task) // don't show
                }
            }
        }
        // weekly
        if let taskArray = self.activeWeeklyTaskList {
            for task in taskArray {
                if (task.view[currentDay]) {
                    newActiveWeeklyTaskList.append(task)
                } else {
                    newSleepingTaskList.append(task)
                }
            }
        }
        if let taskArray = self.inactiveWeeklyTaskList {
            for task in taskArray {
                if (task.view[currentDay]) {
                    newInactiveWeeklyTaskList.append(task)
                } else {
                    newSleepingTaskList.append(task)
                }
            }
        }
        // sleeping
        if let taskArray = self.sleepingTaskList {
            for task in taskArray {
                if (task.view[currentDay]) {
                    if (task.type == "daily") {
                        newActiveDailyTaskList.append(task)
                    } else if (task.type == "weekly") {
                        if (task.count_cur == task.count_goal) {
                            newInactiveWeeklyTaskList.append(task)
                        } else {
                            newActiveWeeklyTaskList.append(task)
                        }
                    }
                } else {
                    newSleepingTaskList.append(task)
                }
            }
        }
        // setting everything back
        DispatchQueue.main.async {
            self.activeDailyTaskList = newActiveDailyTaskList.sorted{ $0.name < $1.name }
            self.activeWeeklyTaskList = newActiveWeeklyTaskList.sorted{ $0.name < $1.name }
            self.inactiveWeeklyTaskList = newInactiveWeeklyTaskList.sorted{ $0.name < $1.name }
            self.sleepingTaskList = newSleepingTaskList
        }
    }
    
    func updateBonus() async {
        self.bonusStatus = true
        // TODO: check error
        do {
            let userTaskDocRef = self.db.collection("user_tasks").document(self.uid)
            Task {
                try await userTaskDocRef.updateData([
                    "bonus_status": true
                ])
            }
            let bonusId = getBonusId()
            let bonusDocRef = self.db.collection("bonus_tasks").document(bonusId)
            await bonusDocRef.getDocument { (doc, error) in
                if let doc = doc, doc.exists {
                    let bonusEmoji = doc.get("emoji") as? String ?? "❌"
                    let bonusName = doc.get("name") as? String ?? "Error"
                    print("successfully in bonus doc!, \(bonusEmoji) \(bonusName)")
                    let bonus = TaskItem(emoji: bonusEmoji, name: bonusName, reward: 10, type: "bonus", count_goal: 1, count_cur: 0, update: [false, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
                    self.activeBonusTaskList = [bonus]
                    self.inactiveBonusTaskList = []
                } else {
                    print("DEBUG: fetch bonus task failed, \(error?.localizedDescription)")
                    self.activeBonusTaskList = []
                    self.inactiveBonusTaskList = []
                }
            }
            print("also need to update bonus")
        } catch let error {
            print("DEBUG: update bonus fail to get user_tasks, \(error.localizedDescription)")
            return
        }
    }
    
    func getDay(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        var rtn = (components.weekday ?? 1) - 1
        if (calendar.component(.hour, from: date) < 4) {
            rtn = (rtn + 6) % 7
        }
        return rtn
    }

    func currentLocalTime() -> Date {
        let currentDate = Date()
        let localTimeZone = TimeZone.current
        return currentDate.addingTimeInterval(TimeInterval(localTimeZone.secondsFromGMT(for: currentDate)))
    }
    
    func getBonusId() -> String {
        let currentDate = Date()
        print("cur date is \(currentDate)!?!?!?")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: currentDate)
    }
    
    func last4AM(date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "GMT")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        // Set the time components to 4am
        var targetComponents = DateComponents()
        targetComponents.year = components.year
        targetComponents.month = components.month
        targetComponents.day = components.day
        targetComponents.hour = 4
        targetComponents.minute = 0
        targetComponents.second = 0

        // Check if the given date is already after 4am
        if let targetDate = calendar.date(from: targetComponents) {
            print("date: \(date), target date: \(targetDate)")
            if (date > targetDate) {
                return targetDate
            }
            //return targetDate
        }

        // If the given date is before 4am, subtract one day and set the time to 4am
        if let adjustedDate = calendar.date(byAdding: .day, value: -1, to: date) {
            print("date: \(date), adjusted date: \(adjustedDate)")
            return calendar.date(bySettingHour: 4, minute: 0, second: 0, of: adjustedDate) ?? date
        }

        return date
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
            "bonus_status": true, // Replace with the desired boolean value
            "task_item_list": taskIdArray
        ]) { error in
            if let error = error {
                print("DEBUG: Error adding user tasks doc: \(error)")
            }
        }
        let bonusId = getBonusId()
        let bonusDocRef = self.db.collection("bonus_tasks").document(bonusId)
        await bonusDocRef.getDocument { (doc, error) in
            if let doc = doc, doc.exists {
                let bonusEmoji = doc.get("emoji") as? String ?? "❌"
                let bonusName = doc.get("name") as? String ?? "Error"
                print("successfully in bonus doc!, \(bonusEmoji) \(bonusName)")
                let bonus = TaskItem(emoji: bonusEmoji, name: bonusName, reward: 10, type: "bonus", count_goal: 1, count_cur: 0, update: [false, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
                self.activeBonusTaskList = [bonus]
                self.inactiveBonusTaskList = []
            } else {
                print("DEBUG: fetch bonus task failed, \(error?.localizedDescription)")
                self.activeBonusTaskList = []
                self.inactiveBonusTaskList = []
            }
        }
        DispatchQueue.main.async {
            self.activeOnceTaskList = [TaskItem.DEFAULT_ONCE_TASK]
            self.activeDailyTaskList = [TaskItem.DEFAULT_DAILY_TASK]
            self.activeWeeklyTaskList = [TaskItem.DEFAULT_WEEKLY_TASK]
            self.inactiveBonusTaskList = []
            self.inactiveDailyTaskList = []
            self.inactiveWeeklyTaskList = []
            AuthViewModel.shared.loadingDone()
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
                    // Bonus task
                    let bonusId = self.getBonusId()
                    print("bonus id is \(bonusId)")
                    let bonusDocRef = self.db.collection("bonus_tasks").document(bonusId)
                    bonusDocRef.getDocument { (doc, error) in
                        if let error = error {
                            print("DEBUG: fetch bonus task failed, \(error.localizedDescription)")
                            self.activeBonusTaskList = []
                            self.inactiveBonusTaskList = []
                            self.bonusStatus = true
                        } else if let doc = doc, doc.exists {
                            let bonusStatus = document.get("bonus_status") as? Bool
                            self.bonusStatus = bonusStatus ?? true
                            let bonusEmoji = doc.get("emoji") as? String ?? "❌"
                            let bonusName = doc.get("name") as? String ?? "Error"
                            print("successfully in bonus doc!, \(bonusEmoji) \(bonusName)")
                            let bonus = TaskItem(emoji: bonusEmoji, name: bonusName, reward: 10, type: "bonus", count_goal: 1, count_cur: 0, update: [false, false, false, false, false, false, false], view: [true, true, true, true, true, true, true])
                            if (bonusStatus ?? true) {
                                self.activeBonusTaskList = [bonus]
                                self.inactiveBonusTaskList = []
                            } else {
                                self.activeBonusTaskList = []
                                self.inactiveBonusTaskList = [bonus]
                            }
                        }
                    }
                    
                    // Once, Daily, Weekly tasks
                    let taskIdList = document.get("task_item_list") as? [String]
                    let currentDay = self.getDay(date: self.currentLocalTime())
                    var newActiveOnceList: [TaskItem] = []
                    var newActiveDailyList: [TaskItem] = []
                    var newActiveWeeklyList: [TaskItem] = []
                    var newInactiveDailyList: [TaskItem] = []
                    var newInactiveWeeklyList: [TaskItem] = []
                    var progress = 0
                    var progress_goal = taskIdList?.count ?? 0
                    for taskItemId in taskIdList ?? [] {
                        let taskItemDocRef = self.db.collection("task_items").document(taskItemId)
                        taskItemDocRef.getDocument { (doc, error) in
                            if let error = error {
                                progress += 1
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
                                if (!itemView[currentDay]) {
                                    self.sleepingTaskList?.append(item)
                                } else if (itemCountCur == itemCountGoal) { // INACTIVE
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
                                progress += 1
                            } else {
                                progress += 1
                                print("DEBUG: fetch task item doesn't exist, id: \(taskItemId), delete taskId from user_tasks!")
                                Task {
                                    do {
                                        try await docRef.updateData([
                                            "task_item_list": FieldValue.arrayRemove([taskItemId])
                                        ])
                                    } catch {
                                        print("DEBUG: error removing task item from user tasks list, \(error.localizedDescription)")
                                    }
                                }
                            }
                            if (progress == progress_goal) {
                                print("finish loading! \(progress)/\(progress_goal)")
                                AuthViewModel.shared.loadingDone()
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
    
    // TODO: manage inactive when adding new task items
    func addTask(item: TaskItem) async {
        // add locally
        let currentDay = getDay(date: currentLocalTime())
        DispatchQueue.main.async {
            if (!item.view[currentDay]) {
                self.sleepingTaskList?.append(item)
            } else if (item.type == "once") {
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
    
    func resetBonus(item: TaskItem) {
        print("reset bonus!")
        self.activeBonusTaskList = [item]
        self.inactiveBonusTaskList = []
        self.bonusStatus = true
        let userTaskDocRef = db.collection("user_tasks").document(self.uid)
        CoinManager.shared.minusCoins(n: item.reward)
        Task {
            try await userTaskDocRef.updateData([
                "bonus_status": true
            ])
        }
    }
    
    func completeBonus(item: TaskItem) {
        self.activeBonusTaskList = []
        self.inactiveBonusTaskList = [item]
        self.bonusStatus = false
        let userTaskDocRef = db.collection("user_tasks").document(self.uid)
        CoinManager.shared.addCoins(n: item.reward)
        Task {
            try await userTaskDocRef.updateData([
                "bonus_status": false
            ])
        }
    }
    
    // count_cur + 1
    func completeTask(item: TaskItem) {
        if (item.type == "bonus") {
            completeBonus(item: item)
            return
        }
        let newItem = TaskItem(emoji: item.emoji, name: item.name, reward: item.reward, type: item.type, count_goal: item.count_goal, count_cur: item.count_cur + 1, update: item.update, view: item.view)
        print("newItem: \(newItem)")
        CoinManager.shared.addCoins(n: item.reward)
        try? updateTaskItemInFirestore(oldItem: item, newItem: newItem)
        updateListEntry(oldItem: item, newItem: newItem)
    }
    
    // count_cur = 0
    func resetTask(item: TaskItem, minusCoin: Bool) {
        if (item.type == "bonus") {
            print("reset bonus task plzplzplz")
            resetBonus(item: item)
            return
        }
        if (item.count_cur == 0) {
            return
        }
        print("reset task!! \(item.name)")
        let newItem = TaskItem(emoji: item.emoji, name: item.name, reward: item.reward, type: item.type, count_goal: item.count_goal, count_cur: 0, update: item.update, view: item.view)
        if minusCoin {
            CoinManager.shared.minusCoins(n: item.reward * item.count_cur)
        }
        try? updateTaskItemInFirestore(oldItem: item, newItem: newItem)
        updateListEntry(oldItem: item, newItem: newItem)
    }
    
    func deleteTask(item: TaskItem) async {
        print("delete \(item.name)")
        // 1. update locally
        if (item.count_cur == item.count_goal) {
            // inactive list
            if (item.type == "daily") {
                self.inactiveDailyTaskList?.removeAll{ $0 == item }
            } else if (item.type == "weekly") {
                self.inactiveWeeklyTaskList?.removeAll{ $0 == item }
            }
        } else {
            // active list
            if (item.type == "once") {
                self.activeOnceTaskList?.removeAll{ $0 == item }
            } else if (item.type == "daily") {
                self.activeDailyTaskList?.removeAll{ $0 == item }
            } else if (item.type == "weekly") {
                self.activeWeeklyTaskList?.removeAll{ $0 == item }
            }
        }
        // 2. update task_items
        let itemId = itemNameToId[item.name]
        print("delete item id \(itemId)")
        let docRef = db.collection("task_items").document(itemId ?? "")
        docRef.delete { error in
            if let error = error {
                print("DEBUG: error deleting task item, \(error)")
            }
        }
        // 3. update user_tasks
        let userTasksDocRef = db.collection("user_tasks").document(self.uid)
        do {
            try await userTasksDocRef.updateData([
                "task_item_list": FieldValue.arrayRemove([itemId])
            ])
        } catch {
            print("DEBUG: error removing task item from user tasks list, \(error.localizedDescription)")
        }
    }
    
    // TODO: ? add a bunch of dispatch queue main async's
    func updateListEntry(oldItem: TaskItem, newItem: TaskItem) {
        print("trying to update list entry")
        if (newItem.count_cur == newItem.count_goal) {
            // complete
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
            // add progress
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
    
    func printDebug() {
        print("---------------")
        print("active list:")
        print("\(self.activeBonusTaskList) \(self.activeOnceTaskList) \(self.activeDailyTaskList) \(self.activeWeeklyTaskList)")
        print("inactive list:")
        print("\(self.inactiveBonusTaskList) \(self.inactiveDailyTaskList) \(self.inactiveWeeklyTaskList)")
        print("sleeping list:")
        print("\(self.sleepingTaskList)")
        print("---------------")
    }
}
