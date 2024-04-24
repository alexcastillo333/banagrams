//
//  SettingsViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 4/3/24.
//

import UIKit

import AVFoundation
import CoreData
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
        print("toggleMusic called with \(shouldPlay)")
        if let player = audioPlayer {
            if shouldPlay {
                audioPlayer?.play()
            } else {
                audioPlayer?.pause()
            }
        } else {
            print("Audio player is nil")
        }
    }
}
class SettingsViewController: UIViewController {
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var colorThemeButton: UIButton!
    @IBOutlet weak var soundFXSwitch: UISwitch!
    var email: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupColorThemeDropdown()
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                musicSwitch.isOn = user.musicOn
                soundFXSwitch.isOn = user.soundEffectsOn
                AudioManager.shared.toggleMusic(user.musicOn)
            }
        } catch {
            print("Error fetching user settings: \(error.localizedDescription)")
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func setupColorThemeDropdown() {
        let colorActions = [
            
            UIAction(title: "Violet and Pink") { _ in
                self.saveSelectedColorTheme(theme: "theme3")
            },
            
            UIAction(title: "White and Black") { _ in
                self.saveSelectedColorTheme(theme: "theme2")
            },
            UIAction(title: "Default") { _ in
                self.saveSelectedColorTheme(theme: "theme1")
            }
        ]

        let menu = UIMenu(title: "Select Game Color", options: .displayInline, children: colorActions)
        colorThemeButton.menu = menu
        colorThemeButton.showsMenuAsPrimaryAction = true
    }
    
    func saveSelectedColorTheme(theme: String) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email ?? "")
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                user.colors = theme
                try context.save()
                print("for email \(email) color saved = \(theme)")
            }
        } catch {
            print("ERROR SAVING IMAGE")
        }
        
    }
    
    
    @IBAction func soundEffectsSwitchFlipped(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "SoundEffectsEnabled")
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email ?? "")
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                user.soundEffectsOn = sender.isOn
                try context.save()
                print("Sound effect changed")
            }
        } catch {
            print("ERROR CHANGING SOUND FX")
        }
        
    }
    

    @IBAction func musicSwitchFlipped(_ sender: UISwitch) {
        AudioManager.shared.toggleMusic(sender.isOn)
        // Update CoreData
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                user.musicOn = sender.isOn
                try context.save()
                print("Music setting updated: \(sender.isOn)")
            }
        } catch {
            print("Error updating music setting: \(error.localizedDescription)")
        }
    }
}
