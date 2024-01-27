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
import Combine

protocol ShopItemFormProtocol {
    var formIsValid: Bool { get }
}

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
    private var cancellables: Set<AnyCancellable> = []
    var itemNameToId: Dictionary<String, String> = [:]
    
    // TODO: (?) init() function called when user is created, store default shopItem in it
    // do it like the way coin manager is set up (with another set subscription function - perhaps)
    init() {
        self.latestShopItem = ShopItem(name: "default", price: 0, emoji: "😀", createdTime: Date())
        self.shopItemList = [ShopItem.MOCK_SHOP_ITEM_1, ShopItem.MOCK_SHOP_ITEM_2, ShopItem.MOCK_SHOP_ITEM_3, ShopItem.MOCK_SHOP_ITEM_4, ShopItem.MOCK_SHOP_ITEM_5, ShopItem.MOCK_SHOP_ITEM_6, ShopItem.MOCK_SHOP_ITEM_7]
        self.uid = ""
    }
    
    // MARK: for localization of bonus tasks
    func currentLanguage() -> String {
        let rtn = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?[0] ?? ""
        if rtn.contains("zh-Hant") {
            return "zh-Hant"
        }
        return rtn
    }
    
    // This is called only when the user creates an account & need to set up documents
    func createShop() async {
        // creating shop items
        var shopItemArray: [String] = []
        let lang = currentLanguage()
        do {
            if (lang == "zh-Hant") {
                let id1 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_1_ct)
                let id2 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_2_ct)
                let id3 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_3_ct)
                shopItemArray.append(id1)
                shopItemArray.append(id2)
                shopItemArray.append(id3)
                itemNameToId[ShopItem.DEFAULT_SHOP_ITEM_1_ct.name] = id1
                itemNameToId[ShopItem.DEFAULT_SHOP_ITEM_2_ct.name] = id2
                itemNameToId[ShopItem.DEFAULT_SHOP_ITEM_3_ct.name] = id3
            } else {
                let id1 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_1)
                let id2 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_2)
                let id3 = try await storeShopItemToFirestore(item: ShopItem.DEFAULT_SHOP_ITEM_3)
                shopItemArray.append(id1)
                shopItemArray.append(id2)
                shopItemArray.append(id3)
                itemNameToId[ShopItem.DEFAULT_SHOP_ITEM_1.name] = id1
                itemNameToId[ShopItem.DEFAULT_SHOP_ITEM_2.name] = id2
                itemNameToId[ShopItem.DEFAULT_SHOP_ITEM_3.name] = id3
            }
        } catch {
            print("DEBUG: createShopItems failed with error \(error.localizedDescription)")
        }
        // creating user shop
        db.collection("user_shop").document(uid).setData([
            "shop_item_list": shopItemArray,
        ]) { error in
            if let error = error {
                print("DEBUG: Error adding user shop document: \(error)")
            }
        }
        DispatchQueue.main.async {
            var newShopItemList: [ShopItem] = []
            if (lang == "zh-Hant") {
                newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_1_ct)
                newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_2_ct)
                newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_3_ct)
            } else {
                newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_1)
                newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_2)
                newShopItemList.append(ShopItem.DEFAULT_SHOP_ITEM_3)
            }
            self.shopItemList = newShopItemList.sorted{ $0.createdTime < $1.createdTime }
        }
    }
    
    func asyncSetup() async {
        // setup subscription to uid
        await AuthViewModel.shared.$currentUser
            .sink { [weak self] newUser in
                self?.uid = newUser?.id ?? ""
            }
            .store(in: &cancellables)
        // check if document doesn't exist, create one
        let collection = db.collection("user_shop")
        let documentReference = collection.document(self.uid)
        documentReference.getDocument { (document, error) in
            if let error = error {
                print("DEBUG: failed to fetch user_shop doc with error \(error.localizedDescription)")
            } else {
                // Check if the document exists
                if let document = document, document.exists {
                    // Document exists -> update coins field (and view)
                    Task {
                        await self.fetchShopItemList()
                    }
                } else {
                    // Document does not exist -> create new shop
                    Task {
                        await self.createShop()
                    }
                }
            }
        }
    }
    
    // update the self.shopItemList variable based on database
    func fetchShopItemList() async {
        let docRef = self.db.collection("user_shop").document(self.uid)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("DEBUG: shop view model fetch shop item list failed \(error.localizedDescription)")
            } else if let document = document, document.exists {
                Task {
                    let shopItemStrArr = document.get("shop_item_list") as? [String]
                    var newShopItemList: [ShopItem] = []
                    for shopItemId in shopItemStrArr ?? [] {
                        let shopItemDocRef = self.db.collection("shop_items").document(shopItemId)
                        try await shopItemDocRef.getDocument { (doc, error) in
                            if let error = error {
                                print("DEBUG: fetch shop item list failed - can't get item \(error.localizedDescription)")
                            } else if let doc = doc, doc.exists {
                                let itemName = doc.get("name") as? String ?? "Error"
                                let itemPrice = doc.get("price") as? Int ?? 0
                                let itemEmoji = doc.get("emoji") as? String ?? "❌"
                                let itemCreatedTimestamp = doc.get("createdTime") as? Timestamp ?? Timestamp()
                                let itemCreatedTime = itemCreatedTimestamp.dateValue()
                                let item = ShopItem(name: itemName, price: itemPrice, emoji: itemEmoji, createdTime: itemCreatedTime)
                                newShopItemList.append(item)
                                self.itemNameToId[item.name] = shopItemId
                                self.shopItemList = newShopItemList.sorted{ $0.createdTime < $1.createdTime }
                                //print("now new shop item list is \(newShopItemList)")
                            } else {
                                print("DEBUG: fetch shop item doesn't exist")
                            }
                        }
                    }
                }
            } else {
                // Document does not exist
                print("DEBUG: fetch shop item user shop doesn't exist")
            }
        }
    }
       
    
    func clickBuyItem(item: ShopItem) {
        let curCoins = CoinManager.shared.coins
        let price = item.price
        latestShopItem = item
        if (curCoins >= price) {
            showAlert = true
            sufficientAlert = true
            insufficientAlert = false
        } else {
            showAlert = true
            insufficientAlert = true
            sufficientAlert = false
        }
    }
    
    func buyItem(item: ShopItem) {
        //print("buy item called price = \(item.price) name = \(item.name)")
        CoinManager.shared.minusCoins(n: item.price)
    }
 
    // addShopItem() function to add another shopItem to the database & update view
    func addShopItem(item: ShopItem) async {
        //print("add shop item called in shop view model \(item)")
        // 1st step: update local self.shopItemList
        if var unwrappedList = self.shopItemList {
            unwrappedList.append(item)
            shopItemList = unwrappedList.sorted{ $0.createdTime < $1.createdTime }
        } else {
            shopItemList = [item]
        }
        // 2nd step: add doc in shop_items
        do {
            let itemId = try await storeShopItemToFirestore(item: item)
            itemNameToId[item.name] = itemId
            // 3rd step: append the new shop item id to user_shop
            let docRef = self.db.collection("user_shop").document(self.uid)
            try await docRef.updateData([
                "shop_item_list": FieldValue.arrayUnion([itemId])
            ])
        } catch {
            print("DEBUG: fail to update firestore when adding new shop item \(error.localizedDescription)")
        }
        
    }
    
    // TODO: editShopItem()
    // update firestore db with the new info, then fetch the item from the db, then update self.shopItemList
    
    func deleteShopItem(item: ShopItem) async {
        // 1st step: update local self.shopItemList
        shopItemList?.removeAll{ $0 == item }
        // 2nd step: get id of the shop_item from the dict
        let itemId = itemNameToId[item.name]
        let docRef = Firestore.firestore().collection("shop_items").document(itemId ?? "")
        docRef.delete { error in
            if let error = error {
                print("DEBUG: Error deleting shop item doc: \(error)")
            }
        }
        // 3rd step: remove the id from user shop doc
        let userShopDocRef = db.collection("user_shop").document(self.uid)
        do {
            try await userShopDocRef.updateData([
              "shop_item_list": FieldValue.arrayRemove([itemId])
            ])
        } catch {
            print("DEBUG: error when removing item id from user shop doc \(error.localizedDescription)")
        }
        // 4th step: remove name from itemNameToId
        itemNameToId.removeValue(forKey: item.name)
    }
    
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
