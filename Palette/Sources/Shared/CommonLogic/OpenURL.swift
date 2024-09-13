//
//  OpenURL.swift
//  Palette
//
//  Created by 4rNe5 on 9/13/24.
//

import Foundation
import UIKit

func OpenURL(url: String) {
    if let url = URL(string: url) {
        UIApplication.shared.open(url)
    }
}
