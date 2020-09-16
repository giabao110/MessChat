//
// ForgotPasswordViewController.swift
// MessChat
//
// Created by GIABAO Photography on 9/4/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import UIKit
import Firebase
import RAGTextField
import ProgressHUD

class ForgotPasswordViewController: UIViewController {
  
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
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
    
    private let textView: UILabel = {
        let textView = UILabel()
        textView.text = "ENTER EMAIL TO RESET PASSWORD"
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 20, weight: .bold)
        textView.textColor = .white
        return textView
    }()
    
    private let emailField: RAGTextField = {
        let field = RAGTextField()
        return field.textField(placeHolder: "Email Address", imageName: "person.crop.circle", isSecureTextEntry: false)
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset my password", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()

        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(textView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(resetButton)
        emailField.addLine(position: .bottom, color: UIColor.white, height: 1.0)
        resetButton.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds

        textView.frame = CGRect(x: 30,
                                y:20,
                                width: scrollView.width-60,
                                height: 50)
        
        emailField.frame = CGRect(x: 30,
                                  y: textView.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        
        resetButton.frame = CGRect(x: 30,
                                   y: emailField.bottom+30,
                                   width: scrollView.width-60,
                                   height: 50)
    }
    
    @objc private func resetPassword(){
        
        emailField.resignFirstResponder()
        
        guard let emailForgot = emailField.text, emailForgot != "" else {
            ProgressHUD.showError(FORGOT_ERROR_EMPTY_EMAIL_RESET)
            return
        }
        DatabaseManager.share.resetPasswordEmail(email: emailForgot, onSuccess: {
            self.view.endEditing(true)
            ProgressHUD.showSuccess(FORGOT_SUCCESS_EMAIL_RESET)
            self.navigationController?.popViewController(animated: true)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
}


