//
//  ProfileViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 3/15/24.
//

import UIKit
import FirebaseAuth
class ProfileViewController: UIViewController {
    var username: String?
    @IBOutlet weak var playerNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        playerNameLabel.text = username
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        let controller = UIAlertController(
            title: "Logout Confirmation",
            message: "Confirm Logout?",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "logoutSegueIdentifier", sender: self)
            } catch {
                print("ERROR LOGGING OUT")
            }
        }
        controller.addAction(okAction)

        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(cancelAction)

        present(controller, animated: true)
        
    }
    @IBAction func signOutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOutSegue", sender: self)
        } catch {
            print("ERROR LOGGING OUT")
        }
        
        
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
