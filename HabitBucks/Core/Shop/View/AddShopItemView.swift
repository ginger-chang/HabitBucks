//
//  AddShopItemView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/6/23.
//

import SwiftUI

struct AddShopItemView: View {
    @EnvironmentObject var shopViewModel: ShopViewModel
    @Environment(\.dismiss) var dismiss
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
                .onChange(of: emoji) { newValue in
                    // Limit to one character
                    if newValue.count > 1 {
                        emoji = String(newValue.prefix(1))
                    }
                }
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
                let newItem = ShopItem(name: self.name, price: Int(self.price) ?? 0, emoji: self.emoji, createdTime: Date())
                Task {
                    await shopViewModel.addShopItem(item: newItem)
                }
                dismiss()
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
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            
            Spacer()
        }
    }
}

extension AddShopItemView: ShopItemFormProtocol {
    var formIsValid: Bool {
        return emoji.count == 1
        && !name.isEmpty
        && !shopViewModel.itemNameToId.keys.contains(name)
        && !price.isEmpty
    }
}

struct AddShopItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddShopItemView()
            .environmentObject(ShopViewModel())
    }
}
