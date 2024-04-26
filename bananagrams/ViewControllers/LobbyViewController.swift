//
//  LobbyViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 4/25/24.
//

import UIKit
import Firebase

class LobbyViewController: UIViewController {
    var email: String?
    var username: String?
    var lobby: Lobby?
    var timer: Timer?
    @IBOutlet weak var p1Label: UILabel!
    @IBOutlet weak var p2Label: UILabel!
    var ref = Database.database().reference().child("playing-online")
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("lobby is: \(self.lobby)")
        print("lobby name: \(self.lobby!.lobbyName)")
        self.ref = self.ref.child(lobby!.lobbyName)
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
        lobby?.getPlayerName(identifier: "player1", label: self.p1Label) { playerName in
            print("p1: \(playerName)")
        }
        lobby?.getPlayerName(identifier: "player2", label: self.p2Label) { playerName in
            print("p2: \(playerName)")
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lobbyToMultiplayerSegueIdentifier" {
            if let nextVC = segue.destination as? MultiplayerViewController {
                nextVC.username = self.username!
                nextVC.email = self.email!
            }
        }
    }


}
