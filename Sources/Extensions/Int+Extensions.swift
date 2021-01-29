//
//  Int+Extensions.swift
//  jandi
//
//  Created by Fernando on 2021/01/29.
//

import Foundation

extension Int {
    func getEmoji() -> String {
        switch self {
        case 1..<4:
            return "🌱"
        case 4..<10:
            return "🌿"
        case 10..<100:
            return "🌳"
        default:
            return "🔥"
        }
    }
}
