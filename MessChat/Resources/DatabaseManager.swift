//
// DatabaseManager.swift
// MessChat
//
// Created by GIABAO Photography on 8/18/20.
// Copyright © 2020 GIABAO Photography. All rights reserved.
// VAN HIEN University 
//
// Website: https://giabaophoto.com
// 
// 


import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation
import Firebase

/// Manager object to read and write data to realtime database
final class DatabaseManager {
    
    /// Shared instance of class
    public static let share = DatabaseManager()
    
    private let database = Database.database().reference()

    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension DatabaseManager {
    
    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

//MARK: - Accout Managerment

extension DatabaseManager {
    
    /// Checks if user exists for given email
    /// Parameters
    /// - `email`:              Target email to be checked
    /// - `completion`    Async closure to return with result
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)){
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard snapshot.value as? [String: Any] != nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Reset password
    public func resetPasswordEmail(email: String, onSuccess: @escaping () -> Void,
                                   onError: @escaping (_ errorMessage: String) -> Void) {
        FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email, completion: { error in
            if error == nil {
                onSuccess()
            }
            else {
                onError(error!.localizedDescription)
            }
        })
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) { database.child(user.safeEmail).setValue(
        [
            "first_name": user.firstName,
            "last_name": user.lastName,
            "phone_number": user.phoneNumber
        ]
        , withCompletionBlock: { [weak self] error, _ in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                print("Failed write to database")
                completion(false)
                return
            }
            strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var userCollection = snapshot.value as? [[String: String]] {
                    // Append to user dictionary
                    let newElement =    [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail,
                        "phone": user.phoneNumber
                    ]
                    userCollection.append(newElement)
                    
                    strongSelf.database.child("users").setValue(userCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    // Create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail,
                            "phone": user.phoneNumber
                        ]
                    ]
                    strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
    })
    }
    
    ///Gets all users from database
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
}

    public enum DatabaseError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This mean blah failed!"
            }
        }
    }

    /*
     users => [
         [
            "name":
            "safe_email":
         ],
         [
             "name":
             "safe_email":
         ]
     ]
     */

    // MARK: - Sending messages / conversation
    extension DatabaseManager {
     /*
     "giabao123" {
         "messages": [
             {
                 "id": String,
                 "type": text, photo, video,
                 "content": String, // change to type
                 "date": Date(),
                 "sender_email": String,
                 "isRead": true,false
             }
         ]
     }
     conversation => [
         [
         "conversation_id": "giabao123"
         "other_user_email":
         "latest_message": => {
             "date": Date(),
             "lastest_message": message
             "is_read":true/false
             }
         ]
     ]
     */
    
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String,
                                      name: String,
                                      firstMessage: Message,
                                      completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let massageText):
                message = massageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            case .linkPreview(_):
                break
            }
            
            let conversationId = "Conversation_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": true
                ]
            ]
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // Update recipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    print("append")
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }
                else {
                    // create
                    print("create")
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // Conversation array exists for current user
                // You should append
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.fisnishCreatingConversation(name: name,
                                                      conversationID: conversationId,
                                                      firstMessage: firstMessage,
                                                      completion: completion)
                })
            }
            else {
                // Conversation array does NOT exist
                // Create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.fisnishCreatingConversation(name: name,
                                                      conversationID: conversationId,
                                                      firstMessage: firstMessage,
                                                      completion: completion)
                })
            }
        })
    }
    
    private func fisnishCreatingConversation(name: String,
                                             conversationID: String,
                                             firstMessage: Message,
                                             completion: @escaping (Bool) -> Void) {
        //        {
        //            "id": String,
        //            "type": text, photo, video,
        //            "content": String, // change to type
        //            "date": Date(),
        //            "sender_email": String,
        //            "isRead": true,false
        //        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        case .linkPreview(_):
            break
        }
        guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmmail)
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": true,
            "name": name
        ]
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        print("adding convo: \(conversationID)")
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
        
        /// Fetchs and returns all conversations for the user with passed in email
        public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
            database.child("\(email)/conversations").observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [[String: Any]] else{
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                let conversations: [Conversation] = value.compactMap({ dictionary in
                    guard let conversationId = dictionary["id"] as? String,
                        let name = dictionary["name"] as? String,
                        let otherUserEmail = dictionary["other_user_email"] as? String,
                        let latestMessage = dictionary["latest_message"] as? [String: Any],
                        let date = latestMessage["date"] as? String,
                        let message = latestMessage["message"] as? String,
                        let isRead = latestMessage["is_read"] as? Bool else {
                            return nil
                    }
                    let latestMmessageObject = LatestMessage(date: date,
                                                             text: message,
                                                             isRead: isRead)
                    return Conversation(id: conversationId,
                                        name: name,
                                        otherUserEmail: otherUserEmail,
                                        latestMessage: latestMmessageObject)
                })
                completion(.success(conversations))
            })
        }
        
        /// Fetchs and returns all conversations for the user with passed in email
        public func getAllFriendRequest(for email: String, completion: @escaping (Result<[FriendRequest], Error>) -> Void) {
            database.child("\(email)/friends").observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [[String: Any]] else{
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                let friends: [FriendRequest] = value.compactMap({ dictionary in
                    guard let conversationId = dictionary["id"] as? String,
                        let name = dictionary["name"] as? String,
                        let otherUserEmail = dictionary["other_user_email"] as? String,
                        let phone = dictionary["phone"] as? String else {
                            return nil
                    }
                  
                    return FriendRequest(id: conversationId,
                                        name: name,
                                        phoneNumber: phone, otherUserEmail: otherUserEmail)
                })
                completion(.success(friends))
            })
        }
        
        /// Gets all message for a given conversation
        public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
            database.child("\(id)/messages").observe(.value, with: { snapshot in
                guard let value = snapshot.value as? [[String: Any]] else{
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                let messages: [Message] = value.compactMap({ dictionary in
                    guard let name = dictionary["name"] as? String,
                        let _ = dictionary["is_read"] as? Bool,
                        let messageID = dictionary["id"] as? String,
                        let content = dictionary["content"] as? String,
                        let senderEmail = dictionary["sender_email"] as? String,
                        let type = dictionary["type"] as? String,
                        let dateString = dictionary["date"] as? String,
                        let date = ChatViewController.dateFormatter.date(from: dateString) else {
                            return nil
                    }
                    var kind: MessageKind?
                    if type == "photo" {
                        /// Photo
                        guard let imageUrl = URL(string: content),
                            let placeHolder = UIImage(systemName: "plus") else {
                                return nil
                        }
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 200, height: 200))
                    kind = .photo(media)
                }
                else if type == "video" {
                    /// Video
                    guard let videoUrl = URL(string: content),
                        let placeHolder = UIImage(named: "placeholder") else {
                            return nil
                    }
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 200))
                    kind = .video(media)
                }
                else if type == "location" {
                    let locationComponents = content.components(separatedBy: ",")
                    guard let longtitude = Double(locationComponents[0]), let latitude = Double(locationComponents[1]) else {
                        return nil
                    }
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longtitude), size: CGSize(width: 200, height: 200))
                    kind = .location(location)
                }
                else {
                    kind = .text(content)
                }
                guard let finalKind = kind else {
                    return nil
                }
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
            })
            completion(.success(messages))
        })
    }
    
    /// Sends a massage with target conversation and massage
    public func sendMessage(to conversation: String,
                            otherUserEmail: String,
                            name: String,
                            newMessage: Message,
                            completion: @escaping (Bool) -> Void) {
        // Add new message to messages
        // Update sender lastest message
        // Update recipient lastest message
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            let messageDate = newMessage.sentDate
            
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch newMessage.kind {
            case .text(let massageText):
                message = massageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = ("\(location.coordinate.longitude),\(location.coordinate.latitude)")
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            case .linkPreview(_):
                break
            }
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updateValue: [String: Any] = [
                        "date": dateString,
                        "is_read": true,
                        "message": message,
                    ]
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        
                        var targetConversation: [String: Any]?
                        
                        var position = 0
                        
                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updateValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                "name": name,
                                "latest_message": updateValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "latest_message": updateValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        // Update latest message for recipient user
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            var databaseEntryConversations = [[String: Any]]()
                            let updateValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message,
                            ]
                            
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                return
                            }
                            
                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String: Any]?
                                
                                var position = 0
                                
                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updateValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }
                                else {
                                    // Failed to find in current collection
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                        "name": currentName,
                                        "latest_message": updateValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            }
                            else {
                                // Current collection is not exists
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                    "name": currentName,
                                    "latest_message": updateValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKeyPath: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print("Deleting conversation with id: \(conversationId)")
        // Get all conversation for current user
        // Delete conversation in collection with targe id
        // Reset those conversations for the user in database
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                        id == conversationId {
                        print("Found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to delete conversation!!!")
                        return
                    }
                    print("Deleted conversation")
                    completion(true)
                })
            }
        })
    }
    
    public func conversationExists(with targerRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targerRecipientEmail)
        guard  let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            // interage and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }){
                
                // Get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DatabaseError.failedToFetch))
            return
        })
        }
        
        public func fiendsExists(with targerRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
            let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targerRecipientEmail)
            guard  let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
            database.child("\(safeRecipientEmail)/friends").observeSingleEvent(of: .value, with: { snapshot in
                guard let collection = snapshot.value as? [[String: Any]] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                
                // interage and find conversation with target sender
                if let conversation = collection.first(where: {
                    guard let targetSenderEmail = $0["other_user_email"] as? String else {
                        return false
                    }
                    return safeSenderEmail == targetSenderEmail
                }){
                    
                    // Get id
                    guard let id = conversation["id"] as? String else {
                        completion(.failure(DatabaseError.failedToFetch))
                        return
                    }
                    completion(.success(id))
                    return
                }
                completion(.failure(DatabaseError.failedToFetch))
                return
            })
            }
        
        public func isRead( conversationId: String) {
            guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                return
            }
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            let ref = database.child("\(safeEmail)/conversations")
            ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if let conversations = snapshot.value as? [[String: Any]] {
                    var positionToRemove = 0
                    for conversation in conversations {
                        if let id = conversation["id"] as? String,
                            id == conversationId {
                            break
                        }
                        positionToRemove += 1
                    }
                    self?.database.child("\(safeEmail)/conversations/\(positionToRemove)/latest_message/").updateChildValues(["is_read": true])
                }
            })
        }
        
        public func createNewFiendRequest(with otherUserEmail: String,
                                          name: String, phone: String, id: String,
                                          completion: @escaping (Bool) -> Void) {
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
                let currentName = UserDefaults.standard.value(forKey: "name") as? String
                else {
                    return
            }
            
            print("PHONE:\(String(describing: UserDefaults.standard.value(forKey: "phone")))")
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
            
            let ref = database.child("\(safeEmail)")
            
            ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard var userNode = snapshot.value as? [String: Any] else {
                    completion(false)
                    print("User not found")
                    return
                }
                
                let newConversationData: [String: Any] = [
                    "id": id,
                    "other_user_email": otherUserEmail,
                    "name": name,
                    "phone": phone,
                    "is_send": true
                ]
                let recipient_newConversationData: [String: Any] = [
                    "id": id,
                    "other_user_email": safeEmail,
                    "name": currentName,
                    "phone": "phone",
                    "is_send": false
                ]
                
                // Update recipient conversation entry
                self?.database.child("\(otherUserEmail)/friends").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    if var conversations = snapshot.value as? [[String: Any]] {
                        // append
                        print("append")
                        conversations.append(recipient_newConversationData)
                        self?.database.child("\(otherUserEmail)/friends").setValue(conversations)
                    }
                    else {
                        // create
                        print("create")
                        self?.database.child("\(otherUserEmail)/friends").setValue([recipient_newConversationData])
                    }
                })
                
                // Update current user conversation entry
                if var conversations = userNode["friends"] as? [[String: Any]] {
                    // Conversation array exists for current user
                    // You should append
                    
                    conversations.append(newConversationData)
                    userNode["friends"] = conversations
                    ref.setValue(userNode, withCompletionBlock: {  error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                }
                else {
                    // Conversation array does NOT exist
                    // Create it
                    userNode["friends"] = [
                        newConversationData
                    ]
                    
                    ref.setValue(userNode, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                }
            })
        }
        
           private func fisnishCreateNewFiendRequest(name: String,
                                                    completion: @escaping (Bool) -> Void) {

               guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else {
                   completion(false)
                   return
               }
               
               let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmmail)
               let collectionMessage: [String: Any] = [
                   "sender_email": currentUserEmail,
                   "is_read": true,
                   "name": name
               ]
               let value: [String: Any] = [
                   "messages": [
                       collectionMessage
                   ]
               ]
        
               database.child("abc").setValue(value, withCompletionBlock: { error, _ in
                   guard error == nil else {
                       completion(false)
                       return
                   }
                   completion(true)
               })
           }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let phoneNumber: String
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var ProfilePictureFileName: String {
        //images/giabaofotography-gmail_com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
