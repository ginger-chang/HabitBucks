//
//  ShopItem.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/4/23.
//

import Foundation
import FirebaseFirestore

struct ShopItem: Codable {
    let name: String
    let price: Int
    let emoji: String
    let createdTime: Date
    
    static func == (lhs: ShopItem, rhs: ShopItem) -> Bool {
        return lhs.name == rhs.name && lhs.price == rhs.price && lhs.emoji == rhs.emoji && lhs.createdTime == rhs.createdTime
    }
}

extension ShopItem {
    static var MOCK_SHOP_ITEM_1 = ShopItem(name: "Game Time 20 min.", price: 10, emoji: "🎮", createdTime: Date())
    static var MOCK_SHOP_ITEM_2 = ShopItem(name: "Boba Milk Tea", price: 5, emoji: "🧋", createdTime: Date())
    static var MOCK_SHOP_ITEM_3 = ShopItem(name: "Go to Cat Cafe", price: 18, emoji: "🐈", createdTime: Date())
    static var MOCK_SHOP_ITEM_4 = ShopItem(name: "Listen to Pink Floyd", price: 9, emoji: "🌈", createdTime: Date())
    static var MOCK_SHOP_ITEM_5 = ShopItem(name: "Sleep until happy", price: 11, emoji: "🛌", createdTime: Date())
    static var MOCK_SHOP_ITEM_6 = ShopItem(name: "Rock'n'roll~~~", price: 22, emoji: "🎸", createdTime: Date())
    static var MOCK_SHOP_ITEM_7 = ShopItem(name: "ijustwannasaythatthiswillbeaveryverylongstring", price: 99, emoji: "💌", createdTime: Date())
    static var DEFAULT_SHOP_ITEM_1 = ShopItem(name: "20 min. Game Time", price: 10, emoji: "🎮", createdTime: Date())
    static var DEFAULT_SHOP_ITEM_2 = ShopItem(name: "Boba Milk Tea", price: 5, emoji: "🧋", createdTime: Date())
    static var DEFAULT_SHOP_ITEM_3 = ShopItem(name: "Go to Cat Cafe", price: 18, emoji: "🐈", createdTime: Date())
}
