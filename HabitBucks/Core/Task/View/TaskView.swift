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
    let activeTaskList = (TaskViewModel.shared.activeBonusTaskList ?? []) + (TaskViewModel.shared.activeOnceTaskList ?? []) + (TaskViewModel.shared.activeDailyTaskList ?? []) + (TaskViewModel.shared.activeWeeklyTaskList ?? [])
    
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
                }
                .padding(.horizontal)
                
                // MARK: activeTaskList
                
                    ScrollView {
                        LazyVStack(alignment: .center, spacing: 10) {
                            ForEach(0..<activeTaskList.count, id: \.self) { index in
                                HStack {
                                    TaskItemView(item: activeTaskList[index])
                                }
                            }
                        }
                        .padding()
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
