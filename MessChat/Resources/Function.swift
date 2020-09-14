//
// Function.swift
// MessChat
//
// Created by GIABAO Photography on 9/4/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import Foundation

// Valid
public func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

public func isValidPassword(_ password : String) -> Bool
{
    let passwordreg =  ("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
    )
    let passwordtesting = NSPredicate(format: "SELF MATCHES %@", passwordreg)
    return passwordtesting.evaluate(with: password)
}

func isValidPhone(_ phone: String) -> Bool {
          let PHONE_REGEX = "^\\d{9}$"
          let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
          let result = phoneTest.evaluate(with: phone)
          return result
      }

