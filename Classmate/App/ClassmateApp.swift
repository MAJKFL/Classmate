//
//  ClassmateApp.swift
//  Classmate
//
//  Created by Kuba Florek on 10/10/2020.
//

import SwiftUI
import Firebase

@main
struct ClassmateApp: App {
    @UIApplicationDelegateAdaptor(Delegate.self) var delegate
    
    @AppStorage("ActivePlan") var activePlan: String = " "
    @State private var selection = 1
    
    var body: some Scene {
        WindowGroup {
            if activePlan != " " {
                TabView(selection: $selection) {
                    PlanListView()
                        .tabItem {
                            Image(systemName: "list.dash")
                            Text("Plans")
                        }
                        .tag(0)
                    
                    TodayView()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Today")
                        }
                        .tag(1)
                    
                    LessonPlanView()
                        .tabItem {
                            Image(systemName: "list.bullet.below.rectangle")
                            Text("Lesson plan")
                        }
                        .tag(2)
                }
            } else {
                WelcomeView()
            }
        }
    }
}

class Delegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        Auth.auth().signInAnonymously()
        
        return true
    }
}
