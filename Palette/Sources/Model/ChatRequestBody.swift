//
//  ChatRequestBody.swift
//  Palette
//
//  Created by 4rNe5 on 10/12/24.
//


struct ChatRequestBody: Encodable {
    let data: ChatRequestData
}

struct ChatRequestData: Encodable {
    let type: String
    let choiceId: String?
    let input: String?
    let choice: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case type, choiceId, input, choice
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(choiceId, forKey: .choiceId)
        try container.encodeIfPresent(input, forKey: .input)
        try container.encodeIfPresent(choice, forKey: .choice)
    }
}