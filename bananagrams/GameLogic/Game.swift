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
    //    var validWords = false
    //    var canDump = true
    var gameOver = false
    // this var tracks if all the letters are adjacent to each other on the grid, you cannot peel if this is false
    var isContinuous = true
    // a tuple of the row and col values of the last placed index on the grid, used to check if all tiles are continous or not
    var lastPlacedIndex: (Int, Int)
    
    var words:Set<String>
    // the number of rows (and columns) of this games grid
    var numRows:Int
    // The grid for the game, where the player places their tiles to make words
    // top left corner is [0][0], bottom right is [numRows-1][numRows-1]
    var grid: [[Tile?]]
    // This tracks the nuber of tiles that are currently placed on the grid
    var tilesOnGrid:Int
    
    
    
    // (like a bunch of bananas)
    // the actual letters in the bunch, used to randomly select a tiles when a player peels or dumps
    var bunch:[Character]
    // The letters in a player's hand, this will be the data source for the hand on the gameViewController
    var hand: [Character:Int] = [:]
    
    // Initializer deckspec is the number of each letter in the deck. numPlayers is how many players there are (only single player implementation as of now
    init(deckSpec:[Int] = [13, 3, 3, 6, 18, 3, 4, 3, 12, 2, 2, 5, 3, 8 ,11, 3, 2 ,9, 6, 9 , 6, 3, 3, 2 , 3, 2], numPlayers:Int = 1)  {
        
        // should be able to dump immediately (assuming deck has at least 24 tiles)
        //canDump = true
        //isContinuous = true
        bunch = []
        tilesOnGrid = 0
        // initialize deck: for each letter in the alphabet, add the letter to the deck the number of times specified in deckSpec
        for letter in 0...25 {
            //for _ in 1...deckSpec[letter] {
            if deckSpec[letter] > 0 {
                for _ in 1...deckSpec[letter] {
                    bunch.append(Character(UnicodeScalar(65 + letter)!))
                }
            }
        }
        
        // initialize hand by randomly removing 21 indices(letters) from deck, update bunch and hand accordingly
        var startHandSize:Int
        if bunch.count > 21 {
            startHandSize = 21
        } else if bunch.count > 2 {
            startHandSize = bunch.count - 3
        } else {
            startHandSize = bunch.count
        }
        // TODO: change this back to 21 when testing is finished
        for _ in 1...startHandSize {
            // randomly remove letter from
            let randomIndex = Int.random(in: 0..<bunch.count)
            let letter = bunch.remove(at: randomIndex)
            // update hand
            if hand[letter] == nil {
                hand[letter] = 1
            } else {
                hand[letter]! += 1
            }
            //update bunch
        }
        if 100 < bunch.count && bunch.count < 160 {
            numRows = 30
        } else {
            numRows = 40 // test different size decks to see which makes the most sense
            // more players means grid can be smaller
        }
        // grid is initially empty
        grid = Array(repeating: Array(repeating: nil, count: numRows), count: numRows)
        lastPlacedIndex = (-1, -1)
        words = Set()
    }
    
    
    // place one tile in the player's hand back into the bunch and draw 3 random tiles from the bunch
    func dump(letter:Character) -> [Character]{
        if bunch.count < 3 {
            return []
        }
        // randomly select 3 tiles to dump
        var dumped:[Character] = []
        for _ in 1...3 {
            let randomIndex = Int.random(in: 0..<bunch.count)
            let tile = bunch.remove(at: randomIndex)
            dumped.append(tile)
            if hand[tile] == nil {
                hand[tile] = 1
            } else {
                hand[tile]! += 1
            }
        }
        // discard the tile in your hand
        if hand[letter]! - 1 == 0 {
            hand.removeValue(forKey: letter)
        } else {
            hand[letter]! -= 1
        }
        bunch.append(letter)
        // discard the letter selected by the player
        return (dumped)
        
    }
    
    // if a player peels, see if they have a valid tile layout, if they do, draw a random letter from the bunch and place it in their hand
    // or set gameOver to true if no letters left to peel
    // if not, return false.
    func peel() -> String {
        if checkPeelConditions() {
            if  bunch.isEmpty {
                gameOver = true
                print("you win")
                return "win"
            }
            let randomIndex = Int.random(in: 0..<bunch.count)
            let letter = bunch.remove(at: randomIndex)
            if hand[letter] == nil {
                hand[letter] = 1
            } else {
                hand[letter]! += 1
            }
            return String(letter)
        }
        return "fail"
    }
    
    
    // recursively check if all tiles on this grid are in a single big crossword and if all words are valid words
    func checkPeelConditions() -> Bool{
        var visited = Array(repeating: Array(repeating: false, count: numRows), count: numRows)
        var count = 0
        checkPeelConditionsHelper(row: lastPlacedIndex.0, col: lastPlacedIndex.1, visited: &visited, count: &count)
        return count == tilesOnGrid
    }
    
    
    // recursive helper. count is the total number of tiles adjacent to each other on the grid, if they are in a valid crossword position,
    // this value should be equal to TilesOnGrid
    func checkPeelConditionsHelper(row:Int, col:Int, visited:inout [[Bool]], count:inout Int) {
        if row < 0 || col < 0 || row >= numRows || col >= numRows {
            // index out of bounds, return
            return
        }
        if visited[row][col] || grid[row][col] == nil {
            // already visited this spot or this spot is nil, return
            return
        }
        // we are currently visiting this spot,
        visited[row][col] = true
        count += 1
        // check if this tile is the beginning of vertical word
        if (row - 1 >= 0 && grid[row-1][col] == nil) || row == 0 {
            let vString = getVStringAtIdx(row: row, col: col)
            if vString.count > 1 {
                // found a word that is not valid -> reset the count and stop recursion
                if !checkWord(word: vString) {
                    print(vString)
                    count = 0
                    return
                }
            }
        }
        // check if this tile is the beginning of a horizontal word
        if (col - 1 >= 0 && grid[row][col - 1] == nil) || col == 0 {
            let hString = getHStringAtIdx(row: row, col: col)
            if hString.count > 1 {
                // found a word that is not valid -> reset the count and stop recursion
                if !checkWord(word: hString) {
                    print(hString)
                    count = 0
                    return
                }
            }
        }
        // recursive step, check all adjacent rows
        checkPeelConditionsHelper(row: row + 1, col: col, visited: &visited, count: &count)
        checkPeelConditionsHelper(row: row - 1, col: col, visited: &visited, count: &count)
        checkPeelConditionsHelper(row: row, col: col + 1, visited: &visited, count: &count)
        checkPeelConditionsHelper(row: row, col: col - 1, visited: &visited, count: &count)
    }
    
    
    // move a tile from the players hand to the grid, update the associated class vars
    // return true if successful, false if unsuccessful
    // row and col are indices into the grid
    func handToGrid(letter:Character, row:Int, col:Int) {
        if hand[letter]! - 1 == 0 {
            hand.removeValue(forKey: letter)
        } else {
            hand[letter]! -= 1
        }
        grid[row][col] = Tile(letter: letter)
        lastPlacedIndex.0 = row
        lastPlacedIndex.1 = col
        tilesOnGrid += 1
    }
    
    // move a tile from the grid back into the players hand
    // row and col are indicies into the grid
    func gridtoHand(letter:Character, row:Int, col:Int) {
        grid[row][col] = nil
        if hand[letter] == nil {
            hand[letter] = 1
        } else {
            hand[letter]! += 1
        }
        tilesOnGrid -= 1
    }
    
    func gridtoGrid(letter:Character ,sourceRow:Int, sourceCol:Int, destRow:Int, destCol:Int) {
        grid[sourceRow][sourceCol] = nil
        grid[destRow][destCol] = Tile(letter: letter)
        lastPlacedIndex.0 = destRow
        lastPlacedIndex.1 = destCol
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
    func getHStringAtIdx(row:Int, col: Int) -> String {
        var s = ""
        var c = col
        while c < numRows && grid[row][c] != nil {
            s += String(grid[row][c]!.letter)
            c += 1
        }
        return s
    }
    
    // check that a horizontal word is a real word, and check if each vertical string is also a word
    
    
    
    // get the vertical string starting at index [row][co]
    func getVStringAtIdx(row: Int, col:Int) -> String {
        var s = ""
        var r = row
        while r < numRows && grid[r][col] != nil {
            s += String(grid[r][col]!.letter)
            r += 1
        }
        return s
    }
    
    // check if a word is in the playable words set
    func checkWord(word:String) -> Bool {
        
        if Game.playableWords.contains(word) {
            words.insert(word)
            return true
        }
        return false
    }
    
}
    
    
    
    
    
    

