//
//  SignUpViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 3/17/24.
//

import UIKit
import FirebaseAuth
import CoreData

class SignUpViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
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
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
                    // Use Firebase Auth to create a new user
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let e = error {
                            let alert = UIAlertController(title: "Sign Up Error", message: e.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            // User was created successfully, now you can do further setup for the user
                            // Segue to the next view controller once it's created
//                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                            let context = appDelegate.persistentContainer.viewContext
//                            let newUser = bananagrams.User(context: context)
////                            let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
//                            newUser.username = usernameTextField.text
//                            newUser.email = emailTextField.text
                            let alert = UIAlertController(title: "Sign Up Successful", message: "Account has been created successfully!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
    }
}
