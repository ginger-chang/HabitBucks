//
//  TaskView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/5/23.
//

import SwiftUI

struct TaskView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var taskViewModel: TaskViewModel
    var activeTaskList = (TaskViewModel.shared.activeBonusTaskList ?? []) + (TaskViewModel.shared.activeOnceTaskList ?? []) + (TaskViewModel.shared.activeDailyTaskList ?? []) + (TaskViewModel.shared.activeWeeklyTaskList ?? [])
    var inactiveTaskList = (TaskViewModel.shared.inactiveBonusTaskList ?? []) + (TaskViewModel.shared.inactiveDailyTaskList ?? []) + (TaskViewModel.shared.inactiveWeeklyTaskList ?? [])
    
    var body: some View {
        NavigationView {
            VStack {
                // heading (text + plus sign)
                HStack(spacing: 4) {
                    Text("Tasks")
                        .font(.system(size: 27))
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    Text("\(coinManager.coins)")
                        .padding(.top, 4)
                    Spacer()
                    NavigationLink {
                        AddTaskView()
                    } label: {
                        Image(systemName: "plus.square")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                    /*
                    Button {
                        TaskViewModel.shared.printDebug()
                    } label: {
                        Text("DEBUG")
                    }
                    Button {
                        TaskViewModel.shared.resetLastUpdate()
                    } label: {
                        Text("resetLastU")
                    }
                    */
                }
                .padding(.horizontal)
                .onAppear {
                    TaskViewModel.shared.checkUpdate()
                }
                
                // MARK: activeTaskList
                
                    ScrollView {
                        LazyVStack(alignment: .center, spacing: 10) {
                            TaskListView(taskItemList: TaskViewModel.shared.activeBonusTaskList)
                            TaskListView(taskItemList: TaskViewModel.shared.activeOnceTaskList)
                            TaskListView(taskItemList: TaskViewModel.shared.activeDailyTaskList)
                            TaskListView(taskItemList: TaskViewModel.shared.activeWeeklyTaskList)
                            TaskListView(taskItemList: TaskViewModel.shared.inactiveBonusTaskList)
                            TaskListView(taskItemList: TaskViewModel.shared.inactiveDailyTaskList)
                            TaskListView(taskItemList: TaskViewModel.shared.inactiveWeeklyTaskList)
                        }
                        .padding()
                    }
                    .refreshable {
                        TaskViewModel.shared.checkUpdate()
                    }
                
                
            }
            .padding(.top, 15)
        }
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
            .environmentObject(AuthViewModel())
            .environmentObject(CoinManager())
            .environmentObject(TaskViewModel())
    }
}
