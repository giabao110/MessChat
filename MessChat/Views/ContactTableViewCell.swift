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
import Foundation

class ContactTableViewCell: UITableViewCell {
    
    static let identifier = "ContactTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public let addFriendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add friend +", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 10)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = UserDefaults.standard.value(forKey: "email") as? String ?? "No Email User"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.sv(
            userImageView,
            userNameLabel,
            addFriendButton,
            emailLabel
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let profileImageDimension: CGFloat = 70
        
        
        userImageView.style { f in
            f.layer.cornerRadius = profileImageDimension/2
        }
        
        userImageView.centerVertically()
        userImageView.left(16).size(profileImageDimension)
        userNameLabel.width(50%)
        emailLabel.width(50%)

        userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor, constant: -10).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor,constant: 16).isActive  = true
        
        emailLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor, constant: 10).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor,constant: 16).isActive  = true
        
        addFriendButton.centerVertically()
        addFriendButton.right(10).width(100).height(40)
    }
    
    public func configureFriends(with model: FriendRequest) {
        userNameLabel.text = model.name
        
        emailLabel.font = .systemFont(ofSize: 16, weight: .regular)
        emailLabel.textColor = .lightGray
        emailLabel.text = "Send you a friend invitation"

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
