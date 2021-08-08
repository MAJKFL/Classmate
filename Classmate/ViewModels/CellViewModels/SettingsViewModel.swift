//
//  SettingsViewModel.swift
//  Classmate
//
//  Created by Kuba Florek on 14/11/2020.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject, Identifiable  {
    @Published var settingsRepository = SettingsRepository()
    @Published var settings: planSettings
      
    var id: String = ""
    @Published var firstLesson = Date()
    @Published var lessonLength = 0
    @Published var title = ""
    
    var qrCodeString: String { "\(id)/\(title)" }
      
    private var cancellables = Set<AnyCancellable>()
    
    init(settings: planSettings) {
        self.settings = settings
            
        $settings
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)

        $settings
            .map { $0.firstLesson }
            .assign(to: \.firstLesson, on: self)
            .store(in: &cancellables)
        
        $settings
            .map { $0.lessonLength }
            .assign(to: \.lessonLength, on: self)
            .store(in: &cancellables)
        
        $settings
            .map { $0.title }
            .assign(to: \.title, on: self)
            .store(in: &cancellables)
        
        $settings
            .dropFirst()
            .sink(receiveValue: settingsRepository.updateSettings(_:))
            .store(in: &cancellables)
    }
}

