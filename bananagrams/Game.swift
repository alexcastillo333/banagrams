//
//  Game.swift
//  bananagrams
//
//  Created by Alex Castillo on 4/7/24.
//

import Foundation

// The class for information about a game, contains a grid, and the hand
class Game {
    
    
    // you can only peel when this is true
    // update this var evertime you move a tile
    var canPeel = false
    var canDump = true
    
    // The grid for the game, where the player places their tiles to make words
    var grid: [[Tile?]]


    // the counts for each letter in the deck: contains 26 integers, integer at index 0 represents the number of A's in the deck ... integer at index 25 represents the number of Z's in the deck. The integers at these indicices will change as the user plays the game (peeling, placing, dumping, removing) but it will never grow larger than the total sum at the beggining (default is 144:)
    var deckCounts:[Int]
    // the actual letters in the deck, used to randomly select a tiles when a player peels or dumps
    var deck:[Character]
    // The letters in a player's hand, it is represented the same way as the deckCounts
    var hand:[Int]
    
    // Initializer deckspec is the number of each letter in the deck. numPlayers is how many players there are (only single player implementation as of now
    init(deckSpec:[Int] = [13, 3, 3, 6, 18, 3, 4, 3, 12, 2, 2, 5, 3, 8 ,11, 3, 2 ,9, 6, 9 , 6, 3, 3, 2 , 3, 2], numPlayers:Int = 1)  {
        canPeel = false
        canDump = true
        deckCounts = deckSpec
        deck = []
        // initialize deck
        for letter in 0...25 {
            for count in 1...deckSpec[letter] {
                deck.append(Character(UnicodeScalar(65 + letter)!))
            }
        }
        // initialize hand by randomly removing 21 indices(letters) from deck, update deckCounts and hand accordingly
        hand = Array(repeating: 0, count: 26)
        for _ in 1...26 {
            var randomIndex = Int.random(in: 0..<deck.count)
            var letter = deck.remove(at: randomIndex)
            var handIdx = letter.asciiValue! - 65
            hand[Int(handIdx)] += 1
            deckCounts[Int(handIdx)] -= 1
        }
        var numRows:Int
        if 100 < deck.count && deck.count < 160 {
            numRows = 30
        } else {
            numRows = 5 // test different size decks to see which makes the most sense
            // more players means grid can be smaller
        }
        // grid is initially empty
        grid = Array(repeating: Array(repeating: nil, count: numRows), count: numRows)
    }
    
    
    
    
    
}
