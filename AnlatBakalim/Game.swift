//
//  Game.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 20.06.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation

class GameManager: ObservableObject {
    
    // MARK: - Default Variables
    @Published var fulltime = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
    @Published var fullBreakTime = UserDefaults.standard.optionalInt(forKey: "fullBreakTime") ?? 600
    @Published var fullround = UserDefaults.standard.optionalInt(forKey: "round") ?? 5
    
    @Published var ended = false
    @Published var teamBlue = 0
    @Published var teamRed = 0
    @Published var currentTeam = "red"
    
    
    // MARK: - Active Variables
    @Published var timeRemaining = 0
    @Published var breakTime = 0
    @Published var round = 5
    // MARK: - Mechanic Variables
    @Published var isActive = false
    @Published var isBreakActive = false
    // MARK: - Settings
    @Published var playSound:Bool = UserDefaults.standard.optionalBool(forKey: "playsound") ?? true {
        didSet {
            settings.set(playSound, forKey: "playsound")
        }
    }
    @Published var showNotifications:Bool = UserDefaults.standard.optionalBool(forKey: "shownotifications") ?? true {
        didSet {
            settings.set(showNotifications, forKey: "shownotifications")
        }
    }
    
    
    
    // MARK: - Int to Human Readable Time String
    func textForPlaybackTime(time: TimeInterval) -> String {
        if !time.isNormal {
            return "00:00"
        }
        let hours = Int(floor(time / 3600))
        let minutes = Int(floor((time / 60).truncatingRemainder(dividingBy: 60)))
        let seconds = Int(floor(time.truncatingRemainder(dividingBy: 60)))
        let minutesAndSeconds = NSString(format: "%02d:%02d", minutes, seconds) as String
        if hours > 0 {
            return NSString(format: "%02d:%@", hours, minutesAndSeconds) as String
        } else {
            return minutesAndSeconds
        }
    }
}



