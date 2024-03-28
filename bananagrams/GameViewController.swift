//
//  GameViewController.swift
//  bananagrams
//
//  Created by Alex Castillo on 3/28/24.
//

import UIKit

// TODO:
// unsure how to properly implement the correct sizing for the grid
// it should be fixed 100 rows by 100 columns, it is currently just fitting itself such that
// the it fits on the screen vertically and you can scroll up and down to see the rest of the tiles


// Screen for the gameplay
class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    // the collectionview representing the gameBoard
    @IBOutlet weak var gameBoard: UICollectionView!
    
    // the data source for the gameBoard
    var grid: [[Tile]]!
    
    // dimensions for the gameBoard
    let rows = 100
    let cols = 100
    
    // will also need a data source for the player's hand
    // var hand: [[Tile]]    *may need to be a composed of different objects than a tile
    
    
    
    
    // cell identifier for the gameBoard collectionView cells
    let gridCellid = "gridCell"
    // will also need a cell identifier for the hand collectionview cells
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameBoard.delegate = self
        gameBoard.dataSource = self
        grid = Array(repeating: Array(repeating: Tile(letter: " ", image: UIImage(systemName: "square.fill")!), count: cols), count: rows)
        // TODO: set the hand delegate and datasource
        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.gameBoard {
            return cols
        }
        // placeholder , TODO: handle hand collection
        return 0

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.gameBoard {
            let cell = gameBoard.dequeueReusableCell(withReuseIdentifier: gridCellid, for: indexPath)
            let row = indexPath.section
            let col = indexPath.item
            // need to correctly set the framing of the imageview
            let imageView = (UIImageView(image: grid[row][col].image))
            cell.contentView.addSubview(imageView)
            return cell
        }
        // placeholder , TODO: handle hand collection
        return gameBoard.dequeueReusableCell(withReuseIdentifier: gridCellid, for: indexPath)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
