//
// ConversationTableViewCell.swift
// MessChat
//
// Created by GIABAO Photography on 8/23/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
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
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(iconImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 80,
                                     height: 80)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 12,
                                     y: 15,
                                     width: contentView.width - 40 - userImageView.width,
                                     height: (contentView.height - 40)/2)
        
        userMessageLabel.frame = CGRect(x: userImageView.right + 12,
                                        y: userNameLabel.bottom + 0 ,
                                        width: contentView.width - 70 - userImageView.width,
                                        height: (contentView.height - 20)/2)
        
        iconImageView.frame = CGRect(x: userMessageLabel.right + 12,
                                     y: contentView.height / 2 ,
                                     width: 10,
                                     height: 10)
    }
    
    public func configure(with model: Conversation) {
        userNameLabel.text = model.name
        if model.latestMessage.isRead == false {
            userMessageLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            userMessageLabel.textColor = .black
            userMessageLabel.text = model.latestMessage.text
            iconImageView.isHidden = false
        }
        else
        {
            userMessageLabel.text = model.latestMessage.text
            userMessageLabel.textColor = .lightGray
            iconImageView.isHidden = true
        }
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
