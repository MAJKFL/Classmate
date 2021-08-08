//
//  PlanListView.swift
//  Classmate
//
//  Created by Kuba Florek on 15/11/2020.
//

import SwiftUI
import CodeScanner

struct PlanListView: View {
    @StateObject var planListVM = PlanListViewModel()
    
    @State private var showAddPanel = false
    @State private var showScanner = false
    
    @AppStorage("ActivePlan") var activePlan: String = " "
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(planListVM.allPlans.keys).sorted(by: <), id: \.self) { key in
                    Button(action: {
                        withAnimation(Animation.easeIn(duration: 0.2)) { activePlan = key }
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                                .opacity(key == activePlan ? 1 : 0)
                                .foregroundColor(.blue)
                            
                            Text(planListVM.allPlans[key] ?? "")
                        }
                    }
                }
                .onDelete(perform: planListVM.removePlan)
                .deleteDisabled(planListVM.allPlans.count <= 1)
                
                if showAddPanel { addPanel }
            }
            .listStyle(InsetListStyle())
            .navigationTitle("All plans")
            .navigationBarItems(leading: Button(action: {
                withAnimation(.easeIn) { showAddPanel.toggle() }
            }) {
                Image(systemName: "plus")
                    .rotationEffect(.degrees(showAddPanel ? 45 : 0))
                    .animation(.spring())
            }, trailing: Button(action: {
                showScanner = true
            }){
                Image(systemName: "qrcode.viewfinder")
            })
            .sheet(isPresented: $showScanner) {
                GetSharedPlanView(planListVM: planListVM, showScanner: $showScanner)
                //CodeScannerView(codeTypes: [.qr], completion: self.handleScan(result:))
                //    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

extension PlanListView {
    var addPanel: some View {
        HStack {
            TextField("Title", text: $planListVM.newPlanTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                planListVM.newPlan()
                withAnimation(.easeIn) { showAddPanel = false }
            }) {
                Text("Add")
            }
            .foregroundColor(.blue)
            .disabled(planListVM.newPlanTitle.isEmpty)
        }
        .padding(5)
        .transition(.opacity)
        .animation(.easeIn)
    }
}

struct GetSharedPlanView: View {
    @ObservedObject var planListVM: PlanListViewModel
    @Binding var showScanner: Bool
    @State private var planID = ""
    
    var body: some View {
        ZStack {
            CodeScannerView(codeTypes: [.qr], completion: self.handleScan(result:))
            
            VStack {
                HStack {
                    TextField("PlanID", text: $planID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        addPlanID()
                    }, label: {
                        Image(systemName: "plus")
                            .font(.title)
                    })
                    .disabled(planID.count < 22)
                }
                .opacity(planID.isEmpty ? 0.4 : 0.8)
                .padding()
                
                Spacer()
            }
            .animation(.easeIn)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        showScanner = false
        
        switch result {
            case .success(let code):
                planListVM.addPlan(code: code)
            case .failure(let error):
                print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addPlanID() {
        showScanner = false
        planListVM.addPlan(code: planID)
    }
}
