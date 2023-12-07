//
//  TaskItemView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
//

import SwiftUI

struct TaskItemView: View {
    let item: TaskItem
    var mainColor: Color {
        if item.type == "bonus" {
            return Color(.systemPurple)
        } else if item.type == "daily" {
            return Color(.systemCyan)
        } else if item.type == "once" {
            return Color(.systemYellow)
        } else {
            return Color(.systemGreen)
        }
    }
    var barColor: Color {
        if item.type == "bonus" {
            return Color(.purple)
        } else if item.type == "daily" {
            return Color(.cyan)
        } else if item.type == "once" {
            return Color(.yellow)
        } else {
            return Color(.green)
        }
    }
    var completeButtonImage: String {
        if item.count_goal == 1 {
            return "checkmark"
        } else {
            return "plus"
        }
    }
    var countText: String {
        if item.count_goal == 1 {
            return ""
        } else {
            return "(\(item.count_cur)/\(item.count_goal))"
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
                    .padding(.leading, 5)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(item.name) \(countText)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(width: UIScreen.main.bounds.width * 0.53, alignment: .leading)
                        HStack(spacing: 3) {
                            Text("Reward: ")
                            Image(systemName: "dollarsign.circle.fill")
                                .imageScale(.medium)
                                .foregroundColor(.blue)
                            Text("\(item.reward)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical)
                    Spacer()
                    Button {
                        print("complete task item \(item.name)")
                    } label: {
                        VStack {
                            Image(systemName: completeButtonImage)
                                .frame(width: UIScreen.main.bounds.width * 0.18, height: 100)
                                .foregroundColor(.white)
                                .scaleEffect(1.7)
                                .background(mainColor)
                        }
                    }
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
            if (contextMenuActive) {
                Button("Edit") {
                    print("Edit \(item.name)")
                }
                Button("Delete") {
                    print("Delete \(item.name)")
                }
            }
        }
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskItemView(item: TaskItem.MOCK_ONCE_TASK_1)
    }
}
