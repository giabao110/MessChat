//
// NewContactViewController.swift
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
import JGProgressHUD
import ProgressHUD
import Stevia

final class NewContactViewController: UIViewController {
    
    public var completion: ((SearchResult) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]] ()
    
    private var results = [SearchResult] ()
    
    private var conversations = [Conversation]()
    
    private var hasFetched = false
    
    private var hasClick = false
    
    public var isNewConversation = false
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(ContactCell.self,
                           forCellReuseIdentifier: ContactCell.identifier)
        return tableView
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sv(
            noResultsLabel,
            tableView
        )
        
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder() // Keyboard show on screen
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.centerVertically()
        noResultsLabel.centerHorizontally()
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewContactViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifier, for: indexPath) as! ContactCell
        
        cell.addFriendButton.tag = indexPath.row
        cell.addFriendButton.addTarget(self, action: #selector(addFriendTapped(_:)), for: .touchUpInside)
        cell.configuree(with: model)
        if hasClick == true {
            createFriendRequest(model)
//            cell.addFriendButton.backgroundColor = .red
            hasClick = false
        }
        return cell
    }
    
    @objc func addFriendTapped(_ sender: UITableView){
          hasClick = true
          tableView.reloadData()
       }
    
    func createFriendRequest(_ model: SearchResult) {
        ProgressHUD.showSucceed("Sending Friend Request", interaction: false)
        ProgressHUD.colorAnimation = .systemGreen
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        
        let newIdentifier  = "Conversation_\(model.email)_\(safeCurrentEmail)_\(dateString)"
        
        let email = DatabaseManager.safeEmail(emailAddress: model.email)
        DatabaseManager.share.fiendsExists(with: email, completion: { result in
            
            switch result {
            case .success(let conversationId):
                
                ProgressHUD.showSucceed("\(conversationId)", interaction: false)
                ProgressHUD.colorAnimation = .systemGreen
                
            case .failure(_):
                
                DatabaseManager.share.createNewFiendRequest(with: model.email, name: model.name, phone: model.phone,id: newIdentifier, completion: { success in
                    if success {
                        print("Messege sent...")
                    }
                    else {
                        print("Failed to sent")
                    }
                })
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension NewContactViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        searchUser(query: text)
    }
    
    func searchUser(query: String) {
        // Check if array has firebase result
        if hasFetched {
            // If it does: Filer
            filterUsers(with: query)
        }
        else {
            // If not: Fetch then filler
            DatabaseManager.share.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term: String) {
        // Update the UI: either show results or show no results label
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
                return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        spinner.dismiss()
        
        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"],
                let name = $0["name"],
            let phone = $0["phone"] else {
                return nil
            }
            return SearchResult(name: name, email: email, phone: phone )
        })
        self.results = results
        updateUI()
    }
    
    func updateUI(){
        if results .isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
