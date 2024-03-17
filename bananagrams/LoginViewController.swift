//
//  LoginViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 3/17/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error {
                    let alert = UIAlertController(title: "Login Error", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                } else {
                    // Login was successful, segue to the next screen or dismiss
                    print("User logged in successfully")
                    // self?.performSegue(withIdentifier: "loggedInSegueIdentifier", sender: self)
                }
            }
        }
    }
    
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "signUpSegueIdentifier" {
//                
//        }
//    }
    
}
