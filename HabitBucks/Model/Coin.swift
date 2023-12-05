//
//  Coin.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/4/23.
//

import Foundation

struct Coin: Codable {
    let total_coins: Int
}

extension Coin {
    static var MOCK_COIN = Coin(total_coins: 888)
}
