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
    
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super .init(coder: coder)
    }
    

    // that variable causes a tile in your hand to have a shadow if it is the selected one.
    override var isSelected: Bool {
        didSet {
            // Update appearance based on selection sta
            if isSelected {
                self.layer.masksToBounds = false  // turns clipping off so shadow is visible
                self.layer.shadowColor = UIColor.black.cgColor
                self.layer.shadowOpacity = 0.7
                self.layer.shadowOffset = CGSize(width: 5, height: 5)
                self.layer.shadowRadius = 4
            } else {
                self.layer.masksToBounds = true
            }
        }
    }
}
