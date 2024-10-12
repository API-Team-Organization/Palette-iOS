import Foundation

struct ChatMessageModel: Codable, Identifiable, Equatable {
    let id: String
    let message: String
    let resource: ResourceType
    let datetime: String
    let roomId: Int
    let userId: Int
    let promptId: String?
    let isAi: Bool
    
    enum ResourceType: String, Codable {
        case CHAT
        case IMAGE
        case PROMPT
    }
    enum CodingKeys: String, CodingKey {
        case id, message, resource, datetime, roomId, userId, isAi, promptId
    }
    
    var date: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.date(from: datetime) ?? Date()
    }
    
    static func ==(lhs: ChatMessageModel, rhs: ChatMessageModel) -> Bool {
        return lhs.id == rhs.id
    }
}
