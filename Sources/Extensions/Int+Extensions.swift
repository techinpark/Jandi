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
            return Localized.streakFristStage
        case 1:
            return Localized.streakSecondStage
        case 2 ..< 30:
            return Localized.streakThirdStage.replacingOccurrences(of: "${day}", with: self.description)
        default:
            return Localized.streakForthStage.replacingOccurrences(of: "${day}", with: self.description)
        }
    }
}
