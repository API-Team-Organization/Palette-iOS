//
//  ChatMessageResponseModel.swift
//  Palette
//
//  Created by 4rNe5 on 7/10/24.
//

import Foundation

struct ChatMessageResponseModel<T: Codable>: Codable {
    let id: Int
    let message: String
    let data: [T]
}
