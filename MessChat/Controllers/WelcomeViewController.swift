//
// WelcomeViewController.swift
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

class WelcomeViewController: UIViewController {
    
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
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "Welcome to MessChat"
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 30, weight: .bold)
        return textView
    }()
    
    private let textViewDes: UITextView = {
        let textViewDes = UITextView()
        textViewDes.text = "Free Messaging, voice and videos, and more!"
        textViewDes.textAlignment = .center
        textViewDes.font = .systemFont(ofSize: 18, weight: .light)
        return textViewDes
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3948340416, green: 0.3551002145, blue: 0.9879776835, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        //      button.titleLabel?.font = UIFont(name: "Alata-Regular", size: 40)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hideNavigationItemBackground() 
        view.backgroundColor = .white

        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
     
        // Add subviews
        view.addSubview(scrollView)
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(textViewDes)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = view.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y:250,
                                 width: size,
                                 height: size)
        
        textView.frame = CGRect(x: 30,
                                y: imageView.bottom+10,
                                width: scrollView.width-60,
                                height: 52)
        
        textViewDes.frame = CGRect(x: 30,
                                   y: textView.bottom+2,
                                   width: scrollView.width-60,
                                   height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: imageView.bottom+300,
                                   width: scrollView.width-60,
                                   height: 52)
    }
    
    @objc private func loginButtonTapped() {
let vc = LoginViewController()
       navigationController?.pushViewController(vc, animated: true)
        }
        
      
    
    func  alertUserLoginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }
    
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Accout"
        navigationController?.pushViewController(vc, animated: true)
        
    }
}



