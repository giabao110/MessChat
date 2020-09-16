//
// ContactTableViewCell.swift
// MessChat
//
// Created by GIABAO Photography on 9/14/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import UIKit
import SDWebImage
import Stevia

class ContactTableViewCell: UITableViewCell {
    
    static let identifier = "ContactTableViewCell"
    
    private let userImageView = UIImageView()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.isHidden = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.sv(
            userImageView,
            userNameLabel,
            userMessageLabel,
            iconImageView
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let profileImageDimension: CGFloat = 80
        
        userImageView.centerVertically()
        
        userImageView.style { f in
            f.layer.cornerRadius = profileImageDimension/2
            f.contentMode = .scaleAspectFill
            f.layer.cornerRadius = 40
            f.layer.masksToBounds = true
        }
        
        userImageView.left(16).size(profileImageDimension)
        userNameLabel.width(60%).height(20%)
        userMessageLabel.width(60%).height(20%)
        
        userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor, constant: -15).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor,constant: 16).isActive  = true
        
        
        userMessageLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor, constant: 15).isActive = true
        userMessageLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor,constant: 16).isActive  = true
        
        iconImageView.centerVertically()
        iconImageView.right(16).size(10)
        
    }
    
    public func configureFriends(with model: FriendRequest) {
        userNameLabel.text = model.name
   print("name: \(model.name) , \(model.phoneNumber),\(model.otherUserEmail) ")
            userMessageLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            userMessageLabel.textColor = .black
        userMessageLabel.text = model.phoneNumber
          
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.share.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case.success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to get images url: \(error)")
            }
        })
    }
}
