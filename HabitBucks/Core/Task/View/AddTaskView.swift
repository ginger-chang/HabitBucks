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

    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("Add Task Item")
                    .font(.system(size: 27))
                Spacer()
            }
            .padding(.horizontal)
            ScrollView {
                VStack(spacing: 24) {
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
                    DayInputView(
                        selectedDays: $update,
                        title: "Update on")
                    DayInputView(
                        selectedDays: $view,
                        title: "View on")
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Button {
                    // let newItem = TaskItem()
                    Task {
                        print("add new item~ ")
                        print("update is \(update)")
                        print("view is \(view)")
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
                
                Spacer()
            }
            
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
            .environmentObject(TaskViewModel())
    }
}
