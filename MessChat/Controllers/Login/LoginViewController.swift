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
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let imageTitleView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "messchatlogo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let emailField: RAGTextField = {
        let field = RAGTextField()
        if let myImage = UIImage(systemName: "person"){
            field.withImage(direction: .Left, image: myImage)
        }
        field.transformedPlaceholderColor = .white
        field.placeholderColor = .white
        field.placeholderFont = .systemFont(ofSize: 18, weight: .medium)
        field.font = .systemFont(ofSize: 18, weight: .medium)
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 8
        field.borderStyle = .none
        field.placeholderMode = .scalesWhenNotEmpty
        field.placeholder = "Username"
        field.textColor = .white
        return field
    }()
    
    private var passwordField: RAGTextField = {
        let field = RAGTextField()
        if let myImage = UIImage(systemName: "lock"){
            field.withImage(direction: .Left, image: myImage)
        }
        field.transformedPlaceholderColor = .white
        field.placeholderColor = .white
        field.placeholderFont = .systemFont(ofSize: 18, weight: .medium)
        field.font = .systemFont(ofSize: 18, weight: .medium)
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
    
//    lazy var passwordContainerView: UIView = {
//        let field = UITextField()
//        
//        return field.textContainerView(view: view, #imageLiteral(resourceName: <#T##String#>), textfield: passwordField)
//    }()
//    
//    lazy var passwordField: UITextField = {
//        let field = UITextField()
//        
//        return field.textField(withPlaceholder: "Password", isSecureTextEntry: true)
//    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
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
        button.imageEdgeInsets = UIEdgeInsets(top: 25,left: 25,bottom: 25,right: 25)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()
    
    private let googleLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Connect with Google", for: .normal)
        button.backgroundColor = .white //UIColor(red: 211/255, green: 72/255, blue: 54/255, alpha: 1)
        button.setImage(UIImage(named: "google"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 15)
        button.setTitleColor(.darkGray, for: .normal)
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
        let gradient = CAGradientLayer() //99, 164, 255)
        let topColor = UIColor(red: 99/255, green: 164/255, blue: 255/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 131/255, green: 234/255, blue: 241/255, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0, 1]
        gradient.frame = self.view.bounds
        self.view.layer.insertSublayer(gradient, at:0)
    }

//            private let googleLoginButton: GIDSignInButton = {
//                let button = GIDSignInButton()
//            button.backgroundColor = #colorLiteral(red: 0.3948340416, green: 0.3551002145, blue: 0.9879776835, alpha: 1)
//            button.layer.cornerRadius = 8
//            button.layer.masksToBounds = true
//                return button
//            }()
    
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
        scrollView.addSubview(imageTitleView)
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
        
        let size = view.width/6
        let sizes = view.width/2
        print("\(sizes)")
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 10,
                                 width: size,
                                 height: size)
        
        imageTitleView.frame = CGRect(x: 60,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-120,
                                  height: 80)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageTitleView.bottom+30,
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
                                           y: loginButton.bottom+sizes,
                                           width: scrollView.width-200,
                                           height: 52)
        
        googleLoginButton.frame = CGRect(x: 100,
                                         y: facebookLoginButton.bottom+10,
                                         width: scrollView.width-200,
                                         height: 52)
        
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
        
        spinner.textLabel.text = "Loading"
        spinner.show(in: view)
        
        // Firebase Log In
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
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
            
            // strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
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
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
            DatabaseManager.share.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    
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
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
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
                
                // This is to get the SceneDelegate object from your view controller
                // then call the change root view controller function to change to main tab bar
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
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
        imageView.frame = CGRect(x: 10.0, y: 10.0, width: 24.0, height: 24.0)
        
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
