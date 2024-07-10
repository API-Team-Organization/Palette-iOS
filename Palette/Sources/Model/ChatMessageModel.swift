//
//  ChatMessageModel.swift
//  Palette
//
//  Created by 4rNe5 on 7/10/24.
//

import Foundation

enum DataType: String {
    case CHAT
    case IMAGE
}

struct ChatMessageModel: Identifiable {
    let id: Int
    let message: String
    let datetime: Date
    let roomId: Int
    let userId: Int
    let isAi: Bool
    let resource: DataType
}
