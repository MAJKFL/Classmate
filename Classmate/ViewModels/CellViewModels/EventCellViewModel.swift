//
//  EventCellViewModel.swift
//  Classmate
//
//  Created by Kuba Florek on 09/12/2020.
//

import Foundation
import Combine

class EventCellViewModel: ObservableObject, Identifiable  {
    @Published var event: event
      
    var id: String = ""
    @Published var subject = ""
    @Published var date = Date()
    @Published var title = ""
    @Published var description = ""
      
    private var cancellables = Set<AnyCancellable>()
    
    init(event: event) {
        self.event = event
            
        $event
            .map { $0.subject }
            .assign(to: \.subject, on: self)
            .store(in: &cancellables)

        $event
            .map { $0.date }
            .assign(to: \.date, on: self)
            .store(in: &cancellables)
        
        $event
            .map { $0.title }
            .assign(to: \.title, on: self)
            .store(in: &cancellables)
        
        $event
            .map { $0.description }
            .assign(to: \.description, on: self)
            .store(in: &cancellables)
        
        $event
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
    }
}

