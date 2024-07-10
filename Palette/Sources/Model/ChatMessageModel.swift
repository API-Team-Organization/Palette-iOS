import Foundation

struct ChatMessageModel: Codable, Identifiable, Equatable {
    let id: Int
    let message: String
    let datetime: String
    let roomId: Int
    let userId: Int
    let isAi: Bool
    let resource: ResourceType
    
    enum ResourceType: String, Codable {
        case CHAT
        case IMAGE
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
