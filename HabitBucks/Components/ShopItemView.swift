//
//  ShopItemView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/4/23.
//

import SwiftUI

struct ShopItemView: View {
    let name: String
    let price: Int
    let emoji: String
    
    var body: some View {
        // TODO: put this inside a button & add button logic in viewmodel
        HStack(alignment: .center, spacing: 12) {
            Text(emoji)
                //.foregroundColor(.white)
                .fontWeight(.semibold)
                .font(.system(size: 38))
                
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: UIScreen.main.bounds.width * 0.3, alignment: .leading)
                HStack(spacing: 3) {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.blue)
                    Text("\(price)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
            }
        }
        //.background(Color(.systemGray4))
        //.cornerRadius(10)
    }
}

struct ShopItemView_Previews: PreviewProvider {
    static var previews: some View {
        ShopItemView(name: "Game time for 20 min.", price: 10, emoji: "🎮")
    }
}
