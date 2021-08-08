//
//  schoolBreak.swift
//  Classmate
//
//  Created by Kuba Florek on 21/10/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct schoolBreak: Codable, Identifiable {
    @DocumentID var id: String?
    
    var number: Int
    var length: Int
    
    static var defaultBreak: schoolBreak {
        schoolBreak(id: UUID().uuidString, number: 1, length: 5)
    }
}
