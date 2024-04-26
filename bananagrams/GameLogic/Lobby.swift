//
//  Lobby.swift
//  bananagrams
//
//  Created by Aaron Posadas on 4/26/24.
//

import Foundation
import UIKit
import Firebase

class Lobby {
    let ref = Database.database().reference().child("playing-online")
    var lobbyName: String
    var deck: DatabaseReference
    init(lobbyName: String) {
        // Create lobby
        self.lobbyName = lobbyName
        self.deck = ref.child(lobbyName).child("deck")
    }
    
    static func createLobby(identifier: String) {
        // Init lobby with identifier and set values
        let ref = Database.database().reference().child("playing-online")
        ref.child(identifier)
    }
    
    func getReference() -> DatabaseReference {
        return ref.child(lobbyName)
    }
    
    func addPlayer(identifier: String, name: String, deck: [Character], isReady: Bool) {
        let playerValues: [String: Any] = [
            "name": name,
            "deck": deck,
            "isReady": isReady
        ]
        let player = self.ref.child(self.lobbyName).child(identifier)
        player.updateChildValues(playerValues) { (error, _) in
            if let error = error {
                print("Error updating player1 data: \(error.localizedDescription)")
            } else {
                print("\(identifier) updated.")
            }
        }
    }
    
    func removePlayer(identifier: String) {
        self.ref.child(self.lobbyName).child(identifier).removeValue()
    }
    
    func setReady(identifier: String, ready: Bool) {
        self.ref.child(self.lobbyName).child(identifier).child("isReady").setValue(ready)
    }
            
    func isReady(identifier: String, completion: @escaping (Bool) -> Void) {
        let playerRef = self.ref.child(self.lobbyName).child(identifier)
        
        // Extract the value of "isReady" from the snapshot
        playerRef.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {
                print("\(identifier) isReady node does not exist")
                return
            }
            
            if let playerData = snapshot.value as? [String: Any],
               let readyBool = playerData["isReady"] as? Bool {
                
                completion(readyBool)
            } else {
                print("Error in retrieving isReady bool for \(identifier)")
                completion(false)
            }
        }
        
        completion(false)
    }

    
    // use this logic to get deck instead
    func getPlayerName(identifier: String, completion: @escaping (String) -> Void) {
        let name: String = "Player not found."
        let player = ref.child(self.lobbyName).child(identifier)
        // Observe changes at the player1 node
        player.observeSingleEvent(of: .value) { (snapshot) in
            // Check if the snapshot contains data
            guard snapshot.exists() else {
                print("\(identifier) node does not exist")
                return
            }
            
            // Extract the value of the "name" field from the snapshot
            if let playerData = snapshot.value as? [String: Any],
               let playerName = playerData["name"] as? String {
                print("Got the player name!: \(playerName)")
                completion(playerName)
            } else {
                print("Error in getting \(identifier) name")
            }
        }
        
        completion(name)
    }
    
    
    func getP1Deck() {
        
    }
    
    func getP2Deck() {
        
    }
    
    func updateGameDeck() {
        
    }
    
    func getGameDeck() {
        
    }
    
    func updatePlayerDeck(player: String, deck: [Character]) {
        
    }
    
}
