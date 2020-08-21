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


class LoginViewController: UIViewController {
    
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
    
    private let emailField: RAGTextField = {
        let field = RAGTextField()
        if let myImage = UIImage(systemName: "person"){
            field.withImage(direction: .Left, image: myImage)
        }
        field.transformedPlaceholderColor = .lightGray
        field.placeholderColor = .lightGray
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 8
        field.borderStyle = .none
        field.placeholderMode = .scalesWhenNotEmpty
        field.placeholder = "Email Address"
        field.textColor = .white
        return field
    }()
    
    private let passwordField: RAGTextField = {
        let field = RAGTextField()
        if let myImage = UIImage(systemName: "lock"){
            field.withImage(direction: .Left, image: myImage)
        }
        field.transformedPlaceholderColor = .lightGray
        field.placeholderColor = .lightGray
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 8
        field.borderStyle = .none
        field.placeholderMode = .scalesWhenNotEmpty
        field.placeholder = "Password"
        field.textColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3948340416, green: 0.3551002145, blue: 0.9879776835, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()
    
    private let googleLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Connect with Google", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3948340416, green: 0.3551002145, blue: 0.9879776835, alpha: 1)
//        button.setImage(UIImage(named: "google"), for: .normal)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0,left: 50,bottom: 0,right: 25)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.addTarget(self, action: #selector(openGoogle), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    //     Google Button Connect
    @objc private func openGoogle(){
        GIDSignIn.sharedInstance().signIn()
    }
    
    // Background Color
    func setGradientBackground() {
        let gradient = CAGradientLayer()
        let topColor = UIColor(red: 13/255, green: 50/255, blue: 77/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 127/255, green: 90/255, blue: 131/255, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0, 1]
        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, at:0)
    }
    
    //    -------
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email, public_profile"]
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
         button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 25,left: 25,bottom: 25,right: 25)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        //        button.imageView?.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0)
        return button
    }()
    
    //        private let googleLoginButton: GIDSignInButton = {
//            let button = GIDSignInButton()
////            button.layer.cornerRadius = 12
////            button.layer.masksToBounds = true
//
//            return button
//        }()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                               object: nil,
                                                               queue: .main,
                                                               using: { [weak self] _ in
                                                                guard let strongSelf = self else {
                                                                    return
                                                                }
                                                                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        setGradientBackground()
        title = "Log In"
        navigationController?.hideNavigationItemBackground()
        
        let rightBarButton = UIBarButtonItem(title: "Register",
                                             style: .done,
                                             target: self,
                                             action: #selector(didTapRegister))
        
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookLoginButton.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = view.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+40,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+15,
                                     width: scrollView.width-60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 60,
                                   y: passwordField.bottom+40,
                                   width: scrollView.width-120,
                                   height: 52)
        
        facebookLoginButton.frame = CGRect(x: 100,
                                           y: loginButton.bottom+230,
                                           width: scrollView.width-200,
                                           height: 52)
        
        googleLoginButton.frame = CGRect(x: 100,
                                         y: facebookLoginButton.bottom+10,
                                         width: scrollView.width-200,
                                         height: 52)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.bounds.width / 2
    }
    
    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
            let password = passwordField.text,
            !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                alertUserLoginError()
                return
        }
        
        // Firebase Log In
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            
            guard let strongSelf = self else {
                return
            }
            guard case let result = authResult, error == nil else{
                print("Failed to log in user with email: \(email)")
                let alert = UIAlertController(title: "Woops",
                                              message: "Mat khau khong chinh xac",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss",
                                              style: .cancel,
                                              handler: nil))
                
                self?.present(alert, animated: true)
                return
            }
            
            let user = result!.user
            print("Logged In User: \(user)")
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func alertUserLoginError() {
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

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with Facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String:Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            guard let userName = result["name"] as? String,
                let email = result["email"] as? String else {
                    print("Failed to get email and name from Facebook result")
                    return
            }
            
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.share.userExists(with: email, completion: { exists in
                if !exists {
                    DatabaseManager.share.insertUser(with: ChatAppUser(firstName: firstName,
                                                                       lastName: lastName,
                                                                       emailAddress: email))
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self]authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else{
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed : \(error)")
                    }
                    return
                }
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
}

extension UITextField {
    
    enum Direction {
        case Left
        case Right
    }
    
    // add image to textfield , colorSeparator: UIColor, colorBorder: UIColor
    func withImage(direction: Direction, image: UIImage){
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        mainView.layer.cornerRadius = 5
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
        view.backgroundColor = .clear
        view.tintColor = .white
    
        mainView.addSubview(view)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 12.0, y: 14.0, width: 24.0, height: 24.0)
        
        view.addSubview(imageView)
        
        let seperatorView = UIView()
        mainView.addSubview(seperatorView)
        
        if(Direction.Left == direction){ // image left
            seperatorView.frame = CGRect(x: 45, y: 0, width: 0, height: 45)
            self.leftViewMode = .always
            self.leftView = mainView
        } else { // image right
            seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
            self.rightViewMode = .always
            self.rightView = mainView
        }
    }
}





