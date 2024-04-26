//
//  NewGameViewController.swift
//  bananagrams
//
//  Created by Taqi Hossain on 4/22/24.
//

import UIKit

class NewGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var selectedDeckLabel: UILabel!
    var deckSpec:[Int]?
    var username: String?
    var email: String?
    
    let options = ["Default Deck", "My Deck 1", "Two-man Deck", "Special Deck", "Easy Deck", "No Vowels", "Only Vowels"]
    
                //  a b c d e f g h i j k l m n o p q r s t u v w x y z
    var easydeck = [3,1,0,0,0,0,1,0,0,0,0,0,1,2,0,0,0,1,1,0,0,0,0,0,0,0]
    var easiest = [2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var isDropdownVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        // Initially hide the table view
        tableView.alpha = 0.0
        
        // Set border properties
        tableView.layer.borderWidth = 2.0
        tableView.layer.borderColor = UIColor.brown.cgColor
        tableView.layer.cornerRadius = 5.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let height = min(200, tableView.contentSize.height)
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: height)
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        let height = min(200, tableView.contentSize.height)
         tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: height)
         tableView.reloadData()
    }
    
    @IBAction func onDropDownButtonPress(_ sender: Any) {
        // Toggle the visibility of the table view
        isDropdownVisible.toggle()
        if isDropdownVisible {
            // If dropdown is visible, fade in the table view & out the label
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 1.0
                self.selectedDeckLabel.alpha = 0.0
            }
        } else {
            // If dropdown is not visible, fade out the table view & in the label
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 0.0
                self.selectedDeckLabel.alpha = 1.0
            }
        }
    }
    
    @IBAction func onStartGamePress(_ sender: Any) {
        // TODO: segue to GameViewController
    }
    
    // MARK: - TableView methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deckCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Hide the table view when an option is selected
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = 0.0
            self.selectedDeckLabel.alpha = 1.0
        }
        isDropdownVisible = false
        // Perform any action needed when an option is selected
        // For example, update the selected option label
        selectedDeckLabel.text = options[indexPath.row]
        if options[indexPath.row] == "Default Deck" {
            deckSpec = nil
        } else if options[indexPath.row] == "Easy Deck" {
            deckSpec = easiest
        } else {
            deckSpec = easydeck
        }
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameSegueIdentifier" {
            if let nextVC = segue.destination as? GameViewController {
                nextVC.email = email
                nextVC.username = username
                if deckSpec != nil {
                    nextVC.deckSpec = deckSpec
                }
            }
        }
    }

}
