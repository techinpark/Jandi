//
//  Date+Extensions.swift
//  jandi
//
//  Created by Fernando on 2021/01/29.
//

import Foundation

extension Date {
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        let prefLanguage = Locale.preferredLanguages[0]
        
        dateFormatter.locale = NSLocale(localeIdentifier: prefLanguage) as Locale
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from:self).capitalized
    }
}
