//
//  SettingsViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 4/3/24.
//

import UIKit

import AVFoundation
class AudioManager {
    static let shared = AudioManager()
    
    var audioPlayer: AVAudioPlayer?
    
    private init() {
        configureAudioPlayer()
    }
    
    func configureAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "croppedLofi", withExtension: "mp3") else {
            print("Unable to locate audio file.")
            return
        }
        do {
            print("found audio file!!")
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
        } catch {
            print("AudioPlayer error: \(error.localizedDescription)")
        }
    }
    
    func toggleMusic(_ shouldPlay: Bool) {
        if shouldPlay {
            audioPlayer?.play()
        } else {
            audioPlayer?.pause()
        }
    }
}
class SettingsViewController: UIViewController {
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var randomButton: SoundButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        musicSwitch.isOn = AudioManager.shared.audioPlayer?.isPlaying ?? false
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func darkModeSwitchFlipped(_ sender: UISwitch) {
       
    }
    
    @IBAction func soundEffectsSwitchFlipped(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "SoundEffectsEnabled")
        
    }
    
    @IBAction func randomButtonPressed(_ sender: Any) {
    }
    @IBAction func musicSwitchFlipped(_ sender: UISwitch) {
        AudioManager.shared.toggleMusic(sender.isOn)
        print("Sound effects setting changed: \(sender.isOn)")
    }
}
