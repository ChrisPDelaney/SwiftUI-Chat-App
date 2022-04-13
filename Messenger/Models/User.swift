//
//  User.swift
//  Messenger
//
//  Created by JP Mancini on 4/6/22.
//

import Foundation

struct User: Hashable, Codable {
    let name: String
    let friends: [String]
}
