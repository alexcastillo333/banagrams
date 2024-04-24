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
    var childList: [DataSnapshot] = []
    @IBOutlet weak var tableView: UITableView!
    let ref = Database.database().reference().child("bananagrams")
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
        // Do any additional setup after loading the view.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) { (snapshot) in
            guard snapshot.exists() else {
                print("No data available")
                return
            }

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    childList.append(childSnapshot)
                } else {
                    continue
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderBoardCellIdentifier", for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        let childSnapshot = childList[indexPath.row]
        // Access the value of the child snapshot
        if let userData = childSnapshot.value as? [String: Any] {
            // Assuming userData is a dictionary containing user data
            // Access the user data as needed
            let username = userData["username"] as? String ?? ""
            let email = userData["email"] as? String ?? ""
            let time = userData["time"] as? Int ?? Int32.max
            cell.testLabel?.text = "\(username) -- \(email) -- \(time)"
            // Do something with the user data
            print("Username: (username), Email: (email), Age: (age)")
        }
      }
        
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
