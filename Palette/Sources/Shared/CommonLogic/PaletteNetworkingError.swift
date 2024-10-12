//
//  PaletteException.swift
//  Palette
//
//  Created by jombi on 10/13/24.
//

import Foundation

enum PaletteNetworkingError : Error {
    case bodyParseFailed
    case unknown
    case frontFault(reason: String, kind: String)
    
    public var reason: String? {
        guard case let .frontFault(reason, _) = self else { return nil }
        return reason
    }
    
    public var kind: String? {
        guard case let .frontFault(_, kind) = self else { return nil }
        return kind
    }
    
    public var localizedDescription: String { "Error.\(self.kind ?? "unknown"): \(self.reason ?? "no reason provided (maybe internal stack is shown)")" }
}
