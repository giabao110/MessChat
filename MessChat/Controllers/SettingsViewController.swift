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
import ProgressHUD

private let reuseIdentifier = "SettingCell"

class SettingsViewController: UIViewController {
    
    
    var tableView: UITableView!
    var userInfoHeader: UserInfoHeader!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        userInfoHeader.imageProfile()
        navigationController?.hideNavigationItemBackground()
    }
    
    func configureTableView(){
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        tableView.register(SettingCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        tableView.tableHeaderView = userInfoHeader
        tableView.tableFooterView = UIView()
    }
    
    func configureUI() {
        configureTableView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingSection(rawValue: section) else {
            return 0
        }
        switch section {
        case .Social: return SocialOptions.allCases.count
        case .Communications: return CommunicationsOptions.allCases.count
        case .Logout: return LogOutOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray5
        let title = UILabel()
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .systemBackground
        title.text = SettingSection(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingCell
        guard let section = SettingSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .Social:
            let social = SocialOptions(rawValue: indexPath.row)
            cell.sectionType = social
            cell.imageView?.contentMode = .scaleAspectFit
            let name = cell.sectionType?.description
            
            switch name! {
            case "Edit Profile":
                cell.imageView?.image = UIImage(systemName: "pencil.circle.fill")
                cell.imageView?.tintColor = .systemYellow
            case "Saved Messages":
                cell.imageView?.image = UIImage(systemName: "message.circle.fill")
                cell.imageView?.tintColor = .systemOrange
            case "Devices":
                cell.imageView?.image = UIImage(systemName: "tv.circle.fill")
                cell.imageView?.tintColor = .systemBlue
            case "Chat Folder":
                cell.imageView?.image = UIImage(systemName: "folder.circle.fill")
                cell.imageView?.tintColor = .systemRed
            default:
                break
            }
            
        case .Communications:
            let communications = CommunicationsOptions(rawValue: indexPath.row)
            cell.sectionType = communications
            cell.imageView?.contentMode = .scaleAspectFit
            let name = cell.sectionType?.description
            
            switch name! {
            case "Dark Mode":
                cell.imageView?.image = UIImage(systemName: "moon.circle.fill")
                cell.imageView?.tintColor = .systemBlue
            case "Notifications and Sounds":
                cell.imageView?.image = UIImage(systemName: "envelope.circle.fill")
                cell.imageView?.tintColor = .systemGreen
            case "Privacy and Security":
                cell.imageView?.image = UIImage(systemName: "lock.circle.fill")
                cell.imageView?.tintColor = .systemOrange
            case "Data and Storage":
                cell.imageView?.image = UIImage(systemName: "icloud.circle.fill")
                cell.imageView?.tintColor = .systemYellow
            case "Report Crashes":
                cell.imageView?.image = UIImage(systemName: "ant.circle.fill")
                cell.imageView?.tintColor = .systemRed
            default:
               break
            }
            
        case .Logout:
            let logout = LogOutOptions(rawValue: indexPath.row)
            cell.sectionType = logout
            cell.imageView?.contentMode = .scaleAspectFit
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingSection(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .Social:
            guard let name = SocialOptions(rawValue: indexPath.row)?.description else {
                return
            }
            switch name {
            default:
                ProgressHUD.showError("Error", image: nil, interaction: false)
            }
            
        case .Communications:
            guard let name = CommunicationsOptions(rawValue: indexPath.row)?.description else {
               return
           }
           switch name {
           default:
               ProgressHUD.showError("Error", image: nil, interaction: false)
            }
            
        case .Logout:
            guard let name = LogOutOptions(rawValue: indexPath.row)?.description else {
                return
            }
            if name == "Log Out" {
                logOut()
            }
        }
    }

    
    func logOut() {
        let actionSheet = UIAlertController(title: "Sign Out?",
                                            message: "You can always access your content by signing back in",
                                            preferredStyle: UIAlertController.Style.alert)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "name")
            UserDefaults.standard.setValue(nil, forKey: "phone")
            
            // LOG OUT FACEBOOK
            FBSDKLoginKit.LoginManager().logOut()
            
            // LOG OUT GOOGLE
            GIDSignIn.sharedInstance()?.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
                self.tableView.reloadData()
                print("LOG OUT")
            }
            catch  {
                print("Failed to Log Out !!!")
            }
        }))
        self.present(actionSheet, animated: true)
    }
}



