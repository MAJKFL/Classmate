//
//  Lesson.swift
//  Classmate
//
//  Created by Kuba Florek on 10/10/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct lesson: Codable, Identifiable {
    @DocumentID var id: String?
    
    var subject: String
    var dayOfTheWeek: String
    var classroom: String
    var number: Int
    
    static var defaultLesson: lesson {
        lesson(id: UUID().uuidString, subject: "Poetry", dayOfTheWeek: "mon", classroom: "208", number: 1)
    }
}
