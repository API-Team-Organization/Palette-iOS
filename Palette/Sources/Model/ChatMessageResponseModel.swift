//
//  ChatMessageResponseModel.swift
//  Palette
//
//  Created by 4rNe5 on 7/10/24.
//

import Foundation

struct ChatMessageResponseModel: Codable {
    let code: Int
    let message: String
    let data: ChatMessageResponseData
}

struct ChatMessageResponseData: Codable {
    let received: [ChatMessageModel]
}

struct ChatHistoryResponse: Codable {
    let code: Int
    let message: String
    let data: [ChatMessageModel]
}
