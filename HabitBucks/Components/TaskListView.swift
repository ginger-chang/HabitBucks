//
//  TaskListView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/18/23.
//

import SwiftUI

struct TaskListView: View {
    let taskItemList: [TaskItem]?
    var body: some View {
        if let list = taskItemList {
            ForEach(list, id: \.id) { i in
                HStack {
                    TaskItemView(item: i)
                }
            }
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(taskItemList: nil)
    }
}
