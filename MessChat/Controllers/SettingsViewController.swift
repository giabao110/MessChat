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

final class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableViewSet: UITableView!
    
    var data = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log Out", handler: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "Sign Out?",
                                                message: "You can always access your content by signing back in",
                                                preferredStyle: UIAlertController.Style.alert)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
                
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                
                // LOG OUT FACEBOOK
                FBSDKLoginKit.LoginManager().logOut()
                
                // LOG OUT GOOGLE
                GIDSignIn.sharedInstance()?.signOut()
                
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
                    print("LOG OUT")
                }
                catch  {
                    print("Failed to Log Out !!!")
                }
            }))
            strongSelf.present(actionSheet, animated: true)
        }))
        tableViewSet.register(LogOutTableViewCell.self, forCellReuseIdentifier: LogOutTableViewCell.indentifier)
        tableViewSet.delegate = self
        tableViewSet.dataSource = self
    }
}

extension SettingsViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LogOutTableViewCell.indentifier, for: indexPath) as! LogOutTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}

class LogOutTableViewCell: UITableViewCell {
    
    static var indentifier = "LogOutTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel) {
        self.textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            self.textLabel?.textAlignment = .center
        case .logout:
            self.textLabel?.textColor = .red
            self.textLabel?.textAlignment = .center
            self.textLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        }
    }
}
