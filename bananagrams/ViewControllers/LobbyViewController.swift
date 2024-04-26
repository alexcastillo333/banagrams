//
//  LobbyViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 4/25/24.
//

import UIKit
import Firebase

class LobbyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var email: String?
    var username: String?
    var isReady: Bool = false
    var lobby: Lobby?
    var timer: Timer?
    var playerList: [String] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(LobbyCell.self, forCellReuseIdentifier: "LobbyCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkPlayers()
        self.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopTimer()
    }
    
    func startTimer() {
        self.stopTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkPlayers), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func checkPlayers() {
        // Check for all current lobbies within multiplayer
        let ref = lobby?.getReference()
        ref?.observeSingleEvent(of: .value) { (snapshot) in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Failed to fetch data")
                return
            }
            
            self.playerList.removeAll(keepingCapacity: true)
            
            // Iterate through each child and extract the name
            for child in children {
                let name = child.key
                self.playerList.append(name)
            }
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func readyPlayer(_ sender: Any) {
        self.isReady = !self.isReady
        lobby?.setReady(identifier: self.username!, ready: self.isReady)
    }
    
    
    @IBAction func leaveLobby(_ sender: Any) {
        self.lobby?.removePlayer(identifier: self.username!)
    }
    
    /* Table Functions */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        
        
        lobby?.isReady(identifier: playerList[indexPath.row]) { isReady in
            DispatchQueue.main.async {
                if isReady {
                    cell.backgroundColor = UIColor.green
                } else {
                    cell.backgroundColor = UIColor.red
                }
            }
        }
        cell.textLabel?.text = playerList[indexPath.row]
        
        return cell
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
