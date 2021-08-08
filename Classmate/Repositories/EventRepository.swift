//
//  EventRepository.swift
//  Classmate
//
//  Created by Kuba Florek on 09/12/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class EventRepository: ObservableObject {
    let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    @Published var events = [event]()
    @Published var id = " "
    
    var observer: NSKeyValueObservation?
    
    init() {
        self.id = defaults.string(forKey: "ActiveLesson") ?? " "
        
        observer = UserDefaults.standard.observe(\.ActivePlan, options: [.initial, .new], changeHandler: { (defaults, change) in
            self.id = change.newValue ?? " "
            self.loadData()
        })
        
        loadData()
    }
    
    func loadData() {
        db.collection("/AllPlans/\(id)/Events")
            .addSnapshotListener {  (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.events = querySnapshot.documents.compactMap { document in
                    try? document.data(as: event.self)
                }
            }
        }
    }
    
    func addEvent(_ event: event) {
        let _ = try? db.collection("/AllPlans/\(id)/Events").addDocument(from: event)
    }
    
    func updateEvent(_ event: event) {
        if let eventID = event.id {
            do {
                try db.collection("/AllPlans/\(id)/Event").document(eventID).setData(from: event)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func removeEvent(_ event: event) {
        if let eventID = event.id {
            db.collection("/AllPlans/\(id)/Events").document(eventID).delete()
        }
    }
    
    deinit {
        observer?.invalidate()
    }
}

