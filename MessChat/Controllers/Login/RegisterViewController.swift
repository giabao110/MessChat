//
// RegisterViewController.swift
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
import ProgressHUD
import RAGTextField

final class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "image_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.tintColor = .white
        return imageView
    }()
    
    private let imageView2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let firtnameField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "First Name", imageName: "", isSecureTextEntry: false)
    }()
    
    private let lastnameField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "Last Name", imageName: "", isSecureTextEntry: false)
    }()
    
    private let emailField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "Email Address", imageName: "", isSecureTextEntry: false)
    }()
    
    private let passwordField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "Password", imageName: "", isSecureTextEntry: true)
    }()
    
    private let passwordReField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "Confirm Password", imageName: "", isSecureTextEntry: true)
    }()
    
    private let phoneField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "Phone number", imageName: "", isSecureTextEntry: false)
        
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        
        registerButton.addTarget(self,
                                 action: #selector(registerButtonTapped),
                                 for: .touchUpInside)
        
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        setGradientBackground()
        
        emailField.delegate = self
        passwordField.delegate = self
        passwordReField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firtnameField)
        scrollView.addSubview(lastnameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(phoneField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(passwordReField)
        scrollView.addSubview(registerButton)
        scrollView.addSubview(imageView2)
        scrollView.addSubview(signInButton)
        
        scrollView.scrollsToBottom(animated: true)

        firtnameField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
        lastnameField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
        emailField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
        phoneField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
        passwordField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
        passwordReField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
        
        //Call screen
        imageView.isUserInteractionEnabled = true
        imageView2.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        
        let gesturee = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        
        imageView.addGestureRecognizer(gesture)
        
        imageView2.addGestureRecognizer(gesturee)

        let attributedText = NSMutableAttributedString(string: "Already have an accout? ",
              attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .light),
                           NSAttributedString.Key.foregroundColor : UIColor.white
              ])
         
              let attributedSubText = NSMutableAttributedString(string: "Sign In",
              attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold),
                           NSAttributedString.Key.foregroundColor : UIColor.white
              ])
              
        attributedText.append(attributedSubText)
        signInButton.setAttributedTitle(attributedText, for: .normal)
    }
    
    // Background Color
    func setGradientBackground() {
        let gradient = CAGradientLayer()
        let topColor = UIColor(red: 99/255, green: 164/255, blue: 255/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 131/255, green: 234/255, blue: 241/255, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0, 1]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at:0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc private func signIn() {
        let vc = LoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = view.width/4
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 10,
                                 width: size,
                                 height: size)
        
        imageView.layer.cornerRadius = imageView.width/2
        
        imageView2.frame = CGRect(x: (scrollView.width-30)/2,
                                  y: imageView.bottom-8,
                                  width: 30,
                                  height: 30)
        
        firtnameField.frame = CGRect(x: 30,
                                     y: imageView.bottom+40,
                                     width: scrollView.width-60,
                                     height: 50)
        
        lastnameField.frame = CGRect(x: 30,
                                     y: firtnameField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 50)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastnameField.bottom+10,
                                  width: scrollView.width-60,
                                  height: 50)
        
        phoneField.frame = CGRect(x: 30,
                                  y: emailField.bottom+10,
                                  width: scrollView.width-60,
                                  height: 50)
        
        passwordField.frame = CGRect(x: 30,
                                     y: phoneField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 50)
        
        passwordReField.frame = CGRect(x: 30,
                                       y: passwordField.bottom+10,
                                       width: scrollView.width-60,
                                       height: 50)
        
        registerButton.frame = CGRect(x: 30,
                                      y: passwordReField.bottom+40,
                                      width: scrollView.width-60,
                                      height: 50)
        
        signInButton.frame = CGRect(x: 60,
                                    y: registerButton.bottom+2,
                                    width: scrollView.width-120,
                                    height: 50)
    }
    
    @objc private func registerButtonTapped() {
        let validEmail = isValidEmail(emailField.text!)
        let validPassword = isValidPassword(passwordField.text!)
        let validRePassword = isValidPassword(passwordReField.text!)
        let validPhone = isValidPhone(phoneField.text!)
        
//        firtnameField.resignFirstResponder()
//        lastnameField.resignFirstResponder()
        emailField.resignFirstResponder()
//        phoneField.resignFirstResponder()
//        passwordField.resignFirstResponder()
        passwordReField.resignFirstResponder()
        
        guard  let email = emailField.text,
            !email.isEmpty,
            validEmail == true else {
                alertEmailError()
                return
        }
        
        guard let password = passwordField.text,
            let passwordRe = passwordReField.text,
            !password.isEmpty,
            !passwordRe.isEmpty,
            validPassword == true,
            validRePassword == true
            else {
                alertPasswordError()
                return
        }
        
        guard let phone = phoneField.text,
            !phone.isEmpty,
            validPhone == true else {
                alertPhoneError()
                return
        }
        
        guard password == passwordRe  else {
            PasswordError()
            return
        }
        
        guard let firstname = firtnameField.text,
            let lastname = lastnameField.text,
            !firstname.isEmpty,
            !lastname.isEmpty
            else {
                alertUserSignUpError()
                return
        }
        
        ProgressHUD.show()
        ProgressHUD.animationType = .circleSpinFade
        ProgressHUD.colorAnimation = .systemBlue
        
        // Firebase Log In
        DatabaseManager.share.userExists(with: email, completion: { [weak self] exists in
            
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
            }
            
            guard !exists else{
                // User already exists
                strongSelf.alertUserSignUpError(messenge: "Looks like a user account for that email address already exists")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else{
                    print("Error cureating user")
                    return
                }
                
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstname) \(lastname)", forKey: "name")
                
                let chatUser = ChatAppUser(firstName: firstname,
                                           lastName: lastname,
                                           emailAddress: email,
                                           phoneNumber: phone)
                print("LOGIN")
                DatabaseManager.share.insertUser(with: chatUser, completion: { success in
                    if success {
                        // Upload image
                        guard let image = strongSelf.imageView.image,
                            let data = image.pngData() else {
                                return
                        }
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
                    }
                })
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
               
            })
        })
    }
    
    func alertUserSignUpError(messenge: String = "Please enter all information to create a new accout!") {
        let alert = UIAlertController(title: "Woops",
                                      message: messenge,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
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
    
    func alertPasswordError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Password is minimum 8 characters at least 1 Alphabet and 1 Number !!!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
        return
    }
    
    func PasswordError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Confirm password is not correct !!!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
        return
    }
    
    func alertPhoneError() {
           let alert = UIAlertController(title: "Woops",
                                         message: "Please enter correct phone number address !!!",
                                         preferredStyle: .alert)
           
           alert.addAction(UIAlertAction(title: "Dismiss",
                                         style: .cancel,
                                         handler: nil))
           
           present(alert, animated: true)
           return
       }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordReField.becomeFirstResponder()
        } else if textField == passwordReField {
            registerButtonTapped()
            print("ABC")
        }
        return true
    }
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture? ",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self]_ in
                                                
                                                self?.presentCamera()
                                                
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self]_ in
                                                
                                                self?.presetPhotoPicker()
                                                
        }))
        
        present(actionSheet, animated: true)
    }
    
    //Update Image
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presetPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("INFO")
        print(info)
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageView.image = selectedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIScrollView {
    func scrollsToBottom(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: animated)
    }
}
