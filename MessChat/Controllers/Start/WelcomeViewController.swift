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
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import RAGTextField
import ProgressHUD


final class WelcomeViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let textView: UILabel = {
        let textView = UILabel()
        textView.text = "Log in to MESSCHAT"
        textView.textAlignment = .left
        textView.font = .systemFont(ofSize: 32, weight: .bold)
        textView.textColor = .white
        return textView
    }()
    
    private let textViewDes: UILabel = {
        let textViewDes = UILabel()
        textViewDes.text = "Log in with your registered email address to get started."
        textViewDes.textAlignment = .left
        textViewDes.font = .systemFont(ofSize: 18, weight: .light)
        textViewDes.contentMode = .scaleAspectFit
        textViewDes.numberOfLines = 0
        textViewDes.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textViewDes.lineBreakMode = NSLineBreakMode.byCharWrapping
        return textViewDes
    }()
    
    private let textViewDess: UILabel = {
        let textViewDes = UILabel()
        textViewDes.text = "If you linked your account to your Facebook or Google, you can also log in that way."
        textViewDes.textAlignment = .left
        textViewDes.font = .systemFont(ofSize: 18, weight: .light)
        textViewDes.contentMode = .scaleAspectFit
        textViewDes.numberOfLines = 0
        textViewDes.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textViewDes.lineBreakMode = NSLineBreakMode.byCharWrapping
        return textViewDes
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in with Email", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email, public_profile"]
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()
    
    private let googleLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue with Google", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        button.setImage(UIImage(named: "google"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 170)
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.addTarget(self, action: #selector(openGoogle), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    // Google Button Connect
    @objc private func openGoogle(){
        GIDSignIn.sharedInstance().signIn()
    }
    
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
        setGradientBackground()
        navigationController?.hideNavigationItemBackground() 
        view.backgroundColor = .white
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        facebookLoginButton.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(textView)
        scrollView.addSubview(textViewDes)
        scrollView.addSubview(textViewDess)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
//        let size = view.width/3
        //        imageView.frame = CGRect(x: (scrollView.width-size)/2,
        //                                 y:250,
        //                                 width: size,
        //                                 height: size)
        
        textView.frame = CGRect(x: 30,
                                y:20,
                                width: scrollView.width-60,
                                height: 50)
        
        textViewDes.frame = CGRect(x: 30,
                                   y: textView.bottom+5,
                                   width: scrollView.width-60,
                                   height: 50)
        textViewDess.frame = CGRect(x: 30,
                                   y: textViewDes.bottom+5,
                                   width: scrollView.width-60,
                                   height: 50)
        
        loginButton.frame = CGRect(x: 30,
                                   y: textViewDess.bottom+400,
                                   width: scrollView.width-60,
                                   height: 50)
        
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom+10,
                                           width: scrollView.width-60,
                                           height: 50)
        
        googleLoginButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom+10,
                                         width: scrollView.width-60,
                                         height: 50)
    }
    
    @objc private func registerButtonTapped() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        let vc = LoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = StartViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - FACEBOOK SIGN IN
extension WelcomeViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with Facebook")
            return
        }
        
        DispatchQueue.main.async {
            ProgressHUD.showSucceed("Login Success", interaction: true )
            ProgressHUD.colorAnimation = .systemBlue
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String:Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            print(result)
            
            guard let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
                let email = result["email"] as? String,
                let picture = result["picture"] as? [String:Any],
                let data = picture["data"] as? [String:Any],
                let pictureUrl = data["url"] as? String else {
                    print("Failed to get email and name from Facebook result")
                    return
            }
            
            let phone = "090000000"
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
            DatabaseManager.share.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email,
                                               phoneNumber: phone)
                    
                    DatabaseManager.share.insertUser(with: chatUser, completion: { success in
                        if success {
                            
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading date from Facebook image")
                            
                            URLSession.shared.dataTask(with: url,
                               completionHandler: { data, _, _ in
                                guard let data = data else {
                                    print("Failed to get data from Facebook")
                                    return
                                }
                                
                                print("Got data from FB, uploading . . .")
                                
                                // Upload image
                                let fileName = chatUser.ProfilePictureFileName
                                StorageManager.share.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                    })
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
                guard authResult != nil, error == nil else{
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed : \(error)")
                    }
                    return
                }
                
                print("Successfully logged user in")
                // strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            })
        })
    }
}

extension UIButton {
    func addLeftPadding(_ padding: CGFloat) {
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: padding, bottom: 0.0, right: -padding)
        contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: padding)
    }
}
