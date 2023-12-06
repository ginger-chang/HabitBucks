//
//  ShopViewModel.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/4/23.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class ShopViewModel: ObservableObject {
    //@Published var
    @Published var showAlert = false
    @Published var sufficientAlert = false
    @Published var insufficientAlert = false
    @Published var shopItemList: [ShopItem]?
    static let shared = ShopViewModel()
    var latestShopItem: ShopItem
    
    // TODO: (?) init() function called when user is created, store default shopItem in it
    // do it like the way coin manager is set up (with another set subscription function - perhaps)
    init() {
        latestShopItem = ShopItem(name: "default", price: 0, emoji: "😀")
        shopItemList = [ShopItem.MOCK_SHOP_ITEM_1, ShopItem.MOCK_SHOP_ITEM_2, ShopItem.MOCK_SHOP_ITEM_3, ShopItem.MOCK_SHOP_ITEM_4, ShopItem.MOCK_SHOP_ITEM_5, ShopItem.MOCK_SHOP_ITEM_6, ShopItem.MOCK_SHOP_ITEM_7]
    }
    
    func asyncSetup() {
        
    }
    
    func fetchShopItemList() {
        
    }
    
    func clickBuyItem(item: ShopItem) {
        let curCoins = CoinManager.shared.coins
        let price = item.price
        latestShopItem = item
        if (curCoins >= price) {
            showAlert = true
            sufficientAlert = true
            insufficientAlert = false
            print("confirm alert is true, \(sufficientAlert), \(insufficientAlert)")
        } else {
            showAlert = true
            insufficientAlert = true
            sufficientAlert = false
            print("insufficient alert is true, \(sufficientAlert), \(insufficientAlert)")
        }
    }
    
    func buyItem(item: ShopItem) {
        print("buy item called price = \(item.price) name = \(item.name)")
        CoinManager.shared.minusCoins(n: item.price)
    }
 
    // TODO: addShopItem() function to add another shopItem to the database & update view
    
    // TODO: editShopItem()
    
    // TODO: deleteShopItem()
    
    // helper alert construction functions
    func constructSufficientAlert() -> Alert {
        return Alert(
            title: Text("Confirm Purchase"),
            message: Text("Do you want to buy this item?"),
            primaryButton: .default(Text("Yes"), action: {
                self.buyItem(item: self.latestShopItem)
            }),
            secondaryButton: .cancel(Text("No"))
        )
    }
    
    func constructInsufficientAlert() -> Alert {
        return Alert(
            title: Text("Insufficient Coins"),
            message: Text("You don't have enough coins to make this purchase."),
            dismissButton: .default(Text("OK"))
        )
    }
}
