//
//  LobbyViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 4/25/24.
//

import UIKit
import Firebase

class LobbyViewController: UIViewController {
    
    var lobbyName: String?
    var timer: Timer?
    @IBOutlet weak var p1Label: UILabel!
    @IBOutlet weak var p2Label: UILabel!
    var ref = Database.database().reference().child("playing-online")
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.ref = self.ref.child(lobbyName ?? "LEADERBOARD USER")
        self.checkPlayers()
        self.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopTimer()
    }
    
    func startTimer() {
        self.stopTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkPlayers), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
    
    @objc func checkPlayers() {
        // Check for all current lobbies within multiplayer
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Failed to fetch data")
                return
            }
            
            // Iterate through each child and extract the name
            for child in children {
                let identifier = child.key
                if identifier == "player1" {
                    self.p1Label.text = child.value as? String
                } else if identifier == "player2" {
                    self.p2Label.text = child.value as? String
                }
            }
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "lobbyToMultiplayerSegueIdentifier" {
//            if let nextVC = segue.destination as? HomeScreenViewController {
//                
//            }
//        }
    }


}
