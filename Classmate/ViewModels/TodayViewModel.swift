//
//  TodayViewModel.swift
//  Classmate
//
//  Created by Kuba Florek on 27/10/2020.
//

import Foundation
import Combine

class TodayViewModel: ViewModel {
    /*var dayOfTheWeek: daysOfTheWeek {
        let date = Date()
        let calendar = Calendar.current
        
        let dayNumber = calendar.component(.weekday, from: date)
        
        switch dayNumber {
            case 3:
                return daysOfTheWeek.tue
            case 4:
                return daysOfTheWeek.wed
            case 5:
                return daysOfTheWeek.thu
            case 6:
                return daysOfTheWeek.fri
            default:
                return daysOfTheWeek.mon
            }
    }*/
    
    var dayOfTheWeek = daysOfTheWeek.mon
    
    var lastLesson: Date {
        var previousBreaks = breakCellViewModels.map { schoolBreak in
            schoolBreak.length
        }
        
        if filteredLessonCellViewModels.count > 0 && breakCellViewModels.count > 0 {
            previousBreaks.removeLast(breakCellViewModels.count - (filteredLessonCellViewModels.count - 1))
        }
        
        return settingsViewModel.firstLesson.addingTimeInterval(TimeInterval(filteredLessonCellViewModels.count * settingsViewModel.lessonLength * 60 + previousBreaks.reduce(0, +) * 60))
    }
    
    var filteredLessonCellViewModels: [LessonCellViewModel] {
        let filteredLessonCellVM = lessonCellViewModels.filter { $0.dayOfTheWeek == dayOfTheWeek}
        
        return filteredLessonCellVM.sorted { $0.number < $1.number }
    }
    
    var currentActivityId: String {
        var secondsUntilNextDay = settingsViewModel.firstLesson.secondsUntilTheNextDay
        
        for index in filteredLessonCellViewModels.indices {
            if (secondsUntilNextDay - Double(settingsViewModel.lessonLength * 60))...secondsUntilNextDay ~= Date().secondsUntilTheNextDay {
                return "\(index)lesson"
            } else {
                secondsUntilNextDay -= Double(settingsViewModel.lessonLength * 60)
            }
            
            if (secondsUntilNextDay - Double(breakCellViewModels[index].length * 60))...secondsUntilNextDay ~= Date().secondsUntilTheNextDay && index + 1 < filteredLessonCellViewModels.count {
                return "\(index)break"
            } else if index + 1 < filteredLessonCellViewModels.count {
                secondsUntilNextDay -= Double(breakCellViewModels[index].length * 60)
            }
        }
        
        return "0"
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //override init() {
    //    super.init()
    //    _ = self.objectWillChange.append(super.objectWillChange)
    //}
    
    func lessonAndBreakDate(_ index: Int, isLesson: Bool) -> String {
        var previousBreaks = breakCellViewModels.map { schoolBreak in
            schoolBreak.length
        }
        
        if previousBreaks.count > 0 {
            previousBreaks.removeLast(breakCellViewModels.count - index)
        }
        
        let summedBreaks = previousBreaks.reduce(0, +)
        
        let date = settingsViewModel.firstLesson.addingTimeInterval(TimeInterval((index + (isLesson ? 0 : 1)) * settingsViewModel.lessonLength * 60 + summedBreaks * 60))
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: date))\n\(formatter.string(from: date.addingTimeInterval(TimeInterval(isLesson ? settingsViewModel.lessonLength * 60 : breakCellViewModels[index].length * 60))))"
    }
    
    func activityBarMultiplier(_ index: Int, isLesson: Bool) -> Float {
        var previousBreaks = breakCellViewModels.map { schoolBreak in
            schoolBreak.length
        }
        
        if breakCellViewModels.count > 0 {
            previousBreaks.removeLast(breakCellViewModels.count - index)
        }
        
        let summedBreaks = previousBreaks.reduce(0, +)
        
        let date = settingsViewModel.firstLesson.addingTimeInterval(TimeInterval((index + (isLesson ? 0 : 1)) * settingsViewModel.lessonLength * 60 + summedBreaks * 60))
        
        let activityStartSecondsUntilNextDay = Float(date.secondsUntilTheNextDay)
        
        let activityEndSecondsUntilNextDay = Float(date.addingTimeInterval(TimeInterval(isLesson ? settingsViewModel.lessonLength * 60 : breakCellViewModels[index].length * 60)).secondsUntilTheNextDay)
        
        let secondsUntilNextDayFromNow = Float(Date().secondsUntilTheNextDay)
        
        if 0...1 ~= (secondsUntilNextDayFromNow - activityEndSecondsUntilNextDay) / (activityStartSecondsUntilNextDay - activityEndSecondsUntilNextDay) {
            return 1 - (secondsUntilNextDayFromNow - activityEndSecondsUntilNextDay) / (activityStartSecondsUntilNextDay - activityEndSecondsUntilNextDay)
        } else {
            return 0
        }
    }
}


class ViewModel: ObservableObject {
    @Published var lessonRepository = LessonRepository()
    @Published var breakRepository = BreakRepository()
    @Published var settingsRepository = SettingsRepository()
    
    @Published var lessonCellViewModels = [LessonCellViewModel]()
    @Published var breakCellViewModels = [BreakCellViewModel]()
    @Published var settingsViewModel = SettingsViewModel(settings: .defaultSettings)
    
    @Published var id = " "
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        lessonRepository.$lessons.map { lessons in
            lessons.map { lesson in
                LessonCellViewModel(lesson: lesson)
            }
        }
        .assign(to: \.lessonCellViewModels, on: self)
        .store(in: &cancellables)
        
        breakRepository.$breaks.map { schoolBreaks in
            schoolBreaks.map { schoolBreak in
                BreakCellViewModel(schoolBreak: schoolBreak)
            }
        }
        .assign(to: \.breakCellViewModels, on: self)
        .store(in: &cancellables)
        
        settingsRepository.$settings.map { settings in
            SettingsViewModel(settings: settings)
        }
        .assign(to: \.settingsViewModel, on: self)
        .store(in: &cancellables)
    }
}
