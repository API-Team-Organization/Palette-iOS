//
//  DateFomatter.swift
//  Palette
//
//  Created by 4rNe5 on 5/23/24.
//

import Foundation

func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // 원하는 날짜 형식 설정
        return formatter.string(from: date)
}

