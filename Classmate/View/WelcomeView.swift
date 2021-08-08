//
//  WelcomeView.swift
//  Classmate
//
//  Created by Kuba Florek on 17/11/2020.
//

import SwiftUI

extension HorizontalAlignment {
    enum MidIcons: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.leading]
        }
    }

    static let midIcons = HorizontalAlignment(MidIcons.self)
}

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 10)
                
                Text("Hi, thanks for choosing my app😀")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text("I'll walk you through some of the most important features.\nWe will also create your first plan")
                    .foregroundColor(.secondary)
                    .font(.title)
                    .padding(.horizontal)
                
                Spacer()
                
                NavigationLink(
                    destination: MainFeaturesView(),
                    label: {
                        Text("Let's move on!")
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(width: UIScreen.main.bounds.width - 50, height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    })
                    .padding(.bottom)
            }
            .multilineTextAlignment(.center)
        }
        
        /*Button("Create first plan") {
            planListVM.newPlanTitle = "Your new plan"
            planListVM.newPlan()
        }*/
    }
}

struct MainFeaturesView: View {
    var body: some View {
        VStack {
            Text("Main features")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(alignment: .midIcons, spacing: 25) {
                HStack {
                    Image(systemName: "list.dash")
                        .font(.system(size: 45))
                        .foregroundColor(.red)
                        .alignmentGuide(.midIcons) { d in d[HorizontalAlignment.center]}
                    
                    VStack(alignment: .leading) {
                        Text("Plan list")
                            .font(.headline)
                        
                        Text("Manage your plans, create new, delete and recieve existing ones")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "house")
                        .font(.system(size: 39))
                        .foregroundColor(.yellow)
                        .alignmentGuide(.midIcons) { d in d[HorizontalAlignment.center]}
                    
                    VStack(alignment: .leading) {
                        Text("Today")
                            .font(.headline)
                        
                        Text("View your today schedulde, share your plan, create and view your events")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "list.bullet.below.rectangle")
                        .font(.system(size: 45))
                        .foregroundColor(.green)
                        .alignmentGuide(.midIcons) { d in d[HorizontalAlignment.center]}
                    
                    VStack(alignment: .leading) {
                        Text("Plan options")
                            .font(.headline)
                        
                        Text("Create and manage your lessons, change lesson and break length")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            NavigationLink(
                destination: FirstPlanView(),
                label: {
                    Text("Continue")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(width: UIScreen.main.bounds.width - 50, height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                })
                .padding(.bottom)
        }
        .padding(.horizontal)
    }
}

struct FirstPlanView: View {
    @StateObject var planListVM = PlanListViewModel()
    
    var body: some View {
        VStack {
            Text("Creating plan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 45))
                    .foregroundColor(.orange)
                    .alignmentGuide(.midIcons) { d in d[HorizontalAlignment.center]}
                
                VStack(alignment: .leading) {
                    Text("Your first plan")
                        .font(.headline)
                    
                    Text("Create your first plan by giving it some beautiful name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            TextField("Title", text: $planListVM.newPlanTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.horizontal, .top], 50)
            
            Spacer()
            
            Button(action: {
                planListVM.newPlan()
            }, label: {
                Text("Create!")
                    .font(.headline)
            })
            .disabled(planListVM.newPlanTitle.isEmpty)
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
}
