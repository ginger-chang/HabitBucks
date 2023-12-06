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
    
    private var db = Firestore.firestore()
    private var uid: String
    static let shared = ShopViewModel()
    var latestShopItem: ShopItem
    
    // TODO: (?) init() function called when user is created, store default shopItem in it
    // do it like the way coin manager is set up (with another set subscription function - perhaps)
    init() {
        self.latestShopItem = ShopItem(name: "default", price: 0, emoji: "😀")
        self.shopItemList = [ShopItem.MOCK_SHOP_ITEM_1, ShopItem.MOCK_SHOP_ITEM_2, ShopItem.MOCK_SHOP_ITEM_3, ShopItem.MOCK_SHOP_ITEM_4, ShopItem.MOCK_SHOP_ITEM_5, ShopItem.MOCK_SHOP_ITEM_6, ShopItem.MOCK_SHOP_ITEM_7]
        self.uid = ""
    }
    
    // This is called only when the user creates an account & need to set up documents
    func createShop() async {
        // creating shop items
        var shopItemArray: [String] = []
        do {
            let id1 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_1)
            let id2 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_2)
            let id3 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_3)
            shopItemArray.append(id1)
            shopItemArray.append(id2)
            shopItemArray.append(id3)
        } catch {
            print("DEBUG: createShopItems failed with error \(error.localizedDescription)")
        }
        print("shopitem arr: \(shopItemArray)")
        
        // creating user shop
        guard let uid = await AuthViewModel.shared.currentUser?.id else {
            print("DEBUG: create shop doesn't get uid")
            return
        }
        db.collection("user_shop").document(uid).setData([
            "shop_item_list": shopItemArray,
        ]) { error in
            if let error = error {
                print("DEBUG: Error adding user shop document: \(error)")
            }
        }
        DispatchQueue.main.async {
            var newShopItemList: [ShopItem] = []
            newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_1)
            newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_2)
            newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_3)
            self.shopItemList = newShopItemList
        }
    }
    
    func asyncSetup() {
        
    }
    
    // gets the uid and retrieve shopItemList from firestore
    func fetchShopItemList() async {
        // get uid & user shop
        guard let uid = await AuthViewModel.shared.currentUser?.id else {
            print("DEBUG: create shop doesn't get uid")
            return
        }
        var shopItemStrArr: [String]
        /*
        let documentReference = db.collection("user_shop").document(uid)
        documentReference.getDocument { (document, error) in
            if let error = error {
                print("DEBUG: failed to fetch user shop doc with error \(error.localizedDescription)")
            } else {
                // Check if the document exists
                if let document = document, document.exists {
                    // Document exists -> update coins field (and view)
                    if let arr = document.get("shop_item_list") {
                        shopItemStrArr = arr as! [String]
                    }
                } // CHECK: do i need a if doc doesn't exist else statement?
            }
        }*/
        /*
        // get shop items
        var curShopItemList: [ShopItem]
        var shopItem: ShopItem?
        var errorShopItem = ShopItem(name: "ERROR", price: 0, emoji: "❌")
        for shopItemId in shopItemStrArr {
            guard let snapshot = try? await Firestore.firestore().collection("user_shop").document(shopItemId).getDocument() else {
                return
            }
            //shopItem = try? snapshot.data(as: ShopItem.self)
            curShopItemList.append(shopItem ?? errorShopItem)
        }
         */
        //DispatchQueue.main.async {
        //self.shopItemList = curShopItemList
        //}
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
    
    // Helper function that takes in a ShopItem, stores it in firestore, and returns the id of the document
    func storeShopItemToFirestore(item: ShopItem) async throws -> String {
        let encodedShopItem = try Firestore.Encoder().encode(item)
        let itemId = try await db.collection("shop_items").addDocument(data: encodedShopItem)
        return itemId.documentID
    }
}
