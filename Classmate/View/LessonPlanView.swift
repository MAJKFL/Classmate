//
//  ContentView.swift
//  Classmate
//
//  Created by Kuba Florek on 10/10/2020.
//

import SwiftUI

enum daysOfTheWeek: String, CaseIterable {
    case mon
    case tue
    case wed
    case thu
    case fri
    
    var order: Int {
        switch self {
        case .tue:
            return 1
        case .wed:
            return 2
        case .thu:
            return 3
        case .fri:
            return 4
        default:
            return 0
        }
    }
}

struct LessonPlanView: View {
    @StateObject var lessonListVM = LessonListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                dayOfTheWeekPicker
                    .animation(nil)
            
                firstLessonPicker
                    .animation(nil)

                switch lessonListVM.dayOfTheWeek {
                case .mon:
                    LessonListView(lessonListVM: lessonListVM, dayOfTheWeek: .mon)
                case .tue:
                    LessonListView(lessonListVM: lessonListVM, dayOfTheWeek: .tue)
                case .wed:
                    LessonListView(lessonListVM: lessonListVM, dayOfTheWeek: .wed)
                case .thu:
                    LessonListView(lessonListVM: lessonListVM, dayOfTheWeek: .thu)
                default:
                    LessonListView(lessonListVM: lessonListVM, dayOfTheWeek: .fri)
                }
            }
            .navigationBarTitle(lessonListVM.settingsViewModel.title)
            .navigationBarItems(leading: EditButton(),trailing: Menu(content: {
                Section {
                    Text("Lesson length:")
                    
                    Picker(selection: $lessonListVM.settingsViewModel.settings.lessonLength, label: Label("\(lessonListVM.settingsViewModel.lessonLength)min.", systemImage: "clock")) {
                        ForEach(LessonListViewModel.lessonLengths, id: \.self) { minutes in
                            Text("\(minutes)min.")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    Text("Break lengths:")
                    
                    ForEach(lessonListVM.filteredLessonCellViewModels.indices, id: \.self) { index in
                        if index < lessonListVM.breakCellViewModels.count {
                            Picker(selection: $lessonListVM.breakCellViewModels[index].schoolBreak.length, label: Label("\(lessonListVM.breakCellViewModels[index].length)min.", systemImage: "\(index + 1).square")) {
                                ForEach(LessonListViewModel.breakLengths, id: \.self) { minutes in
                                    Text("\(minutes)min.")
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
            }) {
                Image(systemName: "gear")
            })
        }
    }
}

private extension LessonPlanView {
    var dayOfTheWeekPicker: some View {
        Picker(selection: $lessonListVM.dayOfTheWeek.animation(.spring()), label: Text("Day of the week")) {
            ForEach(daysOfTheWeek.allCases, id: \.self) { day in
                Text(day.rawValue)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
    
    var firstLessonPicker: some View {
        HStack {
            Image(systemName: "arrow.down.circle")
            
            Text("First lesson")
            
            DatePicker("", selection: $lessonListVM.settingsViewModel.settings.firstLesson, displayedComponents: .hourAndMinute)
        }
        .font(Font.title2.weight(.medium))
        .padding(.horizontal)
    }
}

