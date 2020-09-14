//
// UserInfoHeader.swift
// MessChat
//
// Created by GIABAO Photography on 9/9/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import UIKit
import FirebaseAuth
import SDWebImage
import Stevia


class UserInfoHeader: UIView {

    let profileImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.image = UIImage(named: "image_icon")
        imv.layer.borderColor = UIColor.white.cgColor
        imv.layer.borderWidth = 3
        return imv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = UserDefaults.standard.value(forKey: "name") as? String ?? "No Name User"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        let profileImageDimension: CGFloat = 80
        
        addSubview(profileImageView)
        profileImageView.style { f in
            f.layer.cornerRadius = profileImageDimension/2
        }
        
        profileImageView.centerVertically()
        profileImageView.left(16).width(profileImageDimension).height(profileImageDimension)
        
        addSubview(usernameLabel)
        usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -10).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant: 16).isActive  = true
        
        addSubview(emailLabel)
        emailLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 10).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,constant: 16).isActive  = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func imageProfile() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        StorageManager.share.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.profileImageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Fail to get download url: \(error)")
            }
        })
    }
}

