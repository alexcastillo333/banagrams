//
//  SignUpViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 3/17/24.
//

import UIKit
import FirebaseAuth


class SignUpViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                            // TODO: Segue to the next view controller once it's created
                            let alert = UIAlertController(title: "Sign Up Successful", message: "Account has been created successfully!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
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
