//
//  Utils.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 8.05.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation
import StoreKit

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
