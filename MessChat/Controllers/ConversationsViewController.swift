//
// ConversationsViewController.swift
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
import JGProgressHUD
import Stevia


/// Controller that shows list  of conversations
final class ConversationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func didTapComposeButton(_ sender: Any) {
        didTapComposeButton()
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    var count = 0
    
    private var conversations = [Conversation]()
    
    private var contacts = [Contacts]()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ConversationTableViewCell.self,
                           forCellReuseIdentifier: ConversationTableViewCell.identifier )
        
        tableView.tableFooterView = UIView()
        
        view.sv (
            tableView,
            noConversationsLabel
        )
        
        setupTableView()
        startListeningForConversation()
        startListeningForContacts()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.startListeningForConversation()
            strongSelf.startListeningForContacts()
        })
    }
    
    private func startListeningForConversation() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.share.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.tableView.isHidden = false
                self?.noConversationsLabel.isHidden = true
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("Failed to get convos: \(error)")
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
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        DatabaseManager.share.getAllContacts(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let contacts):
                guard !contacts.isEmpty else {
                    return
                }
                self?.contacts = contacts
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to get convos Contacts: \(error)")
            }
        })
    }
    
    @objc func didTapComposeButton(){
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            let currentConversation = strongSelf.contacts
            
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
                strongSelf.createNewConversation(results: result)
            }
        }
        let naVC = UINavigationController(rootViewController: vc)
        present(naVC, animated: true)
    }
    
    private func createNewConversation(results: SearchResult){
        let name = results.name
        let email = DatabaseManager.safeEmail(emailAddress: results.email)
        // Check in database if conversation with these two user exists
        // If it does, reuse conversation id
        // Otherwise use existing code
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.centerHorizontally().centerVertically()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
}

extension ConversationsViewController: UISearchBarDelegate {

}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
//        let modelContacts = contacts[indexPath.row]
        openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        DatabaseManager.share.isRead(conversationId: model.id)
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        print("Conversations\(model.otherUserEmail), \(model.id)")
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "", message: "Are you sure you want to permanently delete this conversation?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                // Begin delete conversation
                let conversationId = self?.conversations[indexPath.row].id
                tableView.beginUpdates()
                self?.conversations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                DatabaseManager.share.deleteConversation(conversationId: conversationId!, completion: { success in
                    if !success {
                    // Add model and row back and show error alert
                    }
                })
                tableView.endUpdates()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}

