//
//  ProfileViewController.swift
//  bananagrams
//
//  Created by Aaron Posadas on 3/15/24.
//

import UIKit
import FirebaseAuth
import CoreData

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var username: String?
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        playerNameLabel.text = username
        loadAvatarImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playerNameLabel.text = username
        loadAvatarImage()
    }

    
    func loadAvatarImage() {
        guard let username = username else {
            print("Username is nil")
            imageView.image = UIImage(named: "defaultAvatar")
            return
        }

        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)

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
            fetchRequest.predicate = NSPredicate(format: "username == %@", username ?? "")
            
            do {
                let results = try context.fetch(fetchRequest)
                if let user = results.first {
                    if let imageData = image.pngData() { // You can also use jpegData(compressionQuality:) if you prefer
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
