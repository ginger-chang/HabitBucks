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
                if let activeTaskList = TaskViewModel.shared.activeTaskList {
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
                
                Spacer()
                Text("task view desu~")
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
