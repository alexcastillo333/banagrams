//
//  MultiplayerViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 4/25/24.
//

import UIKit
import Firebase

var counter = 1
var selectedLobby: Lobby?

class MultiplayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let ref = Database.database().reference().child("playing-online")
    var email: String?
    var username: String?
    var timer: Timer?
    var lobbyList: [Lobby] = []
    var selectedLobby: Lobby?
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(LobbyCell.self, forCellReuseIdentifier: "LobbyCell")
        checkLobbies()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkLobbies()
        print("in multi now, username is: \(self.username)")
        self.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopTimer()
    }
    
    func startTimer() {
        self.stopTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkLobbies), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
    @objc func checkLobbies() {
        // Check for all current lobbies within multiplayer
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Failed to fetch data")
                return
            }
            
            self.lobbyList.removeAll(keepingCapacity: true)
            
            // Iterate through each child and extract the name
            for child in children {
                let name = child.key
                let lobby = Lobby(lobbyName: name)
                self.lobbyList.append(lobby)
            }
            
            self.tableView.reloadData()
        }
    }
        
    @IBAction func makeLobby(_ sender: Any) {
        counter += 1
        var lobbyName = "Lobby " + String(counter)
        Lobby.createLobby(identifier: lobbyName)
        let lobby = Lobby(lobbyName: lobbyName)
        
        lobby.addPlayer(identifier: "player1", name: self.username ?? "none", deck: [])
        
        selectedLobby = lobby
        self.tableView.reloadData()
        performSegue(withIdentifier: "multiplayerToLobbySegueIdentifier", sender: sender)
    }
    
    /* Table Functions */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lobbyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LobbyCell", for: indexPath) as! LobbyCell
        
        let lobby = self.lobbyList[indexPath.row]
        cell.textLabel?.text = lobby.lobbyName
        
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lobby = lobbyList[indexPath.row]
        lobby.addPlayer(identifier: "player2", name: self.username ?? "none", deck: [])
        
        selectedLobby = lobby
        performSegue(withIdentifier: "multiplayerToLobbySegueIdentifier", sender: indexPath)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "multiplayerToHomeSegueIdentifier" {
            if let nextVC = segue.destination as? HomeScreenViewController {
                nextVC.email = self.email ?? "none"
                nextVC.username = self.username ?? "none"
            }
        } else if segue.identifier == "multiplayerToLobbySegueIdentifier" {
            if let nextVC = segue.destination as?
                LobbyViewController {
                print("selected lobby is: \(selectedLobby)")
                nextVC.lobby = selectedLobby
                nextVC.username = self.username
                nextVC.email = self.email
            }
        }
        
    }


}
