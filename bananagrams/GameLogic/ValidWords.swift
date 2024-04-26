//
//  CreateDict.swift
//  bananagrams
//
//  Created by Alex Castillo on 4/9/24.
//

import Foundation

// This class creates a set of all playable words by reading them in from a file
class MakeValidWords {
    var words:Set<String>!
    init() {
        // Read the contents of the text file
        guard let fileURL = Bundle.main.url(forResource: "scrabble_words", withExtension: "txt") else {
            fatalError("scrabble_words.txt not found")
        }
        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            // Split the contents into individual words
            let validwords = contents.components(separatedBy: .newlines)

            // Create a set of strings from the words
            words = Set(validwords)
        } catch {
            print("Error reading file:", error)
        }
    }
}
