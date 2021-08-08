//
//  PlanListViewModel.swift
//  Classmate
//
//  Created by Kuba Florek on 15/11/2020.
//

import Foundation
import Combine

class PlanListViewModel: ViewModel {
    let defaults = UserDefaults.standard
    @Published var allPlans = [String: String]()
    @Published var newPlanTitle = ""
    
    override init() {
        super.init()
        _ = self.objectWillChange.append(super.objectWillChange)
        
        allPlans = defaults.dictionary(forKey: "AllPlans") as? [String: String] ?? [String: String]()
    }
    
    func addPlan(code: String) {
        if code.components(separatedBy: "/").count == 2 {
            allPlans[code.components(separatedBy: "/")[0]] = code.components(separatedBy: "/")[1]
            
            defaults.set(allPlans, forKey: "AllPlans")
        }
    }
    
    func removePlan(at offsets: IndexSet) {
        let key = Array(allPlans.keys).sorted(by: <)[offsets.first!]
        allPlans.removeValue(forKey: key)
        
        defaults.set(allPlans, forKey: "AllPlans")
        defaults.set(allPlans.randomElement()?.key ?? " ", forKey: "ActivePlan")
    }
    
    func newPlan() {
        settingsRepository.newPlan(title: newPlanTitle)
        
        allPlans = defaults.dictionary(forKey: "AllPlans") as? [String: String] ?? [String: String]()
        
        newPlanTitle = ""
    }
}
