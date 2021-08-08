//
//  Date+Extensions.swift
//  Classmate
//
//  Created by Kuba Florek on 03/11/2020.
//

import Foundation

extension Date {
    var startOfNextDay: Date {
        return Calendar.current.nextDate(after: self, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
    
    var secondsUntilTheNextDay: TimeInterval {
        return startOfNextDay.timeIntervalSince(self)
    }
}
