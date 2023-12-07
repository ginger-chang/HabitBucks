//
//  ShopView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/4/23.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var coinManager: CoinManager
    @EnvironmentObject var shopViewModel: ShopViewModel
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                // heading (text + plus sign)
                HStack(spacing: 4) {
                    Text("Shop")
                        .font(.system(size: 27))
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    Text("\(coinManager.coins)")
                        .padding(.top, 4)
                    Spacer()
                    NavigationLink {
                        AddShopItemView()
                    } label: {
                        Image(systemName: "plus.square")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
                .padding(.horizontal)
                
                // MARK: shop item list
                if let shopItemList = shopViewModel.shopItemList {
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
                    // alert when clicking button
                    .alert(isPresented: $shopViewModel.showAlert) {
                        if shopViewModel.sufficientAlert {
                            return shopViewModel.constructSufficientAlert()
                        } else if shopViewModel.insufficientAlert {
                            return shopViewModel.constructInsufficientAlert()
                        } else {
                            return Alert(title: Text(""))
                        }
                    }
                }
                
                
            }
            .padding(.top, 15)
        }

    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
            .environmentObject(CoinManager())
            .environmentObject(ShopViewModel())
    }
}
