//
//  LessonCellView.swift
//  Classmate
//
//  Created by Kuba Florek on 15/11/2020.
//

import SwiftUI
import Stripes

struct LessonCellView: View {
    @ObservedObject var lessonCellVM: LessonCellViewModel
    
    let stripesConfig = StripesConfig(background: Color("NotebookBackgroundColor"), foreground: Color("NotebookForegroundColor"), degrees: 90, barWidth: 3, barSpacing: 45)
    
    @State private var flipped = false
    @State private var animate3d = false
    @State private var completitionBarMultiplier: Float = 0
    @State var isViewDisplayed = false
    
    let lessonDate: String
    let getMultiplier: (Int, Bool) -> Float
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        Button(action: { withAnimation(Animation.spring()) { self.animate3d.toggle()}}) {
            ZStack {
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "\(lessonCellVM.number).circle")
                            .notebookLabel(Color("NotebookLabelColor"), ifFlipped: false)
                        
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(lessonCellVM.subject != "[EMPTY]" ? lessonCellVM.classroom : "Take a break😎")
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.leading)
                                
                            Text(lessonCellVM.subject != "[EMPTY]" ? lessonCellVM.subject : "")
                                .foregroundColor(.green)
                        }
                        .font(Font.system(size: 50, design: .rounded))
                        .padding(.leading)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .notebookCard(stripesConfig, completitionBarMultiplier: completitionBarMultiplier, number: Float(lessonCellVM.number))
                .opacity(flipped ? 0.0 : 1.0)
                
                VStack(alignment: .trailing) {
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        Image(systemName: "calendar.badge.clock")
                            .notebookLabel(Color("NotebookLabelColor"), ifFlipped: true)
                            .onTapGesture {
                                print("tap")
                            }
                        
                        Spacer()
                        
                        Text(lessonDate)
                            .font(.title)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.yellow)
                            .padding()
                    }
                }
                .notebookCard(stripesConfig, completitionBarMultiplier: completitionBarMultiplier, number: Float(lessonCellVM.number))
                .opacity(flipped ? 1.0 : 0.0)
            }
            .modifier(FlipEffect(flipped: $flipped, angle: animate3d ? 180 : 0, axis: (x: 1, y: 0)))
            .onReceive(timer) { _ in setMultiplier() }
            .onAppear { isViewDisplayed = true }
            .onDisappear { isViewDisplayed = false }
        }
    }
    
    func setMultiplier() {
        if isViewDisplayed {
            withAnimation(.spring()) { completitionBarMultiplier = getMultiplier(lessonCellVM.number - 1, true) }
        }
    }
}
