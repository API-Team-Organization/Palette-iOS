import Foundation

struct ChatMessageModel: Codable, Identifiable {
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
        return formatter.date(from: datetime) ?? Date()
    }
}
