//
//  LeaderBoardViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 4/23/24.
//

import UIKit
import Firebase
import CoreData
import FirebaseStorage


struct TimeEntry {
    var username: String
    var time: Int
    var avatar: String
}

class CustomTableViewCell: UITableViewCell {
    let ref = Database.database().reference().child("bananagrams")
    let storageRef = Storage.storage().reference()
    let placeImageView = UIImageView()
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var cellLabelTime: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addSubview(placeImageView) // Add the placeImageView to the cell's view hierarchy
        placeImageView.isHidden = false // Make sure it's not hidden
        placeImageView.alpha = 1.0 // Make sure it's fully opaque
        bringSubviewToFront(placeImageView)
    }
    
    func configure(with entry: TimeEntry, index: Int) {
        let minutes = entry.time / 60
        let seconds = entry.time % 60
        cellLabelTime?.text =  "Time: " + (String(format: "%02d:%02d", minutes, seconds))
        cellLabel?.text = entry.username
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2 // Make the imageView round
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill // Maintain aspect ratio
        if index == 0 {
            placeImageView.image = UIImage(named: "firstplace")
        } else if index == 1 {
            placeImageView.image = UIImage(named: "secondplace")
        } else if index == 2 {
            placeImageView.image = UIImage(named: "thirdplace")
        } else {
            placeImageView.image = UIImage(named: "medal4th-10th")
        }
        loadAvatarImage(avatar: entry.avatar)
        
    }
    
    func loadAvatarImage(avatar: String) {
        guard let url = URL(string: avatar) else {
            // Handle the case where the URL is not valid
            print("Invalid URL for avatar")
            self.avatarImageView.image = UIImage(named: "defaultAvatar")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    // Handle the error case
                    print("Failed to load the avatar image, setting to default")
                    self.avatarImageView.image = UIImage(named: "defaultAvatar")
                }
                return
            }
            
            DispatchQueue.main.async {
                // Set the downloaded image to the avatarImageView
                if let image = UIImage(data: data) {
                    self.avatarImageView.image = image
                } else {
                    print("Downloaded data is not an image")
                    self.avatarImageView.image = UIImage(named: "defaultAvatar")
                }
            }
        }.resume()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageViewSize = avatarImageView.frame.size
        let cellSize = contentView.frame.size
        avatarImageView.frame.origin.y = (cellSize.height - imageViewSize.height) / 2
        
        let cellPadding: CGFloat = 10 // You can adjust the padding as needed
        let imageSize = CGSize(width: 60, height: 60) // Increase the width and height as needed

        let imageX = bounds.minX + cellPadding // Use padding for x position
        let imageY = (contentView.bounds.height - imageSize.height) / 2 // Center it vertically

        placeImageView.frame = CGRect(x: imageX, y: imageY, width: imageSize.width, height: imageSize.height)
        placeImageView.contentMode = .scaleAspectFit // Maintain aspect ratio
        placeImageView.backgroundColor = .clear

    }
}



class LeaderBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var leaderboardEntries: [TimeEntry] = []
    var email: String?
    @IBOutlet weak var tableView: UITableView!
    let ref = Database.database().reference().child("bananagrams")
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100 
        tableView.rowHeight = UITableView.automaticDimension
        
        self.getStatistics()
    }
        // Do any additional setup after loading the view.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getStatistics()
    }
    
    
    func getStatistics() {
        ref.observeSingleEvent(of: .value) { snapshot in
            var allTimes: [TimeEntry] = []

            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                      let userData = childSnapshot.value as? [String: Any],
                      let username = userData["username"] as? String,
                      let bestTimes = userData["bestTimes"] as? [Int],
                      let avatar = userData["avatar"] as? String else {
                    continue
                }
                
                // Add all times for the user to the allTimes array
                for time in bestTimes where time != Int.max {
                    allTimes.append(TimeEntry(username: username, time: time, avatar: avatar))
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderBoardCellIdentifier", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        
        // Get the corresponding TimeEntry from leaderboardEntries
        let timeEntry = leaderboardEntries[indexPath.row]
        
        cell.configure(with: timeEntry, index: indexPath.row)
        cell.layoutIfNeeded()
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
