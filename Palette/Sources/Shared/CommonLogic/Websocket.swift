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
    private var pingTimer: Timer?
    private var isClosed = false  // 새로운 플래그 추가
    
    func setMessageCallback(onMessage: @escaping (ChatMessageModel) -> ()) {
        self.onMessage = onMessage
    }
    
    init(roomID: Int) {
        self.roomID = roomID
        self.connect()
    }
    
    deinit {
        close()
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
            guard let self = self, !self.isClosed else { return }  // isClosed 체크 추가
            
            switch result {
            case .failure(let error):
                print("WebSocket Receive Error: \(error.localizedDescription)")
                if !self.isClosed {  // isClosed 체크 추가
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
                                    print("im callin")
                                    self.onMessage?(response)
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
                self.receiveMessage()
            }
        }
    }
    
    func close() {
        print("Closing WebSocket connection...")
        isClosed = true  // 연결 종료 플래그 설정
        stopPingTimer()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func reconnect() {
        guard !isClosed else { return }  // isClosed 체크 추가
        
        close()
        isClosed = false  // reconnect 시 isClosed 재설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self, !self.isClosed else { return }  // 추가 체크
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
        guard !isClosed else { return }  // isClosed 체크 추가
        
        webSocketTask?.sendPing { [weak self] error in
            guard let self = self, !self.isClosed else { return }  // 추가 체크
            
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
}

struct WebSocketFailResponseData: Codable {
    let type: MessageType
    let kind: String?
    let message: String?
}
