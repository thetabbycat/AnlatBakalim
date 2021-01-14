//
//  Utils.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation
import StoreKit
import SwiftUI


extension View {
  
    func multicolorGlow(rotation: Int = 1) -> some View {
       
        ZStack {
            
            ForEach(0..<2) { i in
                Rectangle()
                      
                    .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                    
                    .rotationEffect(.degrees(Double(rotation * 360)))
                    
                    .animation(
                        Animation.linear(duration: 10)
                            .repeatForever(autoreverses: false)
                    )
                    .mask(self.blur(radius: 6))
                    .overlay(self.blur(radius: 4 - CGFloat(i * 10)))
                    
                    
                
            }
        }
        .frame(width: 70, height: 70)
        
    }
    
    func glow(color: Color = .red, radius: CGFloat = 20) -> some View {
        self
            .overlay(self.blur(radius: radius / 16))
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
    
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct AnimatableGradientModifier: AnimatableModifier {
    let from: [UIColor]
    let to: [UIColor]
    var interpolatedValue: CGFloat = 0
    
    var animatableData: CGFloat {
        get { interpolatedValue }
        set { interpolatedValue = newValue }
    }
    
    func body(content: Content) -> some View {
        var gColors = [Color]()
        
        for i in 0..<from.count {
            gColors.append(colorMixer(c1: from[i], c2: to[i], interpolatedValue: interpolatedValue))
        }
        
        return RoundedRectangle(cornerRadius: 8)
            .fill(LinearGradient(gradient: Gradient(colors: gColors),
                                 startPoint: UnitPoint(x: 0, y: 0),
                                 endPoint: UnitPoint(x: 0, y: 1)))
            .frame(width: 64, height: 64)
    }
    
    func colorMixer(c1: UIColor, c2: UIColor, interpolatedValue: CGFloat) -> Color {
        guard let cc1 = c1.cgColor.components else { return Color(c1) }
        guard let cc2 = c2.cgColor.components else { return Color(c1) }
        
        // messing with interpolated value, creating waves
        let alteredValue = sin(8.5*interpolatedValue*CGFloat.pi)*0.1 + interpolatedValue
        
        // computing interpolated color channels based on the value (0..1)
        let r = cc1[0]*alteredValue + cc2[0]*(1.0 - alteredValue)
        let g = cc1[1]*alteredValue + cc2[1]*(1.0 - alteredValue)
        let b = cc1[2]*alteredValue + cc2[2]*(1.0 - alteredValue)
        
        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }
}


struct ShakeEffect: GeometryEffect {
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: -10 * sin(position * 2 * .pi), y: 0))
    }
    
    init(shakes: Int) {
        position = CGFloat(shakes)
    }
    
    var position: CGFloat
    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }
}

extension UserDefaults {
    
    public func optionalInt(forKey defaultName: String) -> Int? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Int
        }
        return nil
    }
    
    public func optionalBool(forKey defaultName: String) -> Bool? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Bool
        }
        return nil
    }
}

/// Represents parts of time
struct TimeParts: CustomStringConvertible {
    var seconds = 0
    var minutes = 0
    /// The string representation of the time parts (ex: 07:37)
    var description: String {
        return NSString(format: "%02d:%02d", minutes, seconds) as String
    }
}

/// Represents unset or empty time parts
let EmptyTimeParts = 0.toTimeParts()

extension Int {
    /// The time parts for this integer represented from total seconds in time.
    /// -- returns: A TimeParts struct that describes the parts of time
    func toTimeParts() -> TimeParts {
        let seconds = self
        var mins = 0
        var secs = seconds
        if seconds >= 60 {
            mins = Int(seconds / 60)
            secs = seconds - (mins * 60)
        }
        
        return TimeParts(seconds: secs, minutes: mins)
    }
    
    /// The string representation of the time parts (ex: 07:37)
    func asTimeString() -> String {
        return toTimeParts().description
    }
}




struct StoreReviewHelper {
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        var appOpenCount = UserDefaults.standard.integer(forKey: "APP_OPENED_COUNT")
        appOpenCount += 1
        settings.set(appOpenCount, forKey: "APP_OPENED_COUNT")
    }
    static func checkAndAskForReview() { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        let appOpenCount = UserDefaults.standard.integer(forKey: "APP_OPENED_COUNT")
        
        switch appOpenCount {
            case 10,50:
                StoreReviewHelper().requestReview()
            case _ where appOpenCount%100 == 0 :
                StoreReviewHelper().requestReview()
            default:
           //     print("App run count is : \(appOpenCount)")
                break;
        }
        
    }
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            // Try any other 3rd party or manual method here.
        }
    }
}
