//
//  User.swift
//  HabitBucks
//
//  Created by Ginger Chang on 12/3/23.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: username) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, username: "Geeee Syrup", email: "ginger1234@gmail.com")
}
