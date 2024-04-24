//
//  ProfileViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 3/15/24.
//

import UIKit
import FirebaseAuth
import CoreData

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var username: String?
    var email: String?
    var topTimes: [Int32] = []
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        playerNameLabel.text = username
        loadAvatarImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerNameLabel.text = username
        loadAvatarImage()
        fetchTopTimes()
        tableView.reloadData()
    }
    
    func fetchTopTimes() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                let times = [user.time1, user.time2, user.time3, user.time4, user.time5]
                // Filter out Int32.max values and sort the remaining times
                topTimes = times.filter { $0 != Int32.max }.sorted()
                tableView.reloadData()  // Assuming 'tableView' is your UITableView's outlet
            }
        } catch let error as NSError {
            print("Could not fetch times: \(error), \(error.userInfo)")
        }
    }
    
    func loadAvatarImage() {
        guard let email = email else {
            print("Email is nil")
            imageView.image = UIImage(named: "defaultAvatar")
            return
        }

        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                print("User found: \(user.username ?? "[username not available]")")
                if let avatarData = user.avatar {
                    imageView.image = UIImage(data: avatarData)
                    print("Loaded user's avatar image")
                } else {
                    print("User's avatar image is nil, loading default")
                    imageView.image = UIImage(named: "defaultAvatar")
                }
            } else {
                print("No user found with username \(username), loading default")
                imageView.image = UIImage(named: "defaultAvatar")
            }
        } catch {
            print("ERROR LOADING IMAGE: \(error.localizedDescription)")
        }
    }

    
    @IBAction func setAvatarButtonClicked(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageView.image = pickedImage
                saveAvatarImage(pickedImage)
            }
            dismiss(animated: true, completion: nil)
    }
    
    func saveAvatarImage(_ image: UIImage) {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@", email ?? "")
            
            do {
                let results = try context.fetch(fetchRequest)
                if let user = results.first {
                    if let imageData = image.pngData() { 
                        user.avatar = imageData
                        try context.save()
                    }
                }
            } catch {
                print("ERROR SAVING IMAGE")
            }
        }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        let controller = UIAlertController(
            title: "Logout Confirmation",
            message: "Confirm Logout?",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            do {
                AudioManager.shared.toggleMusic(false)
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
//    @IBAction func signOutButtonPressed(_ sender: Any) {
//        
//        do {
//            
//            try Auth.auth().signOut()
//            performSegue(withIdentifier: "signOutSegue", sender: self)
//        } catch {
//            print("ERROR LOGGING OUT")
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topTimes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCellIdentifier", for: indexPath)
        
        let timeInSeconds = topTimes[indexPath.row]
        let minutes = timeInSeconds / 60
        let seconds = timeInSeconds % 60
        
        // Format the time as MM:SS
        cell.textLabel?.text = String(format: "%02d:%02d", minutes, seconds)
        
        return cell
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToHomeSegueIdentifier" {
            if let nextVC = segue.destination as? HomeScreenViewController {
                nextVC.username = self.username ?? "none"
                nextVC.email = self.email ?? "none"
            }
        }
    }
   

}
