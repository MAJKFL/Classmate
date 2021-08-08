//
//  Event.swift
//  Classmate
//
//  Created by Kuba Florek on 09/12/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct event: Codable, Identifiable {
    @DocumentID var id: String?
    
    var subject: String
    var date: Date
    var title: String
    var description: String
    
    static var defaultEvent: event {
        event(id: UUID().uuidString, subject: "Poetry", date: Date(), title: "Write poem", description: "Write poem about Jan Kochanowski")
    }
}
