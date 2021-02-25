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
        case 1 ..< 4:
            return "🌱"
        case 4 ..< 10:
            return "🌿"
        case 10 ..< 100:
            return "🌳"
        default:
            return "🔥"
        }
    }
    
    func getStreaks() -> String {
        switch self {
        case 0:
            return Localized.streak_first_stage
        case 1 ..< 4:
            return Localized.streak_second_stage
        case 4 ..< 10:
            return Localized.streak_third_stage.replacingOccurrences(of: "${day}", with: self.description)
        default:
            return Localized.streak_fourth_stage.replacingOccurrences(of: "${day}", with: self.description)
        }
    }
}
