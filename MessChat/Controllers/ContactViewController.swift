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

final class ContactViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var data = [ProfileViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBar()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.indentifier)

        tableView.delegate = self
        tableView.dataSource = self

    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.view.width,
                                              height: 300))
        
        let imageView = UIImageView(frame: CGRect(x:(headerView.width-150)/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
        headerView.backgroundColor = #colorLiteral(red: 0.4002331495, green: 0.668225348, blue: 0.9957198501, alpha: 1)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.share.downloadURL(for: path, completion: {result in
            switch result {
            case .success(let url):
               imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Fail to get download url: \(error)")
            }
        })
        return headerView
    }
}

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.indentifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}

class ProfileTableViewCell: UITableViewCell {
    
    static var indentifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel) {
        textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .center
            selectionStyle = .none
            textLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        case .logout:
            textLabel?.textAlignment = .center
        }
    }
}
