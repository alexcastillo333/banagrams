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
class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIScrollViewDelegate {
    
    
    
    
    
    
    
    // the collectionview representing the gameBoard
    @IBOutlet weak var gameBoard: UICollectionView!
    
    var game:Game!
    // the data source for the gameBoard
    
    
    let cellwidth = 70
    // dimensions for the gameBoard
    
    // will also need a data source for the player's hand
    // var hand: [[Tile]]    *may need to be a composed of different objects than a tile
    
    
    
    
    // cell identifier for the gameBoard collectionView cells
    let gridCellid = "gridCell"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Game()
        let handHeight = self.view.frame.height / 5
        let boardBounds = CGRect(x: 0, y: 0, width: game.numRows * cellwidth, height: game.numRows * cellwidth)
        gameBoard.bounds = boardBounds
        gameBoard.frame = boardBounds
        let scrollFrame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y,width: self.view.frame.width, height: self.view.frame.height - handHeight)
        let scrollView = UIScrollView(frame: scrollFrame)
        scrollView.addSubview(gameBoard)
        self.view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.contentSize = gameBoard.frame.size
        scrollView.minimumZoomScale = 0.66
        scrollView.maximumZoomScale = 1.0
            // to enable horizontal scrolling in the grid, the collectionview must be embedded in a scrollview
        gameBoard.delegate = self
        gameBoard.dataSource = self
        gameBoard.delaysContentTouches = true
        gameBoard.dragDelegate = self
        gameBoard.dropDelegate = self
        //grid = Array(repeating: Array(repeating: nil, count: cols), count: rows)
        
        //testing stuff
        for i in 0...game.numRows-1 {
            game.grid[3][i] = Tile(letter: "F")
        }
        
        for i in 0...game.numRows-1 {
            game.grid[4][i] = Tile(letter: "O")
        }

        // TODO: set the hand delegate and datasource

        // Do any additional setup after loading the view.
    }
    
    

   // drop a tile onto the grid or into the user's hand
    // TODO: differientiate the grid and the hand
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
                return
            }
        let sourceIndexPath = coordinator.items.first?.sourceIndexPath
            
            coordinator.session.loadObjects(ofClass: NSString.self) { items in
                // Ensure that items is an array of NSString objects
                guard let letterStrings = items as? [NSString] else { return }
                
                // Perform actions with the dropped data
                for letterString in letterStrings {
                    // Here you can access the dropped string and the destinationIndexPath
                    // For example, you can update your data source with the dropped string
                    // and reload the collection view to reflect the changes.
                    // You can also use the destinationIndexPath to determine where the data should be placed.
                    
                    // Example action: update your grid data source
                    // Assuming grid is your data source, you might want to update it like this:
                    let row = destinationIndexPath.section
                    let col = destinationIndexPath.item
                    let sourceRow = sourceIndexPath!.section
                    let sourceCol = sourceIndexPath!.item
                    self.game.grid[sourceRow][sourceCol] = nil
                    let letter = Character(String(letterString))
                    
                    self.game.grid[row][col] = Tile(letter: letter) // Assuming YourTile is your data model for tiles
                    
                    // Reload collection view to reflect the changes
                    collectionView.reloadData()
                }
            }
       
    }
    
   func collectionView(_ collectionView: UICollectionView,
        canHandle session: any UIDropSession
   ) -> Bool {
       return true
   }
    
    
    // determine if you are able to drop a tile at a location
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: any UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        let row = destinationIndexPath!.section
        let col = destinationIndexPath!.item
        if self.game.grid[row][col] != nil {
            return UICollectionViewDropProposal(operation: UIDropOperation.forbidden)
        }
        return UICollectionViewDropProposal(operation: UIDropOperation.move)
    }
    
    
    // begin a draging a tile
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // dragging a tile already on the board
        if collectionView == gameBoard {
            let row = indexPath.section
            let col = indexPath.item
            // cannot move an empty tile
            if self.game.grid[row][col] == nil {
                return []
            // get the tile
            } else {
                /*let model = dataSource[indexPath.item]
                 let itemProvider = NSItemProvider(object: model.image) //UIImage conforms to NSItemProviderWriting by default
                 let dragItem = UIDragItem(itemProvider: itemProvider)
                 dragItem.localObject = model //We can set the localObject property for convenience
                 return [dragItem]*/
                let tile = self.game.grid[row][col]
                let itemProvider = NSItemProvider(object: NSString(string: String(tile!.letter)))
                let dragItem = UIDragItem(itemProvider: itemProvider)
                return [dragItem]
            }
            // dragging a tile in the hand
        } else {
            return []
        }
        
        return []
    }
    
    
  //   should only be able to drag and drop tiles with letters on to empty tiles
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        // moving tile on the gameboard
        if collectionView == self.gameBoard {
            let row = indexPath.section
            let col = indexPath.item
            // cannot move an empty tile.
            if self.game.grid[row][col] == nil {
                return false
            } else {
                return true
            }
            // moving tile onto hand
        } else {
            return false
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameBoard
    }

    // set the spacing of the tiles in the grid
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellwidth, height: cellwidth)
        gameBoard.collectionViewLayout = layout
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
    }
    
   
    
    // return number of rows in grid
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.gameBoard {
            return game.numRows
        }
        // placeholder , TODO: handle hand collection
        return 0
    }
    
    
    // return number of columns in grid
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.gameBoard {
            return game.numRows
        }
        // placeholder , TODO: handle hand collection
        return 0

    }
    
    
    // return the cells for the grid or the hand
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.gameBoard {
            let cell = gameBoard.dequeueReusableCell(withReuseIdentifier: gridCellid, for: indexPath) as! GridCell
            let row = indexPath.section
            let col = indexPath.item
          
            if self.game.grid[row][col] == nil {
                cell.letter.text = ""
          
            } else {
                cell.letter.text = String(self.game.grid[row][col]!.letter)
            }
            cell.layer.borderWidth = 1
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
