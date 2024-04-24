//
//  GameViewController.swift
//  bananagrams
//
//  Created by Alex Castillo on 3/28/24.
//

import UIKit
import CoreData

// Screen for the gameplay
class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var peelButton: UIButton!
    // the collectionview representing the gameBoard / grid
    @IBOutlet weak var gameBoard: UICollectionView!
    // the collectionview representing the hand
    @IBOutlet weak var gameHand: UICollectionView!
    
    
    
    // count the time until the game ends
    var timer:UILabel!
    // numner of seconds that have passed
    var time = 0
    // queue for updating timer
    var queue: DispatchQueue!
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
    
    // email used to load correct color theme
    var email: String?
    
  
    
    // set up the screen, (scrollview is needed for horizontal scrolling of the gameBoard)
    override func viewDidLoad() {
        super.viewDidLoad()
        var array = Array(repeating: 0, count: 26)
        array[0] = 2
        game = Game(deckSpec: array)
        // game = game()
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
        gameBoard.allowsSelection = false
        peelButton.isHidden = true
        gameHand.allowsSelection = true
        gameHand.allowsMultipleSelection = false
        
        
        // make the timer
        let timerSize = CGSize(width: 90.0, height: 40.0)
        let timerOrigin = CGPoint(x: (self.view.frame.width - 90) / 2, y: 60)
        timer = UILabel(frame: CGRect(origin: timerOrigin, size: timerSize))
        timer.backgroundColor = UIColor.black
        timer.layer.cornerRadius = 10
        timer.textColor = UIColor.white
        timer.textAlignment = .center
        self.view.addSubview(timer)
        self.view.bringSubviewToFront(timer)
        queue = DispatchQueue(label: "myQueue", qos: .userInitiated)
        // for detecting shaking
        becomeFirstResponder()
    }
    
    
    func timerStart() {
        while !game.gameOver {
            
            usleep(1000000)
            self.time += 1
            DispatchQueue.main.async {
                let minutes = self.time / 60
                let seconds = self.time % 60
                let timeString = String(format: "%02d:%02d", minutes, seconds)
                self.timer.text = timeString
            }
        }
        saveTimeToCoreData()
        
//        ref.child(username).setValue([
//            "username": username,
//            "email": email,
//            "request": uid
//        ]) { (error, ref) in
//            if let error = error {
//                print("Data could not be saved: \(error.localizedDescription)")
//            } else {
//                print("Data saved successfully")
//            }
//        }
    }
    
    func saveTimeToCoreData() {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email ?? "")
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                var times = [user.time1, user.time2, user.time3, user.time4, user.time5]
                        
                // Add the new time and sort the array
                times.append(Int32(self.time))
                times.sort()
                
                times = Array(times.prefix(5))
                
                user.time1 = times.count > 0 ? times[0] : Int32.max
                user.time2 = times.count > 1 ? times[1] : Int32.max
                user.time3 = times.count > 2 ? times[2] : Int32.max
                user.time4 = times.count > 3 ? times[3] : Int32.max
                user.time5 = times.count > 4 ? times[4] : Int32.max
                print("below is usertime")
                print(user.time1)
                print(user.time2)
        
                try context.save()
                
                
            }
        } catch {
            print("ERROR SAVING TIME")
        }
            
        
    }
    
    // allow this screen to recognize motion
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    // shake to dump
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // can only dump when at least 3 tiles are in the bunch
            if self.game.bunch.count > 3 {
                if !self.gameHand.indexPathsForSelectedItems!.isEmpty {
                    let idx = self.gameHand.indexPathsForSelectedItems![0]
                    let lettersInHand = Array(game.hand.keys).sorted()
                    let letterToDump = lettersInHand[idx.item]
                    UIView.animate(withDuration: 1.0,
                                   animations: { let dumpee = self.gameHand.cellForItem(at: idx) as! HandCell
                        
                        dumpee.center.y += self.gameHand.frame.height
                        dumpee.transform = dumpee.transform.rotated(by: CGFloat(Double.pi) * 3)
                                                },
                                   completion: {_ in
                        let newTiles = self.game.dump(letter: letterToDump)
                        self.gameBoard.reloadData()
                        self.gameHand.reloadData()
                        self.peelButton.isHidden = !self.game.hand.isEmpty
                    }
                    )
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyColorScheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer.text = "0:00"
        queue.async {
            self.timerStart()
        }
    }
    
    func applyColorScheme() {
        guard let email = email else {
            print("Email is nil")
            return
        }

        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                print("User found: \(user.username ?? "[username not available]")")
                if let theme = user.colors {
                    switch theme {
                    case "theme1":
                        let primaryColor = UIColor(red: 255/255, green: 235/255, blue: 205/255, alpha: 1.0) // An approximation to light beige
                        let secondaryColor = UIColor(red: 210/255, green: 180/255, blue: 140/255, alpha: 1.0) // A darker beige or tan color
                        gameBoard.backgroundColor = primaryColor
                        gameHand.backgroundColor = secondaryColor
                    case "theme2":
                        gameBoard.backgroundColor = UIColor.white
                        gameHand.backgroundColor = UIColor.black
                    case "theme3":
                        gameBoard.backgroundColor = UIColor.systemPink
                        gameHand.backgroundColor = UIColor.systemPurple
                    default:
                        break
                    }
                }
            }
        } catch {
            print("ERROR LOADING COLORS: \(error.localizedDescription)")
        }
    }
    
    
    
  
    

   // drop a tile onto the grid or into the user's hand
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        // dropping a tile onto the grid
        if collectionView == self.gameBoard {
            guard let destinationIndexPath = coordinator.destinationIndexPath else {
                return
            }
            let sourceIndexPath = coordinator.items.first?.sourceIndexPath
            // dragging from hand, dropping on grid
            if sourceIndexPath == nil {
                coordinator.session.loadObjects(ofClass: NSString.self) { items in
                guard let letterStrings = items as? [NSString] else {return}
                for letterString in letterStrings {
                    let row = destinationIndexPath.section
                    let col = destinationIndexPath.item
                    let letter = Character(String(letterString))
                    self.game.handToGrid(letter: letter, row: row, col: col)
                    self.gameHand.reloadData()
                    collectionView.reloadData()
                    self.peelButton.isHidden = !self.game.hand.isEmpty

                }
                }
            // dragging from grid, dropping on grid
            } else {
                coordinator.session.loadObjects(ofClass: NSString.self) { items in
                guard let letterStrings = items as? [NSString] else { return }
                for letterString in letterStrings {
                    let row = destinationIndexPath.section
                    let col = destinationIndexPath.item
                    let sourceRow = sourceIndexPath!.section
                    let sourceCol = sourceIndexPath!.item
                    let letter = Character(String(letterString))
                    self.game.gridtoGrid(letter: letter, sourceRow: sourceRow, sourceCol: sourceCol, destRow: row, destCol: col)
                    collectionView.reloadData()
                }
                }
            }
        // dropping a tile back into your hand
        } else if collectionView == self.gameHand {
            let sourceIndexPath = coordinator.items.first?.sourceIndexPath
            // dragging from grid, dropping in hand
            if sourceIndexPath == nil {
                coordinator.session.loadObjects(ofClass: NSString.self) { items in
                    guard let letterStrings = items as? [NSString] else {return}
                    for letterString in letterStrings {
                        let sourceIndexPath = self.gameBoard.indexPathsForSelectedItems![0]
                        let row = sourceIndexPath.section
                        let col = sourceIndexPath.item
                        let letter = Character(String(letterString))
                        self.game.gridtoHand(letter: letter, row: row, col: col)
                        self.gameBoard.allowsSelection = false
                        self.gameBoard.reloadData()
                        self.gameHand.reloadData()
                        self.peelButton.isHidden = !self.game.hand.isEmpty
                    }
                }
           }
        }
    }
    
   func collectionView(_ collectionView: UICollectionView,
        canHandle session: any UIDropSession) -> Bool {
       return true
   }
    
    @IBAction func peelButtonPressed(_ sender: Any) {
        if !self.game.peel() {
            print("play peel failed sound effect")
        }
        if self.game.gameOver == true {
            print("you win")
        }
        self.peelButton.isHidden = !self.game.hand.isEmpty
        self.gameHand.reloadData()
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
            return UICollectionViewDropProposal(operation: UIDropOperation.move)
        }
        return UICollectionViewDropProposal(operation: UIDropOperation.move)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.gameHand {
            cell.backgroundColor = UIColor.yellow
        }
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
                // these two lines allow access to the index when dragging from the grid to the hand
                self.gameBoard.allowsSelection = true
                self.gameBoard.selectItem(at: indexPath, animated: false, scrollPosition: [])
                let tile = self.game.grid[row][col]
                let itemProvider = NSItemProvider(object: NSString(string: String(tile!.letter)))
                let dragItem = UIDragItem(itemProvider: itemProvider)
                return [dragItem]
            }
        // dragging a tile in the hand
        } else if collectionView == gameHand {
            let keys = Array(game.hand.keys).sorted()
            let key = keys[indexPath.item]
            let itemProvider = NSItemProvider(object: NSString(string: String(key)))
            let dragItem = UIDragItem(itemProvider: itemProvider)
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
