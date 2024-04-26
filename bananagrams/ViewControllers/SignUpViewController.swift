//
//  SignUpViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 3/17/24.
//

import UIKit
import FirebaseAuth
import CoreData
import Firebase
import FirebaseStorage

let appDelegateSignUp = UIApplication.shared.delegate as! AppDelegate
let contextSignUp = appDelegateSignUp.persistentContainer.viewContext
let ref = Database.database().reference().child("bananagrams")
let storageRef = Storage.storage().reference()

class SignUpViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var email = String()
    
    private var loadingIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add brown rounded borders to text fields
        passwordTextField.layer.borderWidth = 2
        passwordTextField.layer.borderColor = CGColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        passwordTextField.layer.cornerRadius = 7
        usernameTextField.layer.borderWidth = 2
        usernameTextField.layer.borderColor = CGColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        usernameTextField.layer.cornerRadius = 7
        emailTextField.layer.borderWidth = 2
        emailTextField.layer.borderColor = CGColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        emailTextField.layer.cornerRadius = 7
        setupUI()
    }
    
    func setupUI() {
            // Initialize the loading indicator
            loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator?.center = self.view.center
            loadingIndicator?.hidesWhenStopped = true
            loadingIndicator?.color = UIColor.brown
            view.addSubview(loadingIndicator!)
        }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let username = usernameTextField.text else {
                // Handle empty fields error
                return
            }

            // First, check if the username already exists
        ref.child(username).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    // Username already exists, present an alert
                    let alert = UIAlertController(title: "Sign Up Error", message: "Username already in use. Please choose a different one.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    // Username is unique, proceed with creating the Firebase Auth user
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let e = error {
                            // Handle error in user creation
                            let alert = UIAlertController(title: "Sign Up Error", message: e.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            // User was created successfully, now save their data to Firebase and CoreData
                            self.email = email
                            self.loadingIndicator?.startAnimating()
                            self.saveToFirebase(email: email, username: username, uid: authResult!.user.uid)
                            self.saveToCoreData(email: email, username: username)
                            let alert = UIAlertController(title: "Sign Up Successful", message: "Account has been created successfully!", preferredStyle: .alert)
                            // Show a spinner within the alert
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:  { _ in
                                self.performSegue(withIdentifier: "toHomeSegueIdentifier", sender: self)
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
            })
                
    }
    
    

    func saveToFirebase(email: String, username: String, uid: String) {
        // URL to the default avatar image stored in Firebase Storage
        let defaultAvatarURL = "https://firebasestorage.googleapis.com/v0/b/bananagrams-9e7d3.appspot.com/o/defaultAvatar.png?alt=media&token=2d82070a-011c-4447-84d4-c5dd69e44ad0"

        // Set the user data in Firebase, including the default avatar URL
        ref.child(username).setValue([
            "username": username,
            "email": email,
            "request": uid,
            "bestTimes": [Int.max, Int.max, Int.max, Int.max, Int.max],
            "avatar": defaultAvatarURL  // Include the avatar URL
        ]) { (error, ref) in
            if let error = error {
                print("Data could not be saved: \(error.localizedDescription)")
            } else {
                print("Data saved successfully")
            }
        }
    }

    
    


    func saveToCoreData(email: String, username: String) {
        let userStored = NSEntityDescription.insertNewObject(forEntityName: "User", into: contextSignUp)
        userStored.setValue(username, forKey: "username")
        userStored.setValue(email, forKey:"email")
        userStored.setValue("theme1", forKey:"colors")
        userStored.setValue(false, forKey: "musicOn")
        userStored.setValue(false, forKey: "soundEffectsOn")
        // Set other attributes as needed
        do {
            try contextSignUp.save()
            print("User data saved to Core Data")
        } catch {
            print("Error saving user data: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHomeSegueIdentifier" {
            if let nextVC = segue.destination as? HomeScreenViewController {
                nextVC.email = self.email
            }
        }
    }
}



