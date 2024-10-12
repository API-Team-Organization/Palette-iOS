//
//  ChatHistoryResponse.swift
//  Palette
//
//  Created by 4rNe5 on 7/11/24.
//

import Foundation

struct ChatHistoryResponse: Codable {
    let code: Int
    let message: String
    let data: [ChatMessageModel]
}
