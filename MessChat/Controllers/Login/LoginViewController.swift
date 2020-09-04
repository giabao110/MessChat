//
// LoginViewController.swift
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
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import RAGTextField
import ProgressHUD

final class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        return imageView
    }()
    
    private let imageTitleView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "messchatlogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "Email Address", imageName: "person", isSecureTextEntry: false)
    }()
    
    private var passwordField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "Password", imageName: "lock", isSecureTextEntry: true)
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()

    private let forgotPassButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password? ", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    // Background Color
    func setGradientBackground() {
        let gradient = CAGradientLayer() //99, 164, 255)
        let topColor = UIColor(red: 99/255, green: 164/255, blue: 255/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 131/255, green: 234/255, blue: 241/255, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0, 1]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at:0)
    }
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        setGradientBackground()
        title = "Log In"
        navigationController?.hideNavigationItemBackground()
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        forgotPassButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
        // Delegate
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(imageTitleView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(signUpButton)
        scrollView.addSubview(forgotPassButton)
       
        
        emailField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
        passwordField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
      
        let attributedText = NSMutableAttributedString(string: "Don't have an account? ",
        attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .light),
                     NSAttributedString.Key.foregroundColor : UIColor.white
        ])
   
        let attributedSubText = NSMutableAttributedString(string: "Sign up",
        attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold),
                     NSAttributedString.Key.foregroundColor : UIColor.white
        ])
        
        attributedText.append(attributedSubText)
        signUpButton.setAttributedTitle(attributedText, for: .normal)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width/6
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 10,
                                 width: size,
                                 height: size)
        
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        
        imageTitleView.frame = CGRect(x: 80,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-160,
                                  height: 80)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageTitleView.bottom+30,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+40,
                                   width: scrollView.width-60,
                                   height: 50)
        
        signUpButton.frame = CGRect(x: 60,
                                    y: loginButton.bottom+2,
                                    width: scrollView.width-120,
                                    height: 50)
        
        forgotPassButton.frame = CGRect(x: 60,
                                    y: signUpButton.bottom+270,
                                    width: scrollView.width-120,
                                    height: 50)
    }
    // Sign up
    @objc private func signUp(){
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Forgot password
    @objc private func forgotPassword(){
        let vc = ForgotPasswordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Login Button
    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        let validEmail = isValidEmail(emailField.text!)
        
        guard validEmail == true else {
            alertEmailError()
            return
        }
        
        guard let email = emailField.text,
            let password = passwordField.text,
            !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                alertUserLoginError()
                return
        }
        
        ProgressHUD.show()
        ProgressHUD.animationType = .circleSpinFade
        ProgressHUD.colorAnimation = .systemBlue
        
        // Firebase Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            
            guard case let result = authResult, error == nil else{
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                }
                let alert = UIAlertController(title: "Woops",
                                              message: "The password is not valid \n Please try again",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss",
                                              style: .cancel,
                                              handler: nil))
                
                self?.present(alert, animated: true)
                
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result!.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.share.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                        let lastName = userData["last_name"] as? String else {
                            return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("Fail to get data with error: \(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            print("Logged In User: \(user)")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        })
    }
    // Alert
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
        return
    }
    
    func alertEmailError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter correct email address !!!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
        return
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

