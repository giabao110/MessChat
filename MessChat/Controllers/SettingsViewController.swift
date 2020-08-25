//
// SettingsViewController.swift
// MessChat
//
// Created by GIABAO Photography on 8/19/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableViewSet: UITableView!
    
    let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSet.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableViewSet.delegate = self
        tableViewSet.dataSource = self
    }
    
}

extension SettingsViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "",
                                      message: "",
                                      preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive,
                                            handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
                                                
            // Log out Facebook
            
            FBSDKLoginKit.LoginManager().logOut()
                                                
            // Log out Google

            GIDSignIn.sharedInstance()?.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = WelcomeViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
                print("Log Out")
            }
            catch  {
                print("Failed to Log Out")
            }
            
        }))
        present(actionSheet, animated: true)
    }
}

