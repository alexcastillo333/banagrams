//
//  Game.swift
//  bananagrams
//
//  Created by Alex Castillo on 4/7/24.
//

import Foundation


// The class for information about a game, contains a grid, and the hand
class Game {
    // a set of all playable words
    static let playableWords = MakeValidWords().words!
    // you can only peel when this is true
    // update this var evertime you move a tile
    var canPeel = false
    var canDump = true
    // this var tracks if all the letters are adjacent to each other on the grid, you cannot peel if this is false
    var isContinuous = true
    
    
    // The grid for the game, where the player places their tiles to make words
    // top left corner is [0][0], bottom right is [numRows-1][numRows-1]
    var grid: [[Tile?]]
    // This tracks the nuber of tiles that are currently placed on the grid
    var tilesOnGrid = 0
    
    // the number of rows (and columns) of this games grid
    var numRows:Int
    
    // the counts for each letter in the deck: contains 26 integers, integer at index 0 represents the number of A's in the deck ... integer at index 25 represents the number of Z's in the deck. The integers at these indicices will change as the user plays the game (peeling, placing, dumping, removing) but it will never grow larger than the total sum at the beggining (default is 144:)
    var deckCounts:[Int]
    // the actual letters in the deck, used to randomly select a tiles when a player peels or dumps
    var deck:[Character]
    // The letters in a player's hand, this will be the data source for the hand on the gamescreenCh
    var hand: [Character:Int] = [:]
    
    
    // Initializer deckspec is the number of each letter in the deck. numPlayers is how many players there are (only single player implementation as of now
    init(deckSpec:[Int] = [13, 3, 3, 6, 18, 3, 4, 3, 12, 2, 2, 5, 3, 8 ,11, 3, 2 ,9, 6, 9 , 6, 3, 3, 2 , 3, 2], numPlayers:Int = 1)  {
        canPeel = false
        // should be able to dump immediately (assuming deck has at least 24 tiles)
        canDump = true
        isContinuous = true
        deckCounts = deckSpec
        deck = []
        // initialize deck
        for letter in 0...25 {
            for count in 1...deckSpec[letter] {
                deck.append(Character(UnicodeScalar(65 + letter)!))
            }
        }
        // initialize hand by randomly removing 21 indices(letters) from deck, update deckCounts and hand accordingly
        for _ in 1...21 {
            // randomly remove letter from
            var randomIndex = Int.random(in: 0..<deck.count)
            var letter = deck.remove(at: randomIndex)
            // update hand
            if hand[letter] == nil {
                hand[letter] = 1
            } else {
                hand[letter]! += 1
            }
            //update deckcounts
            var letteridx = Int(letter.asciiValue! - 65)
            deckCounts[letteridx] -= 1
        }
        if 100 < deck.count && deck.count < 160 {
            numRows = 30
        } else {
            numRows = 5 // test different size decks to see which makes the most sense
            // more players means grid can be smaller
        }
        // grid is initially empty
        grid = Array(repeating: Array(repeating: nil, count: numRows), count: numRows)
    }
    
    // return true if the user successfully peeled, remove a tile from the deck and place it into their hand. return false if the grid is not in a peelable state
    func peel() -> Bool{
        return false
    }
    
    // move a tile from the players hand to the grid, update the associated class vars
    // return true if successful, false if unsuccessful
    // row and col are indices into the grid
    func handToGrid(letter:Character, row:Int, col:Int) -> Bool{
        return false
    }
    // move a tile from the grid back into the players hand
    // row and col are indicies into the grid
    func gridtoHand(row:Int, col:Int) -> Bool{
        
        return false
    }
    
    
    
    // recursively get the index the first letter of a horizontal string in the grid
    func getHStringIdx(row:Int, col:Int) -> (Int, Int) {
        // base case, you are on left edge of grid
        if col < 0 {return (row, 0)}
        // base case, you reached an empty tile
        if grid[row][col] == nil {
            return (row, col + 1)
        }
        // recursive step,
        return getHStringIdx(row: row, col: col - 1)
    }
    // recursively get the index the first letter of a horizontal string in the grid
    func getVStringIdx(row:Int, col:Int) -> (Int, Int) {
        // base case, you are on bottom edge of grid
        if row < 0 {return (0, col)}
        // base case, you reached an empty tile
        if grid[row][col] == nil {
            return (row + 1, col)
        }
        // recursive step,
        return getHStringIdx(row: row - 1, col: col)
    }
    
    // get the horizontal string at index [row][col]
    func getHStringAtIdx(row:Int, col: inout Int) -> String {
        var s = ""
        while col < numRows && grid[row][col] != nil {
            s += String(grid[row][col]!.letter)
            col += 1
        }
        print(s)
        return s
    }
    
    // get the vertical string starting at index [row][co]
    func getVStringAtIdx(row: inout Int, col:Int) -> String {
        var s = ""
        while row < numRows && grid[row][col] != nil {
            s += String(grid[row][col]!.letter)
            row += 1
        }
        print(s)
        return s
    }
    
    // check if a word is in the playable words set
    func checkWord(word:String) -> Bool {
        return Game.playableWords.contains(word.lowercased())
    }
    
}
    
    
    
    
    
    

