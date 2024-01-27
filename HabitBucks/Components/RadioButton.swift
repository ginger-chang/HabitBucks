//
//  RadioButton.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/18/23.
//

import SwiftUI

struct RadioButton: View {
    var label: LocalizedStringKey
    var groupBinding: Binding<String>
    var value: String

    var body: some View {
        Button(action: {
            groupBinding.wrappedValue = value
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: groupBinding.wrappedValue == value ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(groupBinding.wrappedValue == value ? .blue : .gray)
                    .imageScale(.medium)
                Text(label)
                    .foregroundColor(Color(.darkGray))
                    .fontWeight(.semibold)
                    .font(.footnote)
                    
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RadioButton_Previews: PreviewProvider {
    static var previews: some View {
        RadioButton(label: "Name", groupBinding: .constant(""), value: "")
    }
}
