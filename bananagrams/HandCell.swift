//
//  HandCell.swift
//  bananagrams
//
//  Created by Alex Castillo on 4/9/24.
//

import UIKit

// A handcell represents that the player has a certain number of this letter in their hand
class HandCell: UICollectionViewCell {
    // the number of tiles in the players land with this letter
    @IBOutlet weak var count: UILabel!
    // the letter
    @IBOutlet weak var letter: UILabel!
}
