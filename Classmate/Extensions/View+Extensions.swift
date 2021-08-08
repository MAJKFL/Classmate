//
//  View+Extensions.swift
//  Classmate
//
//  Created by Kuba Florek on 18/10/2020.
//

import SwiftUI
import Stripes

struct CustomCorners: Shape {
    var corners : UIRectCorner
    var size : CGFloat
      
    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: size, height: size))
        
        return Path(path.cgPath)
    }
}

struct FlipEffect: GeometryEffect {

      var animatableData: Double {
            get { angle }
            set { angle = newValue }
      }

      @Binding var flipped: Bool
      var angle: Double
      let axis: (x: CGFloat, y: CGFloat)

      func effectValue(size: CGSize) -> ProjectionTransform {

            DispatchQueue.main.async {
                  self.flipped = self.angle >= 90 && self.angle < 270
            }

            let tweakedAngle = flipped ? -180 + angle : angle
            let a = CGFloat(Angle(degrees: tweakedAngle).radians)

            var transform3d = CATransform3DIdentity;
            transform3d.m34 = -1/max(size.width, size.height)

            transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
            transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)

            let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))

            return ProjectionTransform(transform3d).concatenating(affineTransform)
      }
}

struct notebookCardModifier: ViewModifier {
    let completitionBarMultiplier: Float
    let number: Float
    @State private var shadowRadius: CGFloat = 0.0
    
    let stripesConfigOne: StripesConfig
    let stripesConfigTwo: StripesConfig?
    
    func body(content: Content) -> some View {
        content
            .frame(width: UIScreen.main.bounds.width - 125, height: UIScreen.main.bounds.width - 125)
            .background(
                HStack {
                    Color.green.opacity(0.3)
                        .frame(width: (UIScreen.main.bounds.width - 125) * CGFloat(completitionBarMultiplier))
                    
                    Spacer()
                }
            )
            .background(Stripes(config: stripesConfigOne))
            .background(Stripes(config: stripesConfigTwo ?? StripesConfig.clear))
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .shadow(color: (stripesConfigTwo == nil ? Color("NotebookLabelColor") : Color("NotebookLabelColorBreak")).opacity(0.5), radius: shadowRadius, x: shadowRadius / 2, y: shadowRadius / 2)
            .onAppear {
                withAnimation(Animation.spring().delay(Double((number / 2)))) { shadowRadius = 20 }
            }
    }
}

extension View {
    func notebookCard(_ stripesConfigOne: StripesConfig, _ stripesConfigTwo: StripesConfig? = nil, completitionBarMultiplier: Float, number: Float) -> some View {
        self.modifier(notebookCardModifier(completitionBarMultiplier: completitionBarMultiplier, number: number, stripesConfigOne: stripesConfigOne, stripesConfigTwo: stripesConfigTwo))
    }
}

struct notebokLabelModifier: ViewModifier {
    let labelColor: Color
    let isOnTop: Bool
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 50, design: .rounded))
            .foregroundColor(Color("QRShadowColor"))
            .padding(20)
            .background(labelColor)
            .clipShape(CustomCorners(corners: isOnTop ? [.bottomLeft, .topRight] : [.topLeft, .bottomRight], size: 25))
            .shadow(color: labelColor, radius: 7)
    }
}

extension View {
    func notebookLabel(_ color: Color, ifFlipped isOnTop: Bool) -> some View {
        self.modifier(notebokLabelModifier(labelColor: color, isOnTop: isOnTop))
    }
}

extension StripesConfig {
    public static let `clear` = StripesConfig(background: Color.white.opacity(0), foreground: Color.white.opacity(0), degrees: 0, barWidth: 1, barSpacing: 1)
}

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}

extension View {
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}
