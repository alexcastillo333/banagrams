//
//  InstructionsViewController.swift
//  bananagrams
//
//  Created by Alex Castillo on 3/18/24.
//

import UIKit

let freeplay = "Placeholder for Freeplay instructions"
let timed = "Placeholder for Timed instructions"
let versus = "Placeholder for Versus instructions"
class InstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsLabel.text = freeplay
        // Do any additional setup after loading the view.
    }
    
    // This segmented control lists the 3 gamemodes: Freeplay, Timed, and Versus
    @IBOutlet weak var segCtrl: UISegmentedControl!
    // This label displays the instructions for the selectd gamemode
    @IBOutlet weak var instructionsLabel: UILabel!
    
    // Display the correct set of instructions when the user selects a game mode
    @IBAction func onSegmentChanged(_ sender: Any) {
        switch segCtrl.selectedSegmentIndex {
        case 0:
            instructionsLabel.text = freeplay
        case 1:
            instructionsLabel.text = timed
        case 2:
            instructionsLabel.text = versus
        default:
            instructionsLabel.text = "This shouldn't happen!"
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
