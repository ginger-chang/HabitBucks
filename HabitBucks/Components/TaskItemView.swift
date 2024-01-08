//
//  TaskItemView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
//

import SwiftUI

struct TaskItemView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    let item: TaskItem
    var mainColor: Color {
        if item.count_cur == item.count_goal || (item.type == "bonus" && !taskViewModel.bonusStatus){
            return Color(.systemGray)
        } else if item.type == "daily" {
            return Color(.systemCyan)
        } else if item.type == "once" {
            return Color(.systemYellow)
        } else if item.type == "bonus" {
            return Color(.systemPurple)
        } else {
            return Color(.systemGreen)
        }
    }
    var completeButtonImage: String {
        if item.count_goal == 1 {
            return "checkmark"
        } else {
            return "plus"
        }
    }
    var completeButtonActive: Bool {
        if (item.count_cur == item.count_goal || (item.type == "bonus" && !taskViewModel.bonusStatus)) {
            return false
        }
        return true
    }
    var countText: String {
        if item.count_goal == 1 {
            return ""
        } else {
            return "(\(item.count_cur)/\(item.count_goal))"
        }
    }
    var rewardCountText: String {
        if item.count_goal == 1 {
            return ""
        } else {
            return "/click"
        }
    }
    var progressValue: Float {
        return Float(item.count_cur) / Float(item.count_goal)
    }
    var contextMenuActive: Bool {
        return item.type != "bonus"
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Main "button"
            HStack(alignment: .center, spacing: 10) {
                Text(item.emoji)
                    //.foregroundColor(.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 40))
                    .padding(.leading, 8)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(item.name) \(countText)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)
                            .lineLimit(2)
                            .truncationMode(.tail)
                        HStack(spacing: 3) {
                            Text("Reward: ")
                            Image(systemName: "dollarsign.circle.fill")
                                .imageScale(.medium)
                                .foregroundColor(.blue)
                            Text("\(item.reward) \(rewardCountText)")
                                .font(.subheadline)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.5, alignment: .leading)
                    .padding(.vertical)
                    Spacer()
                    Button {
                        TaskViewModel.shared.completeTask(item: item)
                        print("complete task item \(item.name)")
                    } label: {
                        VStack {
                            Image(systemName: completeButtonImage)
                                .frame(width: UIScreen.main.bounds.width * 0.18, height: 104)
                                .foregroundColor(.white)
                                .scaleEffect(1.7)
                                .background(mainColor)
                        }
                    }
                    .disabled(!completeButtonActive)
                }
            }
            // progress bar
            Rectangle()
                .frame(width: CGFloat(progressValue) * UIScreen.main.bounds.width * 0.72, height: 5)
                .foregroundColor(mainColor)
        }
        
        // button presentation
        //.padding(.vertical)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(mainColor.opacity(0.5))
        .cornerRadius(10)
       
        // context menu for edit & delete
        .contextMenu {
            Button("Reset") {
                TaskViewModel.shared.resetTask(item: item, minusCoin: true)
            }
            if (contextMenuActive) {
                Button("Delete") {
                    Task {
                        await TaskViewModel.shared.deleteTask(item: item)
                    }
                }
            }
        }
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskItemView(item: TaskItem.BONUS_1)
            .environmentObject(TaskViewModel())
    }
}
