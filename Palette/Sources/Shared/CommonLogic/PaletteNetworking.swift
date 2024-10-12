//
//  PaletteAlamofire.swift
//  Palette
//
//  Created by jombi on 10/12/24.
//

import Foundation
import Alamofire

struct PaletteAF {
    @available(*, unavailable) private init() {}
    
    private static let baseUrl: String = {
        return "https://api.paletteapp.xyz"
        // TODO: get url from config
    }()
    
    private static let session: Session = Session(
        configuration: URLSessionConfiguration.af.default,
        interceptor: AuthInterceptor()
    )
    
    static let jsonDecoder = {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = JSONDecoder.NonConformingFloatDecodingStrategy.convertFromString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
        return decoder
    }()
    
    private static func handleResponse<R : Decodable>(_ response: DataResponse<R, AFError>) async -> Result<R, PaletteNetworkingError> {
        do {
            if (400...500).contains(response.response?.statusCode ?? 500) {
                if let response = response.data {
                        let body = try jsonDecoder.decode(ErrorModel.self, from: response)
                        throw PaletteNetworkingError.frontFault(reason: body.message, kind: body.kind)
                }
            } else {
                let res = try response.result.get()
                return .success(res)
            }
        } catch {
            switch (error) {
            case is PaletteNetworkingError:
                return .failure(error as! PaletteNetworkingError)
            case is DecodingError:
                switch error as! DecodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context)")
                case .keyNotFound(let key, let context):
                    print("Key '\(key)' not found: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type \(type): \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value of type \(type) not found: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error: \(error)")
                }
                return .failure(PaletteNetworkingError.bodyParseFailed)
            default:
                print(error)
                return .failure(.unknown)
            }
        }
    
        return .failure(.unknown)
    }
    
    static func get<T>(
        _ path: String,
        headers: HTTPHeaders? = nil,
        res: T.Type
    ) async -> Result<T, PaletteNetworkingError> where T : Decodable {
        let response = await session
            .request("\(baseUrl)\(path)", method: .get, headers: headers)
            .validate()
            .serializingDecodable(res)
            .response
        
    
        return await handleResponse(response)
    }
    
    static func post<T, Parameters: Encodable>(
        _ path: String,
        parameters: Parameters? = nil,
        encoder: ParameterEncoder = JSONParameterEncoder.default,
        headers: HTTPHeaders? = nil,
        res: T.Type
    ) async -> Result<T, PaletteNetworkingError> where T : Decodable {
        let response = await PaletteAF.session
            .request("\(baseUrl)\(path)", method: .post, parameters: parameters, encoder: encoder, headers: headers)
            .validate()
            .serializingDecodable(res)
            .response
        
        return await handleResponse(response)
    }
    
    static func patch<T, Parameters: Encodable>(
        _ path: String,
        parameters: Parameters? = nil,
        encoder: ParameterEncoder = JSONParameterEncoder.default,
        headers: HTTPHeaders? = nil,
        res: T.Type
    ) async -> Result<T, PaletteNetworkingError> where T : Decodable {
        let response = await PaletteAF.session
            .request("\(baseUrl)\(path)", method: .patch, parameters: parameters, encoder: encoder, headers: headers)
            .validate()
            .serializingDecodable(res)
            .response
        
        return await handleResponse(response)
    }
    
    static func delete<T>(
        _ path: String,
        headers: HTTPHeaders? = nil,
        res: T.Type
    ) async -> Result<T, PaletteNetworkingError> where T : Decodable {
        let response = await PaletteAF.session
            .request("\(baseUrl)\(path)", method: .delete, headers: headers)
            .validate()
            .serializingDecodable(res)
            .response
        
        return await handleResponse(response)
    }
}
