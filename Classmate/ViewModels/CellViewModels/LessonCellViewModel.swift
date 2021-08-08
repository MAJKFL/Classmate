//
//  lessonCellViewModel.swift
//  Classmate
//
//  Created by Kuba Florek on 10/10/2020.
//

import Foundation
import Combine

class LessonCellViewModel: ObservableObject, Identifiable  {
    @Published var lesson: lesson
      
    var id: String = ""
    @Published var subject = ""
    @Published var dayOfTheWeek = daysOfTheWeek.mon
    @Published var classroom = ""
    @Published var number = 0
      
    private var cancellables = Set<AnyCancellable>()
    
    init(lesson: lesson) {
        self.lesson = lesson
            
        $lesson
            .map { $0.subject }
            .assign(to: \.subject, on: self)
            .store(in: &cancellables)

        $lesson
            .map { (daysOfTheWeek(rawValue: $0.dayOfTheWeek) ?? .mon) }
            .assign(to: \.dayOfTheWeek, on: self)
            .store(in: &cancellables)
        
        $lesson
            .map { $0.classroom }
            .assign(to: \.classroom, on: self)
            .store(in: &cancellables)
        
        $lesson
            .map { $0.number }
            .assign(to: \.number, on: self)
            .store(in: &cancellables)
        
        $lesson
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
}
