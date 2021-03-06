//
// AppDelegate.swift
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
import Firebase
import FirebaseAuth
import FirebaseCore
import FBSDKCoreKit
import GoogleSignIn
import ProgressHUD


@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        // Override point for customization LaunchScreen Time Delay
        Thread.sleep(forTimeInterval: 2.0)
        return true
    }
    
    func application( _ app: UIApplication,
                      open url: URL,
                      options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool { ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
        return GIDSignIn.sharedInstance().handle(url)
    }
}


// MARK: - GIDSignInDelegate

extension AppDelegate: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        
        print("Did sign in with Google: \(user)")
        
        guard let email = user.profile.email,
            let firstName = user.profile.givenName,
            let lastName = user.profile.familyName else {
                return
        }
        
        let phone = "No phone number"
        
        UserDefaults.standard.setValue(email, forKey: "email")
        UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
        UserDefaults.standard.setValue(phone, forKey: "phone")
        
        DatabaseManager.share.userExists(with: email, completion: { exists in
            if !exists {
                
                // Insert Database
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email,
                                           phoneNumber: phone)
                
                DatabaseManager.share.insertUser(with: chatUser, completion: { success in
                    if success {
                        
                        // Upload image
                        
                        if user.profile.hasImage {
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
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
                            }).resume()
                        }
                    }
                })
            }
        })
        
        guard let authentication = user.authentication else {
            print("Missing auth obj off of Google user")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        DispatchQueue.main.async {
            ProgressHUD.showSucceed("Login Success", interaction: true )
            ProgressHUD.colorAnimation = .systemBlue
        }
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
            
            guard authResult != nil, error == nil else {
                print("Failed to log in with Google credential")
                return
            }
            
            print("Successfully signed in with Google credential")

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Google user was disconnected")
    }
}
