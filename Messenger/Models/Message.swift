//
//  Message.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import Foundation

enum MessageType: String {
    case sent
    case received
}

struct Message: Hashable {
    let id: String
    let text: String
    let type: MessageType
    let sender: String
    let created: Date // Date
}
