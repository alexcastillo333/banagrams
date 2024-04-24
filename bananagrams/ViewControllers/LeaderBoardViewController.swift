//
//  LeaderBoardViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 4/23/24.
//

import UIKit
import Firebase

class CustomTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var testLabel: UILabel!
    
}



class LeaderBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    struct TimeEntry {
            var username: String
            var time: Int32
    }
    var leaderboardEntries: [TimeEntry] = []
    var email: String?
    @IBOutlet weak var tableView: UITableView!
    let ref = Database.database().reference().child("bananagrams")
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.getStatistics()
    }
        // Do any additional setup after loading the view.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getStatistics()
    }
    
    @IBAction func updateStats(_ sender: Any) {
        self.getStatistics()
    }
    
    func getStatistics() {
        ref.observeSingleEvent(of: .value) { snapshot in
            var allTimes: [TimeEntry] = []

            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                      let userData = childSnapshot.value as? [String: Any],
                      let username = userData["username"] as? String,
                      let bestTimes = userData["bestTimes"] as? [Int32] else {
                    continue
                }
                
                // Add all times for the user to the allTimes array
                for time in bestTimes where time != Int32.max {
                    allTimes.append(TimeEntry(username: username, time: time))
                }
            }

            // Sort the array by time in ascending order (lowest time first)
            allTimes.sort { $0.time < $1.time }
            
            // Take the top 10 times
            self.leaderboardEntries = Array(allTimes.prefix(10))
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
            
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the count of leaderboard entries
        return leaderboardEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell of the correct type
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderBoardCellIdentifier", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        // Get the corresponding TimeEntry from leaderboardEntries
        let timeEntry = leaderboardEntries[indexPath.row]
        
        // Convert the time into minutes and seconds
        let minutes = timeEntry.time / 60
        let seconds = timeEntry.time % 60
        
        // Set the cell's label to show the username and time in a "MM:SS" format
        cell.testLabel?.text = "\(timeEntry.username) -- \(String(format: "%02d:%02d", minutes, seconds))"
        
        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "leaderboardToHomeSegueIdentifier" {
            if let nextVC = segue.destination as? HomeScreenViewController {
                nextVC.email = self.email ?? "none"
            }
        }
    }

}
