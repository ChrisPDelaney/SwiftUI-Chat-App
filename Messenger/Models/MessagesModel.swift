//
//  MessagesModel.swift
//  Messenger
//
//  Created by Harrison Cooley on 11/22/22.
//

import Foundation

import Foundation
import SwiftUI

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

import WebKit

//Represents all the data and operations our app needs to do
    //If we're chatting with somebody, sending a new message, etc.
    //TESTING
class MessagesModel: ObservableObject {
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("currentEmail") var currentEmail: String = ""
    @AppStorage("profileUrl") var profileUrl: String = ""
    @AppStorage("currentNumFriends") var currentNumFriends: Int = 0
    
    @AppStorage("currentDate") var currentDate: String = "2022-01-27" //added
    @AppStorage("currentVenue") var currentVenue: String = "The Tombs" //added
    @AppStorage("currentGroupName") var currentGroupName: String = ""
    
    @Published var showingSignIn: Bool = true
    @Published var currentGroup: [GroupUser] = []
    //@Published var currentGroupName: String = ""
    @Published var messages: [Message] = []
    
    @Published var unReadMsgs: Int = 0
    @Published var inChat: Bool = false

    let database = Firestore.firestore()
    let auth = Auth.auth()

    var newMsgListener: ListenerRegistration?
    var groupDocListener: ListenerRegistration?
    var chatListener: ListenerRegistration?

    private let defaults = UserDefaults.standard
    
    //immediatley when the app is opened, it che
    init() {
        print("In MessagesModel initialization")
        let userEmail = Auth.auth().currentUser?.email
        print("The users email is \(userEmail)")
        print("The currentUsername is \(currentUsername)")
        self.showingSignIn = Auth.auth().currentUser == nil
        print("Showing sign in is  \(self.showingSignIn)")
    }
}

extension MessagesModel {
    func getMsgsFromGroupDoc(){
        print("Inside function getMsgsFromGroupDoc")
        
        if self.currentGroupName == ""{
            print("No current group name returning")
            return
        }
        
        print("past error checking in getMsgsFromGroupDoc")
        
        groupDocListener = database
            .collection("groups")
            .document(currentGroupName) // should be each user
            .collection("messages")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let objects = snapshot?.documents.compactMap({ $0.data() }), //returns an array of dictionaries
                      error == nil else {
                    return
                }
                
                //holds text, type, created date
                let messages: [Message] = objects.compactMap({//taking the text, sender, and created pieces out, casting them to appropriate expected types
                    guard let date = ISO8601DateFormatter().date(from: $0["created"] as? String ?? "") else {
                        return nil
                    }
                    return Message(
                        id: $0["id"] as? String ?? "",
                        text: $0["text"] as? String ?? "",
                        //set username here rather than doing the type
                        type: $0["sender"] as? String == self?.currentUsername ? .sent : .received,
                        sender: $0["sender"] as? String ?? "",
                        created: date,
                        read: $0["read"] as? Bool ?? false
                    )
                })
                
                for msg in messages{
                    
                    let data = [
                        "id": msg.id,
                        "text": msg.text,
                        "sender": msg.sender,
                        "created": ISO8601DateFormatter().string(from: msg.created),
                        "read": msg.read
                    ] as [String : Any]
                    
                    self!.database.collection("users")
                        .document(self!.currentUsername) // should be each user
                        .collection("myGroups")
                        .document(self!.currentGroupName)
                        .collection("messages")
                        .document(msg.id)
                        .setData(data, merge: true)
                    
                }//END for msg in messages
                
                
                
                
            }//END snapshot listener
    }
    
    func getNewMsgs(){
        print("Inside function getNewMsgs")
        newMsgListener = database
            .collection("users")
            .document(currentUsername)
            .collection("messages")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let objects = snapshot?.documents.compactMap({ $0.data() }), //returns an array of dictionaries
                      error == nil else {
                    return
                }
                
                //holds text, type, created date
                let messages: [Message] = objects.compactMap({//taking the text, sender, and created pieces out, casting them to appropriate expected types
                    guard let date = ISO8601DateFormatter().date(from: $0["created"] as? String ?? "") else {
                        return nil
                    }
                    return Message(
                        id: $0["id"] as? String ?? "",
                        text: $0["text"] as? String ?? "",
                        //set username here rather than doing the type
                        type: $0["sender"] as? String == self?.currentUsername ? .sent : .received,
                        sender: $0["sender"] as? String ?? "",
                        created: date,
                        read: $0["read"] as? Bool ?? false
                    )
                }).sorted(by: { first, second in
                    return first.created < second.created
                })
                
                if self?.inChat == true
                {
                    print("Inside inChat == True")
                    
                    for msg in messages
                    {
                        if msg.read == false
                        {
                            print("Message id is \(msg.id)")
                            self!.database.collection("users").document(self!.currentUsername ).collection("messages").document(msg.id).setData([ "read": true ], merge: true) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                        }//END if msg read == false
                    }//END for loop
                    
                    print("Exited for loop making all messages read")
                    
                    DispatchQueue.main.async
                    {
                        self?.unReadMsgs = 0
                        self?.messages = messages
                    }
                }
                else
                {
                    print("Inside inChat == False")
                    
                    var newMsgNum: Int = 0
                    for msg in messages{
                        if msg.read == false
                        {
                            newMsgNum += 1
                        }//END if msg read == false
                    }//END for loop
                    
                    print("Exited for loop in getNumNew")
            
                    
                    DispatchQueue.main.async {
                        self?.unReadMsgs = newMsgNum
                        self?.messages = messages
                        print("Inside dispatch queue the number of unread messages are \(String(describing: self?.unReadMsgs))")
                    }
                    
                    print("The number of unread messages are \(String(describing: self?.unReadMsgs))")
                }
                
                
            }//END snapshot listener
    }
    
    func sendMessage(text: String) {
        let newMessageId = UUID().uuidString
        let dateString = ISO8601DateFormatter().string(from: Date())

        guard !dateString.isEmpty else {
            return
        }

        let data = [
            "id": newMessageId,
            "text": text,
            "sender": currentUsername,
            "created": dateString,
            "read": false
        ] as [String : Any]

        database.collection("groups")
            .document(currentGroupName) // should be each user
            .collection("messages")
            .document(newMessageId)
            .setData(data)
        
        //loop here forEach username in GCUsers
//        for user in currentGroup {
//            database.collection("users")
//                .document(user.name) // should be each user
//                .collection("messages")
//                .document(newMessageId)
//                .setData(data)
//        }
    }//END sendMessage
}
