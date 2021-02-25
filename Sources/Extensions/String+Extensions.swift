//
//  String+Extensions.swift
//  jandi
//
//  Created by 오준현 on 2021/02/24.
//

import Foundation

extension String {
    
    public func getDateFormat() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        guard let timeDateFormat = dateFormat.date(from: self) else { return Date() }
        
        return timeDateFormat
    }

}
