//
//  TileStack.swift
//  bananagrams
//
//  Created by Alex Castillo on 4/7/24.
//

import Foundation

// These represent how many of each letter are in a player's hand
// It also represents how many of each letter is in 
class TileStack {
    var letter:Character
    var count = 0
    
    init(letter: Character, count: Int = 0) {
        self.letter = letter
        self.count = count
    }
    
}
