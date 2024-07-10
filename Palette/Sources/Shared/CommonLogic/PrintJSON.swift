//
//  PrintJSON.swift
//  Palette
//
//  Created by 4rNe5 on 7/10/24.
//

import Foundation

func PrintJSON(from data: Data) {
    do {
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON 응답:")
                print(jsonString)
            }
        }
    } catch {
        print("JSON 파싱 에러:", error.localizedDescription)
    }
}
