//
//  s_time.swift
//  market
//
//  Created by Busan Dynamic on 10/24/23.
//

import UIKit

func setKoreaUnixTimestamp() -> Int64 {
    
    let unixTimestamp = Int64(Date().timeIntervalSince1970 * 1000) % 10000000000000
    let unixTimestamp_kor = unixTimestamp+32400000
    
    return unixTimestamp_kor
}

func setTimestampToDateTime(timestamp: Int, dateformat: String = "yyyy-MM-dd HH:mm:ss") -> String {
    
    var timeInterval = TimeInterval()
    if ("\(timestamp)".count == 13) { timeInterval = TimeInterval(timestamp/1000) } else { timeInterval = TimeInterval(timestamp) }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateformat
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    
    if (timestamp > 0) {
        return dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval))
    } else {
        return ""
    }
}