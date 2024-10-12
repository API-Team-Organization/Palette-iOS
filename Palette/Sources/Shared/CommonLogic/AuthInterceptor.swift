//
//  AuthInterceptor.swift
//  Palette
//
//  Created by jombi on 10/13/24.
//

import Foundation
import Alamofire

public struct AuthInterceptor: RequestInterceptor {
    public init() {}
    
    public func token() -> String? {
        var token: String? = nil
        if let tokenData = KeychainManager.load(key: "accessToken"), let tokenString = String(data: tokenData, encoding: .utf8) {
            token = tokenString
        }
        return token
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var modifiedRequest = urlRequest
        if let sessionToken = token() {
            modifiedRequest.setValue(sessionToken, forHTTPHeaderField: "x-auth-token")
        }
        
        completion(.success(modifiedRequest))
    }
}
