//
//  ShopView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/4/23.
//

import SwiftUI

struct ShopView: View {
    let shopItemList = [ShopItem.MOCK_SHOP_ITEM_1, ShopItem.MOCK_SHOP_ITEM_2, ShopItem.MOCK_SHOP_ITEM_3, ShopItem.MOCK_SHOP_ITEM_4, ShopItem.MOCK_SHOP_ITEM_5, ShopItem.MOCK_SHOP_ITEM_6, ShopItem.MOCK_SHOP_ITEM_7]
    
    var body: some View {
        VStack {
            // heading (text + plus sign)
            HStack {
                Text("Shop")
                    .font(.system(size: 27))
                Spacer()
                Button {
                    print("add new shop item")
                } label: {
                    Image(systemName: "plus.square")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
            }
            .padding(.horizontal)
            
            // MARK: shop item list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(0..<shopItemList.count, id: \.self) { index in
                        if index % 2 == 0 {
                            HStack {
                                ShopItemView(item: shopItemList[index])
                                Spacer()
                                if index + 1 < shopItemList.count {
                                    ShopItemView(item: shopItemList[index + 1])
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            
            
            Spacer()
            
            // (bottom nav bar?)
            Text("...navbar...")
        }
        
        
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
    }
}
