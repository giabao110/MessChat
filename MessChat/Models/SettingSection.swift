//
// SettingSection.swift
// MessChat
//
// Created by GIABAO Photography on 9/9/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingSection: Int, CaseIterable, CustomStringConvertible {
    case Social
    case Communications
    case Logout
    
    var description: String {
        switch self {
        case .Social:
            return ""
        case .Communications:
            return ""
        case .Logout:
            return ""
        }
    }
}

enum SocialOptions: Int, CaseIterable, SectionType {
    case editProfile
    case savedMessages
    case devices
    case chatFolder
    
    var containsSwitch: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .editProfile:
            return "Edit Profile"
        case .savedMessages:
            return "Saved Messages"
        case .devices:
            return "Devices"
        case .chatFolder:
            return "Chat Folder"
        }
    }
}

enum CommunicationsOptions: Int, CaseIterable, SectionType {
    case darkMode
    case notifications
    case privacy
    case data
    case reportCrashes
    
    var containsSwitch: Bool {
        switch self {
        case .darkMode:
            return true
        case .notifications:
            return false
        case .privacy:
            return false
        case .data:
            return false
        case .reportCrashes:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .darkMode:
            return "Dark Mode"
        case .notifications:
            return "Notifications and Sounds"
        case .privacy:
            return "Privacy and Security"
        case .data:
            return "Data and Storage"
        case .reportCrashes:
            return "Report Crashes"
        }
    }
}

enum LogOutOptions: Int, CaseIterable, SectionType {
    case logout
    
    var containsSwitch: Bool {
        switch self {
        case .logout:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .logout:
            return "Log Out"
        }
    }
}
