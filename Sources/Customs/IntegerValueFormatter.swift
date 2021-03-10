//
//  IntegerValueFormatter.swift
//  jandi
//
//  Created by JunSang Ryu on 2021/03/08.
//

import Foundation

class IntegerValueFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        guard !partialString.isEmpty else { return true }
        let scanner = Scanner(string: partialString)
        let pointer: UnsafeMutablePointer<Int> = .allocate(capacity: 0)
        if !(scanner.scanInt(pointer) && scanner.isAtEnd) {
            return false
        }

        return true
    }
}
