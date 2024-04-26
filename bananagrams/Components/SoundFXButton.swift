//
//  SoundFXButton.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 4/3/24.
//

import UIKit
import AVFoundation
var audioPlayerSX: AVAudioPlayer?
class SoundButton: UIButton {
    
    // Override the method to play sound effect
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        super.sendAction(action, to: target, for: event)
        if UserDefaults.standard.bool(forKey: "SoundEffectsEnabled") {
                    // Play sound effect
                    playSoundEffect(named: "monkey sound effect-[AudioTrimmer.com]")
                }
        
        
        
       
    }
    private func playSoundEffect(named fileName: String) {
            guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
                print("Unable to locate sound effect file.")
                return
            }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("SoundEffectPlayer error: \(error.localizedDescription)")
            }
        }
}
