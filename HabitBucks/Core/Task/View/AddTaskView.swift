//
//  AddTaskView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var reward = ""
    @State private var emoji = ""
    @State private var count_goal = ""
    @State private var update = [false, false, false, false, false, false, false]
    @State private var view = [false, false, false, false, false, false, false]
    @State private var recurrence: String = ""
    let allFalse = [false, false, false, false, false, false, false]
    let allTrue = [true, true, true, true, true, true, true]
    let sundayTrue = [true, false, false, false, false, false, false]
    let mondayTrue = [false, true, false, false, false, false, false]
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("Add Task Item")
                    .font(.system(size: 27))
                Spacer()
            }
            .padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    InputView(
                        text: $emoji,
                        title: "Emoji",
                        placeholder: "⌛️")
                    InputView(
                        text: $name,
                        title: "Name",
                        placeholder: "30 minute study session")
                    NumberInputView(
                        text: $reward, // convert this to int later
                        title: "Reward",
                        placeholder: "20")
                    NumberInputView(
                        text: $count_goal, // convert this to int later
                        title: "Count",
                        placeholder: "5")
                    Text("Recurrence Settings") // no recurrence, daily, custom
                        .fontWeight(.semibold)
                    VStack(alignment: .leading, spacing: 10) {
                        RadioButton(label: "No recurrence", groupBinding: $recurrence, value: "once")
                        RadioButton(label: "Daily", groupBinding: $recurrence, value: "daily")
                        RadioButton(label: "Weekly (Start on Sunday)", groupBinding: $recurrence, value: "weekly0")
                        RadioButton(label: "Weekly (Start on Monday)", groupBinding: $recurrence, value: "weekly1")
                        RadioButton(label: "Custom", groupBinding: $recurrence, value: "weekly")
                    }
                    if (recurrence == "weekly") {
                        DayInputView(
                            selectedDays: $update,
                            title: "Update on")
                        DayInputView(
                            selectedDays: $view,
                            title: "View on")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                Button {
                    var newItem: TaskItem
                    if (recurrence == "once") {
                        newItem = TaskItem(emoji: self.emoji, name: self.name, reward: Int(self.reward) ?? 0, type: "once", count_goal: Int(self.count_goal) ?? 1, count_cur: 0, update: self.allFalse, view: self.allTrue)
                    } else if (recurrence == "daily") {
                        newItem = TaskItem(emoji: self.emoji, name: self.name, reward: Int(self.reward) ?? 0, type: "daily", count_goal: Int(self.count_goal) ?? 1, count_cur: 0, update: self.allTrue, view: self.allTrue)
                    } else if (recurrence == "weekly0") {
                        newItem = TaskItem(emoji: self.emoji, name: self.name, reward: Int(self.reward) ?? 0, type: "weekly", count_goal: Int(self.count_goal) ?? 1, count_cur: 0, update: self.sundayTrue, view: self.allTrue)
                    } else if (recurrence == "weekly1") {
                        newItem = TaskItem(emoji: self.emoji, name: self.name, reward: Int(self.reward) ?? 0, type: "weekly", count_goal: Int(self.count_goal) ?? 1, count_cur: 0, update: self.mondayTrue, view: self.allTrue)
                    } else { // custom
                        if (self.update == self.allTrue) {
                            // update is all true, store as daily
                            newItem = TaskItem(emoji: self.emoji, name: self.name, reward: Int(self.reward) ?? 0, type: "daily", count_goal: Int(self.count_goal) ?? 1, count_cur: 0, update: self.update, view: self.view)
                        } else {
                            // store as weekly
                            newItem = TaskItem(emoji: self.emoji, name: self.name, reward: Int(self.reward) ?? 0, type: "weekly", count_goal: Int(self.count_goal) ?? 1, count_cur: 0, update: self.update, view: self.view)
                        }
                    }
                    Task {
                        print("add new item~ \(newItem)")
                    }
                    dismiss()
                } label: {
                    HStack {
                        Text("SAVE")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top)
            }
            .navigationBarTitle("Your Title", displayMode: .inline)
            Spacer()
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(TaskViewModel())
    }
}
