//
// FriendsViewController.swift
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
import FirebaseAuth
import SDWebImage
import Stevia

final class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let model = friends[indexPath.row]
              let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier,
                                                       for: indexPath) as! ContactTableViewCell
              cell.configureFriends(with: model)
              return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    private var friends = [FriendRequest]()
    
    private var loginObserver: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Friend Request"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(ContactTableViewCell.self,
                           forCellReuseIdentifier: ContactTableViewCell.identifier )
        
        view.sv(
            tableView,
            noConversationsLabel
        )
        
        tableView.left(0).right(0).top(0).bottom(0)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        startListeningForConversation()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.startListeningForConversation()
        })
    }
    
    private func startListeningForConversation() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("Starting Friends fetch...")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        print("\(safeEmail)")
        
        DatabaseManager.share.getAllFriendRequest(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let friends):
                print("Successfully got Friends models")
                guard !friends.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.tableView.isHidden = false
                self?.noConversationsLabel.isHidden = true
                self?.friends = friends
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("Failed to get convos Friends: \(error)")
            }
        })
    }
    
    
}
