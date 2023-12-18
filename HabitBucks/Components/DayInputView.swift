//
//  DayInputView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/18/23.
//

import SwiftUI

enum DayOfWeek: String, CaseIterable, Identifiable {
    case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    
    var id: String { self.rawValue }
}

struct DayInputView: View {
    @Binding var selectedDays: [Bool]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            HStack {
                ForEach(DayOfWeek.allCases.indices) { index in
                    Button(action: {
                        toggleDaySelection(index)
                    }) {
                        Text(DayOfWeek.allCases[index].rawValue.prefix(3))
                            .frame(maxWidth: .infinity)
                            .padding(5)
                            .background(selectedDays[index] ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                            .font(.footnote)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                // Handle selected days
                let selectedBools = selectedDays
            })
        }
    }
    private func toggleDaySelection(_ index: Int) {
        selectedDays[index].toggle()
    }
}

struct DayInputView_Previews: PreviewProvider {
    static var previews: some View {
        DayInputView(selectedDays: .constant([false, false, false, false, false, false, false]), title: "Title")
    }
}
