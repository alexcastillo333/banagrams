//
//  ProfileViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 3/15/24.
//

import UIKit
import FirebaseAuth
import CoreData
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var username: String?
    var email: String?
    var topTimes: [Int] = []
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let ref = Database.database().reference().child("bananagrams")
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
        ref.child(username!).observeSingleEvent(of: .value, with: { snapshot in
            guard let userData = snapshot.value as? [String: Any],
                  let username = userData["username"] as? String,
                  var times = userData["bestTimes"] as? [Int] else {
                return
            }
            self.topTimes = times.filter { $0 != Int.max }.sorted()
                self.tableView.reloadData()
            })
    }
    
    func loadAvatarImage() {
        ref.child(username!).observeSingleEvent(of: .value, with: { snapshot in
            guard let userData = snapshot.value as? [String: Any],
                  let avatarURLString = userData["avatar"] as? String,
                  let url = URL(string: avatarURLString) else {
                DispatchQueue.main.async {
                    print("User data is missing or avatar URL is not available.")
                    self.imageView.image = UIImage(named: "defaultAvatar")
                }
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        print("Failed to load the avatar image, setting to default")
                        self.imageView.image = UIImage(named: "defaultAvatar")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }.resume()
        })
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
    
//    func saveAvatarImage(_ image: UIImage) {
//            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "email == %@", email ?? "")
//            
//            do {
//                let results = try context.fetch(fetchRequest)
//                if let user = results.first {
//                    if let imageData = image.pngData() { 
//                        user.avatar = imageData
//                        try context.save()
//                    }
//                }
//            } catch {
//                print("ERROR SAVING IMAGE")
//            }
//        }
    func saveAvatarImage(_ image: UIImage) {
            guard let imageData = image.jpegData(compressionQuality: 0.75) else {
                print("Could not get JPEG representation of UIImage")
                return
            }
            
            let storageRef = Storage.storage().reference()
            let avatarRef = storageRef.child("avatars/\(username!).jpg")

            avatarRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                
                avatarRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        print("Could not get download URL")
                        return
                    }
                    
                    self.ref.child(self.username!).updateChildValues(["avatar": downloadURL.absoluteString]) { error, _ in
                        if let error = error {
                            print("Error updating avatar URL: \(error.localizedDescription)")
                        } else {
                            print("Avatar URL updated successfully")
                        }
                    }
                }
            }
        }


//    2. Update Firebase Realtime Database
//    Here's the helper method to update the user's avatar URL in Firebase Realtime Database:
//
//    swift
//    Copy code
    func updateAvatarURLInDatabase(email: String, url: String) {
        // Locate the user by email and update the avatar URL
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
            if let userSnapshot = snapshot.children.allObjects.first as? DataSnapshot {
                userSnapshot.ref.updateChildValues(["avatar": url])
                print("Avatar URL updated successfully")
            } else {
                print("User not found or avatar URL is missing for email: \(email)")
            }
        })
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
