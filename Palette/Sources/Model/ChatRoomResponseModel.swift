//
//  ChatRoomResponseModel.swift
//  Palette
//
//  Created by 4rNe5 on 7/10/24.
//

import Foundation

struct ChatRoomResponseModel<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: [T]
}
