//
//  lessonListViewModel.swift
//  Classmate
//
//  Created by Kuba Florek on 10/10/2020.
//


import Foundation
import Combine

class LessonListViewModel: ViewModel {
    @Published var dayOfTheWeek = daysOfTheWeek.mon
    
    @Published var allSubjects = [String]()
    @Published var newLessonSubject = ""
    @Published var newLessonClass = "" {
        didSet {
            if newLessonClass.count > 5 && oldValue.count <= 5 {
                newLessonClass = oldValue
            }
        }
    }
    
    var filteredLessonCellViewModels: [LessonCellViewModel] {
        let filteredLessonCellVM = lessonCellViewModels.filter { $0.dayOfTheWeek == dayOfTheWeek}
        return filteredLessonCellVM.sorted { $0.number < $1.number }
    }
    
    static let breakLengths = [0, 5, 10, 15, 20, 25, 30]
    static let lessonLengths = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        _ = self.objectWillChange.append(super.objectWillChange)
        
        $lessonCellViewModels
            .sink(receiveValue: setAllSubjects(_:))
            .store(in: &cancellables)
        
        setDayOfTheWeek()
    }
    
    func setDayOfTheWeek()  {
    let date = Date()
    let calendar = Calendar.current
    
    let dayNumber = calendar.component(.weekday, from: date)
    
    switch dayNumber {
        case 3:
            dayOfTheWeek = .tue
        case 4:
            dayOfTheWeek = .wed
        case 5:
            dayOfTheWeek = .thu
        case 6:
            dayOfTheWeek = .fri
        default:
            dayOfTheWeek = .mon
        }
    }
    
    private func setAllSubjects(_ subjects: [LessonCellViewModel]) {
        var allSubjectsData = subjects.map { lesson in
            lesson.subject
        }
        allSubjectsData.removeAll(where: { $0 == "[EMPTY]" })
        
        let allSubjectsNotSorted = Array(Set(allSubjectsData))
        allSubjects = allSubjectsNotSorted.sorted { $0.lowercased() < $1.lowercased() }
    }
    
    func addNewLesson() {
        if filteredLessonCellViewModels.count + 1 > breakCellViewModels.count {
            let newBreak = schoolBreak(id: UUID().uuidString, number: breakCellViewModels.count + 1, length: 5)
        
            breakRepository.addBreak(newBreak)
        }
        
        var allNumbers = filteredLessonCellViewModels.map { lesson in
            lesson.number
        }
        allNumbers.sort()
        
        let newLesson = lesson(id: UUID().uuidString, subject: newLessonSubject, dayOfTheWeek: dayOfTheWeek.rawValue, classroom: newLessonClass, number: (allNumbers.last ?? 0) + 1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.lessonRepository.addLesson(newLesson)
        }
        
        newLessonClass = ""
        newLessonSubject = ""
    }
    
    func removeLesson(at offsets: IndexSet) {
        var index: Int?
        offsets.forEach { i in
            index = i
        }
        
        guard let unwrappedIndex = index else { return }
        let lessonCellVM = filteredLessonCellViewModels[unwrappedIndex]
        lessonRepository.removeLesson(lessonCellVM.lesson)
        
        var i = 1
        for lesson in filteredLessonCellViewModels {
            if lesson.id != lessonCellVM.id {
                lesson.lesson.number = i
                lessonRepository.updateLesson(lesson.lesson)
                i += 1
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        var movedLessonCellVMs = filteredLessonCellViewModels
        movedLessonCellVMs.move(fromOffsets: source, toOffset: destination)
        
        var i = 1
        for lessonCellVM in movedLessonCellVMs {
            lessonCellVM.lesson.number = i
            lessonRepository.updateLesson(lessonCellVM.lesson)
            i += 1
        }
    }
    
    func lessonDate(index: Int) -> String {
        var previousBreaks = breakCellViewModels.map { schoolBreak in
            schoolBreak.length
        }
        
        previousBreaks.removeLast(breakCellViewModels.count - index)
        let summedBreaks = previousBreaks.reduce(0, +)
        let date = settingsViewModel.firstLesson.addingTimeInterval(TimeInterval(index * settingsViewModel.lessonLength * 60 + summedBreaks * 60))
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: date)) - \(formatter.string(from: date.addingTimeInterval(TimeInterval(settingsViewModel.lessonLength * 60))))"
    }
}
