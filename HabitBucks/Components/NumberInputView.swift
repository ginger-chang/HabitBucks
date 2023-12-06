//
//  NumberInputView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
//

import SwiftUI

struct NumberInputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            TextField(placeholder, text: $text)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 14))
                
            
            Divider()
            
        }
    }
}

struct NumberInputView_Previews: PreviewProvider {
    static var previews: some View {
        NumberInputView(text: .constant(""), title: "Number", placeholder: "30")
    }
}
