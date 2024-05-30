//
//  SignUpRequestModel.swift
//  Palette
//
//  Created by 4rNe5 on 5/23/24.
//

import Foundation

struct SignUpRequestModel: Codable {
    let username: String
    let password: String
    let birthDate: String
    let email: String
}
