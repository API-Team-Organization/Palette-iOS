//
//  QnAResponseModel.swift
//  Palette
//
//  Created by 4rNe5 on 10/12/24.
//

struct QnAResponseModel: Codable {
    let code: Int
    let message: String
    let data: [QnAData]
}

struct QnAData: Codable {
    let id: String
    let type: QnAType
    let question: QuestionDto
    let answer: AnswerDto
    let promptName: String
}

enum QnAType: String, Codable {
    case SELECTABLE
    case USER_INPUT
    case GRID
}

struct QuestionDto: Codable {
    let type: String
    let choices: [Choice]?
    let xSize: Int?
    let ySize: Int?
}

struct Choice: Codable, Identifiable {
    let id: String
    let displayName: String
}

struct AnswerDto: Codable {
    let type: String
    let choiceId: String?
    let input: String?
    let choice: [Int]?
}
