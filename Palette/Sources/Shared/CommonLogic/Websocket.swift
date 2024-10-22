import Foundation
import Combine

class Websocket: ObservableObject {
    @Published var queuePosition: Int?
    private var webSocketTask: URLSessionWebSocketTask?
    private let roomID: Int
    private var onMessage: ((ChatMessageModel) -> ())?
    private var pingTimer: Timer?
    private var isClosed = false
    
    init(roomID: Int) {
        self.roomID = roomID
        self.connect()
    }
    
    deinit {
        close()
    }
    
    func setMessageCallback(onMessage: @escaping (ChatMessageModel) -> ()) {
        self.onMessage = onMessage
    }
    
    private func connect() {
        guard let url = URL(string: "wss://api.paletteapp.xyz/ws/\(roomID)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        let headers = getHeaders()
        headers.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        print("WebSocket connected successfully.")
        receiveMessage()
        startPingTimer()
    }
    
    private func getHeaders() -> [String: String] {
        let token: String
        if let tokenData = KeychainManager.load(key: "accessToken"),
           let tokenString = String(data: tokenData, encoding: .utf8) {
            token = tokenString
        } else {
            token = ""
        }
        
        return ["x-auth-token": token]
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self, !self.isClosed else { return }
            
            switch result {
            case .failure(let error):
                print("WebSocket 수신 오류: \(error.localizedDescription)")
                if !self.isClosed {
                    self.reconnect()
                }
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8) {
                        do {
                            let baseResponse = try JSONDecoder().decode(WebSocketResponseBase.self, from: data)
                            switch baseResponse.type {
                            case .NEW_CHAT:
                                let response = try JSONDecoder().decode(ChatMessageModel.self, from: data)
                                DispatchQueue.main.async {
                                    self.onMessage?(response)
                                }
                            case .ERROR:
                                let response = try JSONDecoder().decode(WebSocketFailResponseData.self, from: data)
                                print("WebSocket 오류: \(response.message ?? "알 수 없는 오류")")
                            case .QUEUE_POSITION_UPDATE:
                                let response = try JSONDecoder().decode(QueuePositionMessage.self, from: data)
                                DispatchQueue.main.async {
                                    self.queuePosition = response.position
                                    print("Queue position updated: \(response.position)")
                                }
                            }
                        } catch {
                            print("WebSocket 디코딩 오류: \(error.localizedDescription)")
                        }
                    }
                case .data(let data):
                    print("바이너리 데이터 수신: \(data)")
                @unknown default:
                    break
                }
                self.receiveMessage()
            }
        }
    }
    
    func close() {
        print("Closing WebSocket connection...")
        isClosed = true
        stopPingTimer()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func reconnect() {
        guard !isClosed else { return }
        
        close()
        isClosed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self, !self.isClosed else { return }
            print("Attempting to reconnect WebSocket...")
            self.connect()
        }
    }
    
    private func startPingTimer() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func sendPing() {
        guard !isClosed else { return }
        
        webSocketTask?.sendPing { [weak self] error in
            guard let self = self, !self.isClosed else { return }
            
            if let error = error {
                print("Error sending ping: \(error.localizedDescription)")
                self.reconnect()
            } else {
                print("Ping sent successfully")
            }
        }
    }
}

struct WebSocketResponseBase: Decodable {
    let type: MessageType
}

enum ResourceType: String, Codable {
    case TEXT
    case IMAGE
    case START
    case PROMPT
    case END
}

enum MessageType: String, Codable {
    case ERROR
    case NEW_CHAT
    case QUEUE_POSITION_UPDATE
}

struct QueuePositionMessage: Codable {
    let position: Int
}

struct WebSocketFailResponseData: Codable {
    let type: MessageType
    let kind: String?
    let message: String?
}
