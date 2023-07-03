//
//  conversationTableViewCell.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 7/11/21.
//

import UIKit
import Foundation
import FirebaseStorage
import SDWebImage


class conversationTableViewCell: UITableViewCell {
    
    static let identitier = "ConversationTableViewCell"
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
        
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(userImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        usernameLabel.frame = CGRect(x: userImageView.right + 10, y: 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height - 20)/2)
        userMessageLabel.frame = CGRect(x: userImageView.right + 10, y: usernameLabel.bottom + 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height - 20)/2)
    }
    
    public func configure(with model: Conversation){
        self.userMessageLabel.text = model.latestMessage.text
        self.usernameLabel.text = model.name
        print(model.latestMessage.text)
        print(model.name)
        let path = "\(model.otherUserUID)/profilePicture.jpeg"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("No profile PIc")
                self?.userImageView.image = UIImage(named: "blankprofile")
            
            }
        })
        
    }
}
