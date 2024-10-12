//
//  DataResModel.swift
//  Palette
//
//  Created by jombi on 10/13/24.
//

import Foundation

struct DataResModel<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T
}
