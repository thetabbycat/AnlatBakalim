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
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "lose2", ofType: "mp3")!))
            audioPlayer.play()
        } catch {
            
        }
    }
    
    public func right() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "point", ofType: "mp3")!))
            audioPlayer.play()
        } catch {
            
        }
    }
    
    public func newGame() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "newGame2", ofType: "mp3")!))
            audioPlayer.play()
        } catch {
            
        }
    }
    
    public func endGame() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "lose3", ofType: "mp3")!))
            audioPlayer.play()
        } catch {
            
        }
    }
    
    
    public func nextRound() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "newGame", ofType: "mp3")!))
            audioPlayer.play()
        } catch {
            
        }
    }
    
    public func menu() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "menu", ofType: "mp3")!))
            audioPlayer.play()
        } catch {
            
        }
    }
    
}
