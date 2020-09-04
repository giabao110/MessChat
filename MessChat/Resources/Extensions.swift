//
// Extensions.swift
// MessChat
//
// Created by GIABAO Photography on 8/17/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import Foundation
import UIKit
import RAGTextField

let FORGOT_ERROR_EMPTY_EMAIL_RESET = "Please enter an email address for password reset"

let FORGOT_SUCCESS_EMAIL_RESET = "We have just sent you password reset email. Please check your inbox and follow the instructions to reset password"

extension UIView {
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
}

// EXTENSION HIDE NAVIGATION BAR
extension UINavigationController {
    func hideNavigationItemBackground (){
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        view.backgroundColor = UIColor.clear
        navigationBar.barStyle = UIBarStyle.black
        navigationBar.tintColor = UIColor.white
        /// Title
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
}

extension Notification.Name {
    /// Notificaiton  when user logs in
    static let didLogInNotification = Notification.Name("didLogInNotification")
}

extension UITextField {
    enum Direction {
        case Left
        case Right
    }
    // Add image to textfield , colorSeparator: UIColor, colorBorder: UIColor
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
            seperatorView.frame = CGRect(x: 45, y: 0, width: 0, height: 40)
            leftViewMode = .always
            leftView = mainView
        } else { // image right
            seperatorView.frame = CGRect(x: 0, y: 0, width: 5, height: 45)
            rightViewMode = .always
            rightView = mainView
        }
    }
}

// TOP - BOTTOM LINE
extension UIView {
    enum Line_Position {
        case top
        case bottom
    }

    func addLine(position : Line_Position, color: UIColor, height: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: height)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        switch position {
        case .top:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .bottom:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
}

//private let emailField: RAGTextField = {
//    let field = RAGTextField()
//    if let myImage = UIImage(systemName: "person"){
//        field.withImage(direction: .Left, image: myImage)
//    }
//    field.transformedPlaceholderColor = .white
//    field.placeholderColor = .white
//    field.placeholderFont = .systemFont(ofSize: 18, weight: .medium)
//    field.font = .systemFont(ofSize: 18, weight: .medium)
//    field.autocapitalizationType = .none
//    field.autocorrectionType = .no
//    field.returnKeyType = .done
//    field.layer.cornerRadius = 8
//    field.borderStyle = .none
//    field.placeholderMode = .scalesWhenNotEmpty
//    field.placeholder = "Email Address"
//    field.textColor = .white
//    return field
//}()

extension RAGTextField {
    func textField(placeHolder: String, imageName: String, isSecureTextEntry: Bool) -> RAGTextField {
        let field = RAGTextField()
        if let myImage = UIImage(systemName: "\(imageName)"){
            field.withImage(direction: .Left, image: myImage)
        }
        field.transformedPlaceholderColor = .white
        field.placeholderColor = .white
        field.placeholderFont = .systemFont(ofSize: 18, weight: .semibold)
        field.font = .systemFont(ofSize: 18, weight: .light)
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 8
        field.borderStyle = .none
        field.isSecureTextEntry = isSecureTextEntry
        field.placeholderMode = .scalesWhenNotEmpty
        field.placeholder = "\(placeHolder)"
        field.textColor = .white
        return field
    }
}
