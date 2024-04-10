//
//  GameViewController.swift
//  bananagrams
//
//  Created by Alex Castillo on 3/28/24.
//

import UIKit

// Screen for the gameplay
class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIScrollViewDelegate {
    
    // the collectionview representing the gameBoard / grid
    @IBOutlet weak var gameBoard: UICollectionView!
    // the collectionview representing the hand
    @IBOutlet weak var gameHand: UICollectionView!
    // this contains the data sources for the gameBoard and methods for manipulating them
    var game:Game!
    // the width and height of the gameBoard cells on the screen
    let gridCellWidth = 70
    // width and height of gameHand cells
    let handCellWidth = 100
    // cell identifier for the gameBoard collectionView cells
    let gridCellid = "gridCell"
    // cell identifier for the hand collectionView cells
    let handCellid = "handCell"

    // set up the screen, (scrollview is needed for horizontal scrolling of the gameBoard)
    override func viewDidLoad() {
        super.viewDidLoad()
        game = Game()
        let handHeight = self.view.frame.height / 5
        
        let boardBounds = CGRect(x: 0, y: 0, width: game.numRows * gridCellWidth, height: game.numRows * gridCellWidth)
        gameBoard.bounds = boardBounds
        gameBoard.frame = boardBounds
    
        let handFrame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.height - handHeight, width: self.view.frame.width, height: handHeight)
        gameHand.frame = handFrame
        let scrollFrame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y,width: self.view.frame.width, height: self.view.frame.height - handHeight)
        let scrollView = UIScrollView(frame: scrollFrame)
        scrollView.addSubview(gameBoard)
        self.view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.contentSize = gameBoard.frame.size
        scrollView.minimumZoomScale = 0.66
        scrollView.maximumZoomScale = 1.0
        gameBoard.delegate = self
        gameBoard.dataSource = self
        gameBoard.delaysContentTouches = true
        gameBoard.dragDelegate = self
        gameBoard.dropDelegate = self
        gameHand.delegate = self
        gameHand.dataSource = self
        gameHand.dragDelegate = self
        gameHand.dropDelegate = self
        
        //testing stuff
        for i in 0...game.numRows-1 {
            game.grid[3][i] = Tile(letter: "F")
        }
        
        for i in 0...game.numRows-1 {
            game.grid[4][i] = Tile(letter: "O")
        }
    }
    
    

   // drop a tile onto the grid or into the user's hand
    // TODO: differientiate the grid and the hand
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        if collectionView == self.gameBoard {
            guard let destinationIndexPath = coordinator.destinationIndexPath else {
                return
            }
            let sourceIndexPath = coordinator.items.first?.sourceIndexPath
            if sourceIndexPath == nil {
                coordinator.session.loadObjects(ofClass: NSString.self) { items in
                    // Ensure that items is an array of NSString objects
                    guard let letterStrings = items as? [NSString] else {return}
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
                        let letter = Character(String(letterString))
                        if self.game.hand[letter]! - 1 == 0 {
                            self.game.hand.removeValue(forKey: letter)
                        } else {
                            self.game.hand[letter]! -= 1
                        }
                        self.game.grid[row][col] = Tile(letter: letter) // Assuming YourTile is your data model for tiles
                        // Reload collection view to reflect the changes
                        self.gameHand.reloadData()
                        collectionView.reloadData()
                    }
                    
                }
            } else {
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
        } else if collectionView == self.gameHand {
            
        }
       
    }
    
   func collectionView(_ collectionView: UICollectionView,
        canHandle session: any UIDropSession
   ) -> Bool {
       return true
   }
    
    
    // determine if you are able to drop a tile at a location
    // parameter collectionView is the destination collectionView
    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: any UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        if collectionView == self.gameBoard {
            let row = destinationIndexPath!.section
            let col = destinationIndexPath!.item
            if self.game.grid[row][col] != nil {
                return UICollectionViewDropProposal(operation: UIDropOperation.forbidden)
            }
            return UICollectionViewDropProposal(operation: UIDropOperation.move)
        } else if collectionView == self.gameHand {
            print("checkcheck")
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
        } else if collectionView == gameHand {
            let cell = gameHand.dequeueReusableCell(withReuseIdentifier: handCellid, for: indexPath) as! HandCell
            let keys = Array(game.hand.keys).sorted()
            let key = keys[indexPath.item]
            let itemProvider = NSItemProvider(object: NSString(string: String(key)))
            let dragItem = UIDragItem(itemProvider: itemProvider)
            print(dragItem)
            print("drag from hand to grid")
            return [dragItem]
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
        } else {
            // should be able to drag all tiles in the hand
            return true
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameBoard
    }

    // set the spacing of the tiles in the grid
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let gridLayout = UICollectionViewFlowLayout()
        gridLayout.itemSize = CGSize(width: gridCellWidth, height: gridCellWidth)
        gameBoard.collectionViewLayout = gridLayout
        gridLayout.minimumLineSpacing = 0.0
        gridLayout.minimumInteritemSpacing = 0.0
        let handLayout = UICollectionViewFlowLayout()
        handLayout.scrollDirection = .horizontal
        handLayout.itemSize = CGSize(width: handCellWidth, height: handCellWidth)
        gameHand.collectionViewLayout = handLayout
    }
    
    // if collectionView is gameBoard return number of rows in grid or 1 if colletionView is gameHand
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.gameBoard {
            return game.numRows
        } else if collectionView == self.gameHand {
            return 1
        }
        return 0
    }
    
    // if collectionView is gameBoard return number of columns in grid or the number of unique letters in the players hand if colletionView is gameHand
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.gameBoard {
            return game.numRows
        } else if collectionView == self.gameHand {
            return game.hand.count
        }
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
                cell.layer.cornerRadius = CGFloat(gridCellWidth / 10)
            }
            cell.layer.borderWidth = CGFloat(gridCellWidth / 70)
            return cell
        } else if collectionView == self.gameHand {
            let cell = gameHand.dequeueReusableCell(withReuseIdentifier: handCellid, for: indexPath) as! HandCell
            let keys = Array(game.hand.keys).sorted()
            let key = keys[indexPath.item]
            let count = game.hand[key]
                    // Configure the cell with the key
            cell.letter.text = String(key)
            cell.count.text = String(count!)
            cell.layer.borderWidth =   CGFloat(handCellWidth/70)
            cell.layer.cornerRadius = CGFloat(handCellWidth/10)
            return cell
        }
        return gameBoard.dequeueReusableCell(withReuseIdentifier: gridCellid, for: indexPath)
    }
}
