//
// ViewController.swift
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

class ConversationsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
      validateAuth()
    
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
}

