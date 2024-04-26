//
//  InstructionsViewController.swift
//  bananagrams
//
//  Created by Alex Castillo on 3/18/24.
//

import UIKit

let freeplay = "drag and drop your letters onto the grid zoom in and out by pinching create one big crossword with your letters peel when you have used all your letters to receive a random letter shake to dump the last letter you placed and receive 3 random letters keep peeling until there are no letters left!"
let timed = "drag and drop your letters onto the grid zoom in and out by pinching create one big crossword with your letters peel when you have used all your letters to receive a new letter shake to dump the last letter you placed and receive 3 new letters keep peeling until there are no letters left race against the clock!"
let versus = "drag and drop your tiles onto the gridzoom in and out by pinchingcreate one big crossword with your letters peel when you have used all your letters to give a new letter to yourself and your opponents shake to dump the last letter you placed and receive 3 new letterskeep peeling until there are no letters left! the last player to peel wins!"
class InstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        instructionsLabel.text = freeplay
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
}
