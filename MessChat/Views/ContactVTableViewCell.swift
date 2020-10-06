//
// ContactVTableViewCell.swift
// MessChat
//
// Created by GIABAO Photography on 9/18/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import UIKit
import SDWebImage
import Stevia
import FirebaseAuth
import Foundation



class ContactVTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static let identifier = "ContactVTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public let addNewConversation: UIButton = {
        let button = UIButton()
        button.setTitle("Chat", for: .normal)
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 10)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    public let callButton: UIButton = {
        let button = UIButton()
        button.setTitle("Call", for: .normal)
        button.setImage(UIImage(systemName: "phone"), for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 10)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.sv(
            userImageView,
            userNameLabel,
            addNewConversation,
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
        
        userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor, constant: -12).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor,constant: 16).isActive  = true
        
        emailLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor, constant: 12).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor,constant: 16).isActive  = true
        
        addNewConversation.centerVertically()
        addNewConversation.right(10).width(75).height(40)
    }
    
    public func configureContact(with model: Contacts) {
        userNameLabel.text = model.name
        emailLabel.text = model.phoneNumber
        
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




    
