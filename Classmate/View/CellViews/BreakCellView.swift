//
//  BreakCellView.swift
//  Classmate
//
//  Created by Kuba Florek on 15/11/2020.
//

import SwiftUI
import Stripes

struct BreakCellView: View {
    @ObservedObject var breakCellVM: BreakCellViewModel
    @State private var completitionBarMultiplier: Float = 0
    let stripesConfigHorizontal = StripesConfig(background: Color("NotebookBackgroundColor"), foreground: Color("NotebookForegroundColor"), degrees: 90, barWidth: 3, barSpacing: 45)
    let stripesConfigVertical = StripesConfig(background: Color.white.opacity(0), foreground: Color("NotebookForegroundColor"), degrees: 0, barWidth: 3, barSpacing: 45)
    
    @State private var flipped = false
    @State private var animate3d = false
    @State var isViewDisplayed = false
    
    let breakDate: String
    
    let getMultiplier: (Int, Bool) -> Float
    
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        if breakCellVM.length != 0 {
            Button(action: { withAnimation(Animation.spring()) { self.animate3d.toggle()}}) {
                ZStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom) {
                            Image(systemName: "\(breakCellVM.number).square")
                                .notebookLabel(Color("NotebookLabelColorBreak"), ifFlipped: false)
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        Text("\(breakCellVM.length)min")
                            .font(Font.system(size: 70, design: .rounded))
                            .foregroundColor(.orange)
                            .padding()
                    }
                    .notebookCard(stripesConfigVertical, stripesConfigHorizontal, completitionBarMultiplier: completitionBarMultiplier, number: Float(breakCellVM.number) + 0.5)
                    .opacity(flipped ? 0.0 : 1.0)
                    
                    VStack(alignment: .trailing) {
                        Text(breakDate)
                            .font(Font.system(size: 50, design: .rounded))
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.yellow)
                            .padding()
                        
                        Spacer()
                        
                        HStack(alignment: .bottom) {
                            Image(systemName: "clock")
                                .notebookLabel(Color("NotebookLabelColorBreak"), ifFlipped: true)
                            
                            Spacer()
                        }
                    }
                    .notebookCard(stripesConfigVertical, stripesConfigHorizontal, completitionBarMultiplier: completitionBarMultiplier, number: Float(breakCellVM.number) + 0.5)
                        .opacity(flipped ? 1.0 : 0.0)
                }
                .modifier(FlipEffect(flipped: $flipped, angle: animate3d ? 180 : 0, axis: (x: 1, y: 0)))
                .onReceive(timer) { _ in setMultiplier() }
                .onAppear { isViewDisplayed = true }
                .onDisappear { isViewDisplayed = false }
            }
        }
    }
    
    func setMultiplier() {
        if isViewDisplayed {
            withAnimation(.spring()) { completitionBarMultiplier = getMultiplier(breakCellVM.number - 1, false) }
        }
    }
}
