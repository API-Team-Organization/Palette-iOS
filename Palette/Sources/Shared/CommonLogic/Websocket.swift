//
//  Websocket.swift
//  Palette
//
//  Created by 4rNe5 on 9/13/24.
//
import Foundation
import Combine
import SwiftUI
import Alamofire

class Websocket: ObservableObject {
    @Published var messages = [ChatMessageModel]()
    private var webSocketTask: URLSessionWebSocketTask?
    private let roomID: Int
    
    init(roomID: Int) {
        self.roomID = roomID
        self.connect()
    }
    
    private func connect() {
        guard let url = URL(string: "wss://api.paletteapp.xyz/ws/\(roomID)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        // Add authentication token to the request
        let headers = getHeaders()
        headers.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.name)
        }
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        print("WebSocket connected successfully.")
        receiveMessage()
    }
    
    private func getHeaders() -> HTTPHeaders {
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
            switch result {
            case .failure(let error):
                print("WebSocket Receive Error: \(error.localizedDescription)")
                self?.reconnect()
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received WebSocket message: \(text)")
                    if let data = text.data(using: .utf8) {
                        do {
                            let baseResponse = try JSONDecoder().decode(WebSocketResponseBase.self, from: data)
                            switch baseResponse.type {
                            case .NEW_CHAT:
                                let response = try JSONDecoder().decode(WebSocketResponse<WebSocketSuccessResponseData>.self, from: data)
                                if let chatMessage = response.data.message {
                                    DispatchQueue.main.async {
                                        self?.messages.append(chatMessage)
                                    }
                                }
                            case .ERROR:
                                let response = try JSONDecoder().decode(WebSocketResponse<WebSocketFailResponseData>.self, from: data)
                                print("WebSocket Error: \(response.data.message ?? "Unknown error")")
                            }
                        } catch {
                            print("WebSocket Decoding Error: \(error.localizedDescription)")
                        }
                    }
                case .data(let data):
                    print("Received binary data: \(data)")
                @unknown default:
                    break
                }
                self?.receiveMessage()
            }
        }
    }
    
    private func reconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            print("Attempting to reconnect WebSocket...")
            self?.connect()
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
}

struct WebSocketResponse<T: Decodable>: Decodable {
    let type: MessageType
    var data: T
}

struct WebSocketSuccessResponseData: Codable {
    let action: ResourceType
    let message: ChatMessageModel?
}

struct WebSocketFailResponseData: Codable {
    let kind: String?
    let message: String?
}
