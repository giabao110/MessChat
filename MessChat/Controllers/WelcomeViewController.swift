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
import Lottie

class WelcomeViewController: UIViewController {
    
    private let animationView: AnimationView = {
        let animation = AnimationView()
        
        animation.animation = Animation.named("test")
        animation.contentMode = .scaleToFill
        animation.loopMode = .loop
        animation.play()
        
        return animation
    }()
        
    
    
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
        textView.font = .systemFont(ofSize: 30, weight: .bold)
        return textView
    }()
    
    private let textViewDes: UILabel = {
        let textViewDes = UILabel()
        textViewDes.text = "Free Messaging, voice and videos, and more!"
        textViewDes.textAlignment = .center
        textViewDes.font = .systemFont(ofSize: 18, weight: .light)
        textViewDes.contentMode = .scaleAspectFit
//        textViewDes.centerView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
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
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3948340416, green: 0.3551002145, blue: 0.9879776835, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
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
        view.addSubview(scrollView)
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(textViewDes)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
//        view.addSubview(animationView)
        imageView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: 100,
                                     height: 100)
        animationView.center = view.center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = view.width/6
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
                                   height: 100)
        
        loginButton.frame = CGRect(x: 30,
                                   y: imageView.bottom+400,
                                   width: scrollView.width-60,
                                   height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                   y: loginButton.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
//        animationView.frame = CGRect(x: 30,
//                                         y: loginButton.bottom+300,
//                                         width: scrollView.width-60,
//                                         height: 52)
    }
    
    @objc private func registerButtonTapped() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
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



