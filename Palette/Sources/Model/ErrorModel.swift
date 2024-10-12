//
//  ErrorModel.swift
//  Palette
//
//  Created by jombi on 10/13/24.
//

import Foundation

struct ErrorModel: Decodable {
    let code: Int
    let message: String
    let kind: String
}
