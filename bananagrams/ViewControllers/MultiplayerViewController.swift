//
//  MultiplayerViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 4/25/24.
//

import UIKit
import Firebase
class MultiplayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let ref = Database.database().reference().child("playing-online")
    var email: String?
    var username: String?
    var timer: Timer?
    var lobbyCount: Int = 1
    var lobbyList: [String] = []
    var selectedLobby: String = ""
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
                self.lobbyList.append(name)
            }
            
            self.tableView.reloadData()
        }
    }
        
    @IBAction func makeLobby(_ sender: Any) {
        let lobbyName = "Lobby " + String(self.lobbyCount)
        self.lobbyList.append(lobbyName)
        self.lobbyCount += 1
        
        self.ref.child(lobbyName).setValue([
            "player1": self.username ?? "No player found.",
            "player2": "No player found.",
            "deck": []
        ]) { (error, ref) in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
            } else {
                print("Data saved successfully")
            }
        }
        
        self.selectedLobby = lobbyName
        self.tableView.reloadData()
        performSegue(withIdentifier: "multiplayerToLobbySegueIdentifier", sender: sender)
    }
    
    /* Table Functions */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lobbyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LobbyCell", for: indexPath) as! LobbyCell
        
        cell.textLabel?.text = self.lobbyList[indexPath.row]
        
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lobbyName = lobbyList[indexPath.row]
        let lobbyP2Ref = self.ref.child("\(lobbyName)/player2")
//        lobbyP2Ref.setValue(self.username) { (error, _) in
//            if let error = error {
//                print("Error in inserting p2 name: \(error.localizedDescription)")
//            } else {
//                print("P2 inserted!")
//            }
//        }
        
        self.selectedLobby = lobbyName
        print("before segue")
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
                nextVC.lobbyName = self.selectedLobby
            }
        }
        
    }


}
