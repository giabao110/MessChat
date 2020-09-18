//
// ContactViewController.swift
// MessChat
//
// Created by GIABAO Photography on 8/16/20.
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

final class ContactViewController: UIViewController {
    
    @IBAction func didTapContactButton(_ sender: Any) {
        didTapContactButton()
    }
    
    @IBOutlet weak var buttonFriendRequest: UIBarButtonItem!
    
    @IBAction func didTapRequestFriend(_ sender: Any) {
        
    }
    
    private var hasClick = false
    
    private var friends = [FriendRequest]()
    
    private var conversations = [Conversation]()
    
    private var contacts = [Contacts]()
    
    private var loginObserver: NSObjectProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBar()

    }
    
    private let noContactsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Contacts"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let badgetButton: UIButton = {
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        rightButton.setBackgroundImage(UIImage(systemName: "person.fill"), for: .normal)
        rightButton.tintColor = .white
        return rightButton
    }()
    
    private let badgetLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 12, y: -12, width: 20, height: 20))
        label.layer.borderColor = UIColor.clear.cgColor
        label.layer.borderWidth = 2
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .systemRed
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ContactVTableViewCell.self,
                           forCellReuseIdentifier: ContactVTableViewCell.identifier )
        tableView.delegate = self
        tableView.dataSource = self
        
        badgetButton.addTarget(self, action: #selector(rightButtonTouched), for: .touchUpInside)
        badgetButton.addSubview(badgetLabel)
        badgetLabel.isHidden = true
        
        NSLayoutConstraint.activate([
        ])
        
        view.sv(
            tableView,
            noContactsLabel
        )
        tableView.left(0).right(0).top(0).bottom(0)
        noContactsLabel.centerVertically().centerHorizontally().left(0).right(0).top(0).bottom(0)
        tableView.tableFooterView = UIView()
        
        // Bar button item
        let rightBarButtomItem = UIBarButtonItem(customView: badgetButton)
        navigationItem.rightBarButtonItem = rightBarButtomItem
        
        startListeningForContacts()
        startListeningForFriendRequest()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.startListeningForFriendRequest()
            strongSelf.startListeningForContacts()
        })
    }
    
    private func startListeningForFriendRequest() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        print("Starting Friends fetch...")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        DatabaseManager.share.getAllFriendRequest(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let friends):
                guard !friends.isEmpty else {
                    self?.badgetLabel.isHidden = true
                    return
                }
                self?.friends = friends
                self?.badgetLabel.text = "\(friends.count)"
                self?.badgetLabel.isHidden = false
                
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
                //                }
            case .failure(let error):
                self?.badgetLabel.isHidden = true
                print("Failed to get convos Friends: \(error)")
            }
        })
    }
    
    private func startListeningForContacts() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        print("Starting Contacts fetch...")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.share.getAllContacts(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let contacts):
                print("Successfully got Contacts models")
                guard !contacts.isEmpty else {
                    self?.noContactsLabel.isHidden = false
                    self?.tableView.isHidden = true
                    return
                }
                self?.tableView.isHidden = false
                self?.noContactsLabel.isHidden = true
                self?.contacts = contacts
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.noContactsLabel.isHidden = false
                self?.tableView.isHidden = true
                print("Failed to get convos Contacts: \(error)")
            }
        })
    }
    
    @objc func rightButtonTouched() {
        let vc = FriendsViewController()
        vc.title = "Friend Request"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapContactButton(){
        let vc = NewContactViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            let currentConversation = strongSelf.conversations
            
            if let targetConversation = currentConversation.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }){
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                strongSelf.createNewContacts(results: result)
            }
        }
        let naVC = UINavigationController(rootViewController: vc)
        present(naVC, animated: true)
    }

    private func createNewContacts(results: SearchResult){
        let name = results.name
        let email = DatabaseManager.safeEmail(emailAddress: results.email)
        DatabaseManager.share.conversationExists(with: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)

            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = contacts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactVTableViewCell.identifier,
                                                 for: indexPath) as! ContactVTableViewCell
        cell.addNewConversation.tag = indexPath.row
        cell.addNewConversation.addTarget(self, action: #selector(newConversation(_:)), for: .touchUpInside)
        
        cell.callButton.tag = indexPath.row
        cell.callButton.addTarget(self, action: #selector(newCall(_:)), for: .touchUpInside)
        
        cell.configureContact(with: model)
        
        if hasClick == true {
            createFriendRequest(model)
            print("createFriendRequest")
            hasClick = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = contacts[indexPath.row]
        createFriendRequest(model)
    }
    
    @objc func newConversation(_ sender: UITableView){
        hasClick = true
        print(hasClick)
        tableView.reloadData()
    }
    
    @objc func newCall(_ sender: UITableView){
        ProgressHUD.showFailed()
        tableView.reloadData()
    }
    
    func createFriendRequest(_ model: Contacts) {
        print("\(model.name),\(model.otherUserEmail)")
        let name = model.name
        let email = DatabaseManager.safeEmail(emailAddress: model.otherUserEmail)
        DatabaseManager.share.conversationExists(with: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                print("ABC")
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                print("Success")
                
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                print("Failed")
            }
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

