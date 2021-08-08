//
//  Settings.swift
//  Classmate
//
//  Created by Kuba Florek on 14/11/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct planSettings: Codable, Identifiable {
    @DocumentID var id: String?
    
    var firstLesson: Date
    var lessonLength: Int
    var title: String
    
    static var defaultSettings: planSettings {
        planSettings(firstLesson: Date(timeIntervalSince1970: 1577865600), lessonLength: 45, title: "")
    }
}
