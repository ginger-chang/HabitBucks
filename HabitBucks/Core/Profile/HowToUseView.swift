//
//  HowToUseView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 1/10/24.
//

import SwiftUI

struct HowToUseView: View {
    var body: some View {
        @Environment(\.dismiss) var dismiss
        
        VStack (spacing: 18) {
            Image("icon")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.top)
            Text("Turn tasks into treasures! HabitBucks: Where every completed task is a step closer to your rewards.")
                .bold()
            List {
                Section ("Summary") {
                    Text("Please ensure you have stable Internet connection so the data is being written correctly.")
                    Text("Long press/3D touch on the task/reward to show more actions.")
                    Text("All task updates happen at 4 am, pull down to refresh if you don’t see the change.")
                    Text("A general guideline: 10 coins for 30 minutes of work.")
                    Text("Purple: bonus task (built-in daily task for positivity)")
                        .listRowBackground(Color(.systemPurple).opacity(0.5))
                    Text("Yellow: one-time task")
                        .listRowBackground(Color(.systemYellow).opacity(0.5))
                    Text("Blue: daily task")
                        .listRowBackground(Color(.systemCyan).opacity(0.5))
                    Text("Green: weekly/custom task")
                        .listRowBackground(Color(.systemGreen).opacity(0.5))
                }
                Section ("Tasks / Adding a task") {
                    Text("Press the ‘+’ button on the top right corner in the Task page. If you cannot save a new task, check that you don’t already have a task with the same name.")
                    Text("Count: Set a count for the task. Notice that a reward will be given every time you made progress.")
                    Text("No recurrence: The task will stay on your task page until you’ve completed it. Once completed, it will be removed from your task page.")
                    Text("Daily: The task will be shown every day and will be updated every day at 4am.")
                    Text("Weekly: The task will be shown every day and will be updated at 4am Sunday/Monday.")
                    Text("Custom: The task will be shown on days specified with “View on” and updated on days at 4 am specified with “Updated on.” If no days are selected in “View on,” then the task will not be created.")
                }
                Section("Tasks / Resetting a task") {
                    Text("Long press/3D touch on the task to show the menu. Reset a task will clear your progress of the task and take back the coins you have earned from this task previously since the last update.")
                }
                Section("Tasks / Deleting a task") {
                    Text("Long press/3D touch on the task to show the menu. This action will erase your task and is not reversible.")
                }
                Section("Shop / Adding a reward") {
                    Text("Press the ‘+’ button on the top right corner in the Shop page. If you cannot save a new reward, check that you don’t already have a reward with the same name.")
                }
                Section("Shop / Deleting a reward") {
                    Text("Long press/3D touch on the reward to show the menu. This action will erase your reward and is not reversible.")
                }
                Section("Contact") {
                    Text("Email us at habitbucks@gmail.com if you have any questions, suggestions, or comments!")
                }
            }
            .cornerRadius(20)
        }
        .padding(.horizontal)
    }
}

struct HowToUseView_Previews: PreviewProvider {
    static var previews: some View {
        HowToUseView()
    }
}
