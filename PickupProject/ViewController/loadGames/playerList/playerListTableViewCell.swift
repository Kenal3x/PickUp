//
//  playerListTableViewCell.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 6/30/21.
//

import UIKit

class playerListTableViewCell: UITableViewCell {

    @IBOutlet weak var userRole: UILabel!
    @IBOutlet weak var userProfilePicture: UIImageView!
    
    @IBOutlet weak var userDisplayName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }
    
}
