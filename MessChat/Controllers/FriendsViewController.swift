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
import ProgressHUD

final class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = friends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier,
                                                 for: indexPath) as! ContactTableViewCell
        cell.addFriendButton.tag = indexPath.row
        cell.addFriendButton.addTarget(self, action: #selector(addFriendTapped(_:)), for: .touchUpInside)
        cell.configureFriends(with: model)
        if hasClick == true {
            createFriendRequest(model)
            hasClick = false
        }
        return cell
    }
    
    @objc func addFriendTapped(_ sender: UITableView){
        hasClick = true
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = friends[indexPath.row]
        createFriendRequest(model)
    }
    
    func createFriendRequest(_ model: FriendRequest) {
        ProgressHUD.showSucceed("Added 1 new contact", interaction: false)
        ProgressHUD.colorAnimation = .systemGreen
        
        let newIdentifier  = "\(model.id)"
        
        let email = DatabaseManager.safeEmail(emailAddress: model.otherUserEmail)
        DatabaseManager.share.contactsExists(with: email, completion: { result in
            
            switch result {
            case .success(let conversationId):
                ProgressHUD.showSucceed("\(conversationId)", interaction: false)
                ProgressHUD.colorAnimation = .systemGreen
                
            case .failure(_):
                
                DatabaseManager.share.createNewContact(with: model.otherUserEmail, name: model.name, phone: model.phoneNumber,id: newIdentifier, completion: { success in
                    if success {
                        print("Successsss")
                    }
                    else {
                        print("Failed")
                    }
                })
                
                DatabaseManager.share.deleteFriendsRequest(conversationId: newIdentifier, completion: { success in
                    if !success {
                        // Add model and row back and show error alert
                    }
                })
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let model = friends[indexPath.row]
        if editingStyle == .delete {
            let alert = UIAlertController(title: "", message: "Are you sure you want to permanently delete this friend invitation?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                // Begin delete conversation
                let friendsId = model.id
                tableView.beginUpdates()
                self?.friends.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                DatabaseManager.share.deleteFriendsRequest(conversationId: friendsId, completion: { success in
                    if !success {
                        // Add model and row back and show error alert
                    }
                })
                tableView.endUpdates()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private var friends = [FriendRequest]()
    
    private var hasClick = false
    
    private var loginObserver: NSObjectProtocol?
    
    private let tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    private let noFriendLabel: UILabel = {
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
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(ContactTableViewCell.self,
                           forCellReuseIdentifier: ContactTableViewCell.identifier )
        
        view.sv(
            tableView,
            noFriendLabel
        )
        
        tableView.left(0).right(0).top(0).bottom(0)
        noFriendLabel.centerVertically().centerHorizontally().left(0).right(0).top(0).bottom(0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
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
                    self?.noFriendLabel.isHidden = false
                    self?.tableView.isHidden = true
                    return
                }
                self?.tableView.isHidden = false
                self?.noFriendLabel.isHidden = true
                self?.friends = friends
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.noFriendLabel.isHidden = false
                self?.tableView.isHidden = true
                print("Failed to get convos Friends: \(error)")
            }
        })
    }
}
