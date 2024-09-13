//
//  ImageResponseModel.swift
//  Palette
//
//  Created by 4rNe5 on 9/13/24.
//


struct ImageResponseModel: Codable {
    let code: Int
    let message: String
    let data: [String]
}
