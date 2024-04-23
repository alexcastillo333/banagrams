//
//  HomeScreenViewController.swift
//  bananagrams
//
//  Created by Abdullah Alsukhni on 3/29/24.
//

import UIKit
import CoreData
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext
class HomeScreenViewController: UIViewController {
    
    
    var email: String!
    var username = String()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let fetchedResults = retrieveUsers()
        
        for user in fetchedResults {
            if let usernameFound = user.value(forKey: "username") {
                if let emailFound = user.value(forKey: "email") {
                    if((emailFound as! String) == email) {
                        username = usernameFound as! String
                        print(username)
                    }
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func retrieveUsers() -> [NSManagedObject] {
        // retrieve all objects that meet criteria
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"User")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            print("Error occurred while retrieving data")
            abort()
        }
        
        return(fetchedResults)!
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileSegueIdentifier" {
            if let nextVC = segue.destination as? ProfileViewController {
                nextVC.email = email
                nextVC.username = username
            }
        }
        if segue.identifier == "settingsSegueIdentifier" {
            if let nextVC = segue.destination as? SettingsViewController {
                nextVC.email = email
            }
        }
        if segue.identifier == "gameSegueIdentifier" {
            if let nextVC = segue.destination as? GameViewController {
                nextVC.email = email
            }
        }
    }
     
    

}
