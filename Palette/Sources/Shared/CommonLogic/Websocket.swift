//
//  Websocket.swift
//  Palette
//
//  Created by 4rNe5 on 9/13/24.
//

import Foundation
import Combine
import SwiftUI

class Websocket: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let roomID: Int
    private var onMessage: ((ChatMessageModel) -> ())?
    
    func setMessageCallback(onMessage: @escaping (ChatMessageModel) -> ()) {
        self.onMessage = onMessage
    }
    
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
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        print("WebSocket connected successfully.")
        receiveMessage()
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
            switch result {
            case .failure(let error):
                print("WebSocket Receive Error: \(error.localizedDescription)")
                self?.reconnect()
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
                                    print("im callin")
                                    self?.onMessage?(response)
                                }
                            case .ERROR:
                                let response = try JSONDecoder().decode(WebSocketFailResponseData.self, from: data)
                                print("WebSocket Error: \(response.message ?? "Unknown error")")
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

struct WebSocketFailResponseData: Codable {
    let type: MessageType
    let kind: String?
    let message: String?
}
