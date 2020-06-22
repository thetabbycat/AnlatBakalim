//
//  SoundEffects.swift
//  AnlatBakalim
//
//  Created by Steven J. Selcuk on 6.06.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class SoundManager: ObservableObject {
    
    var audioPlayer = AVAudioPlayer()
    
    
    public func wrong() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "crumbling", ofType: "mp3")!))
            audioPlayer.play()
        } catch {
            
        }
    }
    
}
