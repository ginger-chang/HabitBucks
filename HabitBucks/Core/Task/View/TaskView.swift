//
//  TaskView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/5/23.
//

import SwiftUI

struct TaskView: View {
    var body: some View {
        @EnvironmentObject var authViewModel: AuthViewModel
        @EnvironmentObject var coinManager: CoinManager
        
        Text("task view desu~")
        
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
            .environmentObject(AuthViewModel())
            .environmentObject(CoinManager())
    }
}
