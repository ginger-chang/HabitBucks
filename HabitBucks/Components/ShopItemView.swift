//
//  ShopItemView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/4/23.
//

import SwiftUI

struct ShopItemView: View {
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var shopViewModel: ShopViewModel
    let item: ShopItem
    
    var body: some View {
        // TODO: 3D touch for edit & delete
        
        Button {
            print("click item \(item.name)")
            shopViewModel.clickBuyItem(item: item)
        } label: {
            HStack(alignment: .center, spacing: 5) {
                Text(item.emoji)
                    //.foregroundColor(.white)
                    .fontWeight(.semibold)
                    .font(.system(size: 37))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
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
                        Text("\(item.price)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                }
            }
            // button presentation
            .frame(width: UIScreen.main.bounds.width * 0.45, height: 72)
            .background(Color(.systemGray5))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        // context menu for edit & delete
        .contextMenu {
            Button("Delete") {
                print("Delete \(item.name)")
                Task {
                    await shopViewModel.deleteShopItem(item: item)
                }
            }
        }
    }
}

struct ShopItemView_Previews: PreviewProvider {
    static var previews: some View {
        ShopItemView(item: ShopItem.MOCK_SHOP_ITEM_1)
            .environmentObject(CoinManager())
            .environmentObject(ShopViewModel())
    }
}
