//
//  GameTableViewCell.swift
//  PickupProject
//
//  Created by Sharmeen Lalani on 6/5/21.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeOfGame: UILabel!
    @IBOutlet weak var dateOfGame: UILabel!


    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var locationOfGame: UILabel!
    @IBOutlet weak var sportOfGame: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
