//
//  Tile.swift
//  bananagrams
//
//  Created by Alex Castillo on 3/28/24.
//

import Foundation
import UIKit

// A class that represents a tile on the game board ... Can/Should this be a struct instead?
class Tile {
    // The letter of this tile. either one character a-z or " " representing a tile grid location with no letter tile on it
    var letter:Character
    
    // An image for the tile (currently using systemName UIImages)
    var image:UIImage
    
    // initializer
    init(letter: Character, image: UIImage) {
        self.letter = letter
        self.image = image
    }
}
