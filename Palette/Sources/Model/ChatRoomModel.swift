//
//  ChatRoomModel.swift
//  Palette
//
//  Created by 4rNe5 on 7/10/24.
//

import Foundation

struct ChatRoomModel: Identifiable, Codable {
    let id: Int
    let title: String
    let message: String?
}
