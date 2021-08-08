//
//  BreakRepository.swift
//  Classmate
//
//  Created by Kuba Florek on 13/11/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class BreakRepository: ObservableObject {
    let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    @Published var breaks = [schoolBreak]()
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
        db.collection("/AllPlans/\(id)/Breaks")
            .order(by: "number")
            .addSnapshotListener {  (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.breaks = querySnapshot.documents.compactMap { document in
                    try? document.data(as: schoolBreak.self)
                }
            }
        }
    }
    
    func addBreak(_ schoolBreak: schoolBreak) {
        let _ = try? db.collection("/AllPlans/\(id)/Breaks").addDocument(from: schoolBreak)
    }
    
    func updateBreak(_ schoolBreak: schoolBreak) {
        if let breakID = schoolBreak.id {
            do {
                try db.collection("/AllPlans/\(id)/Breaks").document(breakID).setData(from: schoolBreak)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    deinit {
        observer?.invalidate()
    }
}
