//
// ConversationsModels.swift
// MessChat
//
// Created by GIABAO Photography on 8/31/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct FriendRequest {
    let id: String
    let name: String
    let phoneNumber: String
    let otherUserEmail: String
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

struct Contacts {
    let id: String
    let name: String
    let phoneNumber: String
    let otherUserEmail: String
}
