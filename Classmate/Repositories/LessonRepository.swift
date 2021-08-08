//
//  LessonRepository.swift
//  Classmate
//
//  Created by Kuba Florek on 12/11/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class LessonRepository: ObservableObject {
    let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    @Published var lessons = [lesson]()
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
        db.collection("/AllPlans/\(id)/Lessons").addSnapshotListener {  (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.lessons = querySnapshot.documents.compactMap { document in
                    try? document.data(as: lesson.self)
                }
            }
        }
    }
    
    func addLesson(_ lesson: lesson) {
        let _ = try? db.collection("/AllPlans/\(id)/Lessons").addDocument(from: lesson)
    }
    
    func updateLesson(_ lesson: lesson) {
        if let lessonID = lesson.id {
            do {
                try db.collection("/AllPlans/\(id)/Lessons").document(lessonID).setData(from: lesson)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func removeLesson(_ lesson: lesson) {
        if let lessonID = lesson.id {
            db.collection("/AllPlans/\(id)/Lessons").document(lessonID).delete()
        }
    }
    
    deinit {
        observer?.invalidate()
    }
}

extension UserDefaults {
    @objc dynamic var ActivePlan: String {
        return string(forKey: "ActivePlan") ?? " "
    }
}
