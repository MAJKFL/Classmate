//
//  EventInspectorViewModel.swift
//  Classmate
//
//  Created by Kuba Florek on 09/12/2020.
//

import Foundation
import Combine

class EventInspectorViewModel: ObservableObject {
    enum filters: String, CaseIterable {
        case today
        case allDays
    }
    
    @Published var lessonRepository = LessonRepository()
    @Published var eventRepository = EventRepository()
    @Published var lessonCellViewModels = [LessonCellViewModel]()
    @Published var allEvents = [EventCellViewModel]()
    @Published var newEventTitle = ""
    @Published var newEventDescription = ""
    @Published var newEventSubject = ""
    @Published var newEventDate = Date()
    @Published var filter = filters.today
    @Published var selectedEvent: EventCellViewModel?
    
    var dayOfTheWeek: daysOfTheWeek? {
        let date = newEventDate
        let calendar = Calendar.current
        
        let dayNumber = calendar.component(.weekday, from: date)
        
        switch dayNumber {
            case 2:
                return daysOfTheWeek.mon
            case 3:
                return daysOfTheWeek.tue
            case 4:
                return daysOfTheWeek.wed
            case 5:
                return daysOfTheWeek.thu
            case 6:
                return daysOfTheWeek.fri
            default:
                return nil
            }
    }
    
    var filteredEvents: [EventCellViewModel] {
        if filter == .today {
            let calendar = Calendar.current
            return allEvents.filter({ calendar.component(.weekday, from: $0.date) == calendar.component(.weekday, from: Date())})
        } else {
            return allEvents
        }
    }
    
    var filteredSubjects: [String] {
        let filteredLessonCellVM = lessonCellViewModels.filter { $0.dayOfTheWeek == dayOfTheWeek}
        let subjects = filteredLessonCellVM.map { $0.subject }
        return subjects.filter { $0 != "[EMPTY]" }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        lessonRepository.$lessons.map { lessons in
            lessons.map { lesson in
                LessonCellViewModel(lesson: lesson)
            }
        }
        .assign(to: \.lessonCellViewModels, on: self)
        .store(in: &cancellables)
        
        eventRepository.$events.map { events in
            events.map { event in
                EventCellViewModel(event: event)
            }
        }
        .assign(to: \.allEvents, on: self)
        .store(in: &cancellables)
    }
    
    func removeEvent(_ event: EventCellViewModel) {
        eventRepository.removeEvent(event.event)
    }
    
    func newEvent() {
        eventRepository.addEvent(event(subject: newEventSubject, date: newEventDate, title: newEventTitle, description: newEventDescription))
        newEventDate = Date()
        newEventSubject = ""
        newEventTitle = ""
        newEventDescription = ""
    }
    
    func doesSubjectExist(_ event: event) -> Bool{
        var day = daysOfTheWeek.mon
        let calendar = Calendar.current
        let dayNumber = calendar.component(.weekday, from: event.date)
        
        switch dayNumber {
            case 2:
                day = .mon
            case 3:
                day = .tue
            case 4:
                day = .wed
            case 5:
                day = .thu
            case 6:
                day = .fri
            default:
                day = .mon
            }
        
        let lessons = lessonCellViewModels.filter({ $0.dayOfTheWeek == day })
        
        let subjects = lessons.map { $0.subject }
        
        return subjects.contains(event.subject)
    }
}
