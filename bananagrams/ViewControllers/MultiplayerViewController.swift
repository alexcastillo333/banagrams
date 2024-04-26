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
    var lobbyList: [String] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LobbyCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
    
    /* Table Functions */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lobbyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LobbyCell", for: indexPath)
        
        cell.textLabel?.text = self.lobbyList[indexPath.row]
        
      
        return cell
    }
        
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "multiplayerToHomeSegueIdentifier" {
            if let nextVC = segue.destination as? HomeScreenViewController {
                nextVC.email = self.email ?? "none"
                nextVC.username = self.username ?? "none"
            }
        }
    }


}
