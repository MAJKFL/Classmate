//
//  SettingsRepository.swift
//  Classmate
//
//  Created by Kuba Florek on 14/11/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class SettingsRepository: ObservableObject {
    let defaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    @Published var settings = planSettings.defaultSettings
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
        db.document("/AllPlans/\(id)").addSnapshotListener {  (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                do {
                    try self.settings = querySnapshot.data(as: planSettings.self) ?? planSettings.defaultSettings
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    func updateSettings(_ settings: planSettings) {
        db.document("/AllPlans/\(id)").updateData([
            "firstLesson": settings.firstLesson,
            "lessonLength": settings.lessonLength,
            "title": settings.title
        ])
    }
    
    func newPlan(title: String) {
        let defaults = UserDefaults.standard
        var allPlans = defaults.dictionary(forKey: "AllPlans") as? [String: String] ?? [String: String]()
        var newPlanSettings = planSettings.defaultSettings
        newPlanSettings.title = title
        
        do {
            let newPlanReference = try db.collection("AllPlans").addDocument(from: newPlanSettings)
            let _ = try db.document(newPlanReference.path).collection("Breaks").addDocument(from: schoolBreak.defaultBreak)
            let _ = try db.document(newPlanReference.path).collection("Lessons").addDocument(from: lesson.defaultLesson)
            allPlans[newPlanReference.documentID] = title
            defaults.set(allPlans, forKey: "AllPlans")
            defaults.set(newPlanReference.documentID, forKey: "ActivePlan")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    deinit {
        observer?.invalidate()
    }
}

