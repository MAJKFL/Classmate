//
//  BreakCellViewModel.swift
//  Classmate
//
//  Created by Kuba Florek on 28/10/2020.
//

import Foundation
import Combine

class BreakCellViewModel: ObservableObject, Identifiable  {
    @Published var breakRepository = BreakRepository()
    @Published var schoolBreak: schoolBreak
      
    var id: String = ""
    @Published var length = 0
    @Published var number = 0
      
    private var cancellables = Set<AnyCancellable>()
    
    init(schoolBreak: schoolBreak) {
        self.schoolBreak = schoolBreak
            
        $schoolBreak
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)

        $schoolBreak
            .map { $0.length }
            .assign(to: \.length, on: self)
            .store(in: &cancellables)
        
        $schoolBreak
            .map { $0.number }
            .assign(to: \.number, on: self)
            .store(in: &cancellables)
        
        $schoolBreak
            .dropFirst()
            .sink(receiveValue: breakRepository.updateBreak(_:))
            .store(in: &cancellables)
    }
}
