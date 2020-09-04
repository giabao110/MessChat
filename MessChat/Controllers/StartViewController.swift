//
// StartViewController.swift
// MessChat
//
// Created by GIABAO Photography on 9/1/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import RAGTextField
import JGProgressHUD
import ProgressHUD

class StartViewController: UIViewController {
    
    private let spinnerStart = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textView: UILabel = {
        let textView = UILabel()
        textView.text = "Welcome to MessChat"
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 32, weight: .bold)
        textView.textColor = .black
        return textView
    }()
    
    private let textViewDes: UILabel = {
        let textViewDes = UILabel()
        textViewDes.text = "Free Messaging, voice and videos, and more"
        textViewDes.textAlignment = .center
        textViewDes.font = .systemFont(ofSize: 18, weight: .light)
        textViewDes.contentMode = .scaleAspectFit
        textViewDes.numberOfLines = 0
        textViewDes.textColor = .black
        textViewDes.lineBreakMode = NSLineBreakMode.byCharWrapping
        return textViewDes
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.hideNavigationItemBackground()
        view.backgroundColor = .white
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        registerButton.addTarget(self,
                                 action: #selector(registerButtonTapped),
                                 for: .touchUpInside)
        
        // Add subviews
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(textViewDes)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        imageView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: 100,
                                 height: 100)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width/4
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: scrollView.height/4,
                                 width: size,
                                 height: size)
        
        textView.frame = CGRect(x: 30,
                                y: imageView.bottom+10,
                                width: scrollView.width-60,
                                height: 50)
        
        textViewDes.frame = CGRect(x: 30,
                                   y: textView.bottom+2,
                                   width: scrollView.width-60,
                                   height: 60)
        
        loginButton.frame = CGRect(x: 30,
                                   y: imageView.bottom+400,
                                   width: scrollView.width-60,
                                   height: 50)
        
        registerButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom+10,
                                           width: scrollView.width-60,
                                           height: 50)
    }
    
    @objc private func loginButtonTapped() {
         let vc = WelcomeViewController()
         navigationController?.pushViewController(vc, animated: true)
     }
    
    @objc private func registerButtonTapped() {
         let vc = RegisterViewController()
               vc.title = "Create Accout"
               navigationController?.pushViewController(vc, animated: true)
    }
}
