//
//  AddShopItemView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
//

import SwiftUI

struct AddShopItemView: View {
    @State private var name = ""
    @State private var price = ""
    @State private var emoji = ""
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("Add Shop Item")
                    .font(.system(size: 27))
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 24) {
                InputView(
                    text: $emoji,
                    title: "Emoji",
                    placeholder: "🍿")
                InputView(
                    text: $name,
                    title: "Name",
                    placeholder: "Movie Night")
                NumberInputView(
                    text: $price, // convert this to int later
                    title: "Price",
                    placeholder: "20")
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button {
                print("add item")
            } label: {
                HStack {
                    Text("SAVE")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .cornerRadius(10)
            .padding(.top)
            
            Spacer()
        }
    }
}

struct AddShopItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddShopItemView()
    }
}
