//
//  gamesCollectionViewCell.swift
//  JustSmallTHings
//
//  Created by Ken Alexopoulos on 8/9/22.
//

import UIKit

class gamesCVC: UICollectionViewCell {
    

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var locationOfGame: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var nameOfGame: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var sportOfGame: UILabel!
    @IBOutlet weak var timeOfGame: UILabel!
    @IBOutlet weak var dateOfGame: UILabel!
    @IBOutlet weak var numberOfPlayers: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Initialization code
    }

}
