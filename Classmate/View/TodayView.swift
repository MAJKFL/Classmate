//
//  TodayView.swift
//  Classmate
//
//  Created by Kuba Florek on 27/10/2020.
//

import SwiftUI
import Stripes
import CoreImage.CIFilterBuiltins

struct TodayView: View {
    @StateObject var TodayVM = TodayViewModel()
    @State private var showQR = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { reader in
                    VStack(spacing: 40) {
                        Text(TodayVM.settingsViewModel.firstLesson, style: .time)
                            .font(Font.system(size: 50, design: .rounded))
                            .frame(width: UIScreen.main.bounds.width - 50, height: 100)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .shadow(color: Color.green.opacity(0.5), radius: 10, x: 5, y: 5)
                            .padding(.top, 15)
                            .id("0")
                        
                        ForEach(TodayVM.filteredLessonCellViewModels.indices, id: \.self) { index in
                            LessonCellView(lessonCellVM: TodayVM.filteredLessonCellViewModels[index], lessonDate: TodayVM.lessonAndBreakDate(index, isLesson: true), getMultiplier: TodayVM.activityBarMultiplier)
                                .id("\(index)lesson")
                            
                            if index + 1 < TodayVM.filteredLessonCellViewModels.count && TodayVM.breakCellViewModels.count > 0 {
                                BreakCellView(breakCellVM: TodayVM.breakCellViewModels[index], breakDate: TodayVM.lessonAndBreakDate(index, isLesson: false), getMultiplier: TodayVM.activityBarMultiplier)
                                    .id("\(index)break")
                            }
                        }
                        
                        Text(TodayVM.lastLesson, style: .time)
                            .font(Font.system(size: 50, design: .rounded))
                            .frame(width: UIScreen.main.bounds.width - 50, height: 100)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                            .shadow(color: Color.red.opacity(0.5), radius: 10, x: 5, y: 5)
                            .padding(.bottom, 15)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .onAppear {
                        reader.scrollTo(TodayVM.currentActivityId)
                    }
                }
            }
            .navigationBarTitle(TodayVM.settingsViewModel.title, displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                showQR = true
            }) {
                Image(systemName: "qrcode")
            }, trailing: NavigationLink(destination: EventInspectorView(), label: { Image(systemName: "calendar") }))
            .sheet(isPresented: $showQR) {
                QRCodeView(settingsVM: TodayVM.settingsViewModel)
            }
        }
    }
}

struct QRCodeView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    let defaultBrightness = UIScreen.main.brightness
    let imageSaver = ImageSaver()
    @State private var showShareSheet = false
    @State private var shadowRadius: CGFloat = 0.0
    
    var body: some View {
        VStack(spacing: 30) {
            Text(settingsVM.title)
                .multilineTextAlignment(.center)
            
            Image(uiImage: generateQRCode(from: settingsVM.qrCodeString))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .contextMenu {
                    Button(action: {
                        imageSaver.writeToPhotoAlbum(image: generateQRCode(from: settingsVM.qrCodeString))
                    }) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save QR")
                    }
                }
                .padding(7)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .shadow(color: Color("QRShadowColor").opacity(0.35), radius: shadowRadius, x: shadowRadius / 2, y: shadowRadius / 2)
            
            Text(settingsVM.qrCodeString)
                .font(.title2)
                .multilineTextAlignment(.center)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = settingsVM.qrCodeString
                    }) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy ID")
                    }
                }
            
            Button(action: {
                showShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
            }
        }
        .font(.largeTitle)
        .onAppear {
            withAnimation(Animation.easeIn.delay(0.6)) { shadowRadius = 20 }
            UIScreen.main.brightness = CGFloat(1)
        }
        .onDisappear {
            UIScreen.main.brightness = defaultBrightness
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: ["Hi, check out my plan in Classmate app! My plans id is: \(settingsVM.qrCodeString)", generateQRCode(from: settingsVM.qrCodeString)])
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        let transform = CGAffineTransform(scaleX: 14, y: 14)
        
        if let outputImage = filter.outputImage?.transformed(by: transform) {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
