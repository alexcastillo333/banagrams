//
//  PopUp.swift
//  bananagrams
//
//  Created by Alex Castillo on 4/26/24.
//

import UIKit

class PopUp: UIView, UITableViewDelegate, UITableViewDataSource{
    
    
    
    
    var wordsTableView:UITableView?
    var width:CGFloat?
    var height:CGFloat?
    var words:[String]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPopup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPopup()
    }
    
    func setupPopup() {
        width = 2 * UIScreen.main.bounds.width / 3
        height = 2 * UIScreen.main.bounds.height / 3
        let origin = CGPoint(x: (UIScreen.main.bounds.width - width!) / 2, y: (UIScreen.main.bounds.height - height!) / 2)
        
        self.frame = CGRect(origin: origin, size: CGSize(width: width!, height: height!))
        self.clipsToBounds = true
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    func addVars(peelCount:Int, failedPeelCount:Int, dumpCount:Int, words:[String], time:Int) {
        // Add Congratulations label
        let congratsLabel = UILabel(frame: CGRect(x: 20, y: 10, width: width! - 40, height: 30))
        congratsLabel.text = "Congratulations!"
        congratsLabel.textColor = UIColor.black
        congratsLabel.textAlignment = .center
        self.addSubview(congratsLabel)
        
        let timeLabel = UILabel(frame: CGRect(x: 20, y: 50, width: width! - 40, height: 20))
        let minutes = time / 60
        let seconds = time % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        timeLabel.text = "Total time: " + timeString
        timeLabel.textColor = UIColor.black
        timeLabel.textAlignment = .center
        self.addSubview(timeLabel)
        
        // Add total dumps label
        let dumpsLabel = UILabel(frame: CGRect(x: 20, y: 80, width: width! - 40, height: 20))
        dumpsLabel.text = "Total dumps: \(dumpCount)"
        dumpsLabel.textColor = UIColor.black
        dumpsLabel.textAlignment = .center
        self.addSubview(dumpsLabel)
        
        // Add total peels label
        let peelsLabel = UILabel(frame: CGRect(x: 20, y: 110, width: width! - 40, height: 20))
        peelsLabel.text = "Total peels: \(peelCount)"
        peelsLabel.textColor = UIColor.black
        peelsLabel.textAlignment = .center
        self.addSubview(peelsLabel)
        
        let failedPeelsLabel = UILabel(frame: CGRect(x: 20, y: 140, width: width! - 40, height: 20))
        failedPeelsLabel.text = "Total failed peels: \(failedPeelCount)"
        failedPeelsLabel.textColor = UIColor.black
        failedPeelsLabel.textAlignment = .center
        self.addSubview(failedPeelsLabel)
        
        // Add this game's words label
        let wordsLabel = UILabel(frame: CGRect(x: 20, y: 170, width: width! - 40, height: 20))
        wordsLabel.text = "Your bananagrams:"
        wordsLabel.textColor = UIColor.black
        wordsLabel.textAlignment = .center
        self.addSubview(wordsLabel)
        
        // Create the close button
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: width! - 40, y: 0, width: 40, height: 40)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(UIColor.red, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        self.addSubview(closeButton)
        
        wordsTableView = UITableView(frame: CGRect(x: 20, y: 200, width: width! - 40, height: height! - 250))
        wordsTableView!.dataSource = self
        wordsTableView!.delegate = self
        wordsTableView!.layer.borderWidth = 3
        wordsTableView!.clipsToBounds = true
        wordsTableView!.layer.cornerRadius = 10
        wordsTableView!.layer.borderColor = UIColor.black.cgColor
        wordsTableView!.allowsSelection = false
        self.words = words
        self.words!.sort()
        self.addSubview(wordsTableView!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.words!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = words![indexPath.row]
        return cell
    }

        
    @objc func closeButtonTapped() {
        self.removeFromSuperview()
        // Handle the close button tap action here
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
