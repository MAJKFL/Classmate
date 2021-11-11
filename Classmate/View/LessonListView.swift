//
//  LessonListView.swift
//  Classmate
//
//  Created by Kuba Florek on 24/10/2020.
//

import SwiftUI

struct LessonListView: View {
    @ObservedObject var lessonListVM: LessonListViewModel
    
    let dayOfTheWeek: daysOfTheWeek
    
    @State private var showBreakLength = false
    @State private var showAddPanel = false
    
    var filteredLessonCellVMs: [LessonCellViewModel] {
        let filteredLessonCellVM = lessonListVM.lessonCellViewModels.filter { $0.dayOfTheWeek == lessonListVM.dayOfTheWeek}
        
        return filteredLessonCellVM.sorted { $0.number < $1.number }
    }
    
    var body: some View {
        List {
            ForEach(filteredLessonCellVMs) { lesson in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "\(lesson.number).circle")
                        Text(lesson.subject == "[EMPTY]" ? "" : "\(lesson.subject),")
                            .fontWeight(.bold)
                        Text(lesson.classroom)
                    }
                    
                    if showBreakLength && lesson.subject != "[EMPTY]" {
                        Text(lessonListVM.lessonDate(index: getIndex(lesson)))
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                    } else if lesson.subject != "[EMPTY]" {
                        Text("Next break: \(lessonListVM.breakCellViewModels[getIndex(lesson)].length) min")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                    }
                }
            }
            .onDelete(perform: lessonListVM.removeLesson)
            .onMove(perform: lessonListVM.move)
            
            addCell
            
            if showAddPanel { addPanel }
        }
        .listStyle(InsetListStyle())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                withAnimation(Animation.easeIn(duration: 0.15)) { showBreakLength = true }
            }
        }
    }
    
    func getIndex(_ lesson: LessonCellViewModel) -> Int {
        filteredLessonCellVMs.firstIndex(where: { $0.id == lesson.id }) ?? 0
    }
}

extension LessonListView {
    var addPanel: some View {
        VStack(alignment: .center, spacing: 5) {
            TextField("Class", text: $lessonListVM.newLessonClass)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.top)
            
            TextField("Subject", text: $lessonListVM.newLessonSubject)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("Your subjects", selection: $lessonListVM.newLessonSubject) {
                Text("")
                
                Text("[EMPTY]")
                    .tag("[EMPTY]")
                
                ForEach(lessonListVM.allSubjects, id: \.self) { subject in
                    Text(subject)
                }
            }
        }
        .padding()
    }
    
    var addCell: some View {
        HStack {
            Button(action: {
                showAddPanel.toggle()
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .rotationEffect(.degrees(showAddPanel ? 45 : 0))
                        .animation(.spring())
                    Text(showAddPanel ? "Cancel" : "Add lesson")
                        .animation(.none)
                }
            }
            .font(.headline)
            .foregroundColor(.blue)
            
            Spacer()
            
            if showAddPanel {
                Button(action: {
                    lessonListVM.addNewLesson()
                    withAnimation(.easeIn) { showAddPanel = false }
                }) {
                    HStack {
                        Text("Add")
                    }
                }
                .foregroundColor(.blue)
                .disabled((lessonListVM.newLessonClass.isEmpty || lessonListVM.newLessonSubject.isEmpty || filteredLessonCellVMs.count >= 49) && lessonListVM.newLessonSubject != "[EMPTY]")
            }
        }
    }
}
