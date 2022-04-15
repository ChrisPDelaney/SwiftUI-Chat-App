//
//  AppStateModel.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import Foundation
import SwiftUI

import FirebaseAuth
import FirebaseFirestore
import WebKit

//Represents all the data and operations our app needs to do
    //If we're chatting with somebody, sending a new message, etc.
    //TESTING
class AppStateModel: ObservableObject {
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("currentEmail") var currentEmail: String = ""
    @AppStorage("currentDate") var currentDate: String = "2022-01-27" //added
    @AppStorage("currentVenue") var currentVenue: String = "The Tombs" //added

    @Published var showingSignIn: Bool = true
    @Published var currentGroup: [GroupUser] = [] //added
    @Published var conversations: [String] = [] //can prob delete
    @Published var messages: [Message] = []

    let database = Firestore.firestore()
    let auth = Auth.auth()

    var conversationListener: ListenerRegistration?
    var chatListener: ListenerRegistration?
    var beerListener: ListenerRegistration?

    init() {
        self.showingSignIn = Auth.auth().currentUser == nil
    }
}

// Search

extension AppStateModel {
    func searchAvailableUsers(queryText: String, completion: @escaping ([String]) -> Void) {
        database.collection("users").whereField("inGroup", isLessThan: true).order(by: "inGroup").getDocuments { snapshot, error in //snapshot is the
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), //document id is the username
                  error == nil else {
                completion([])//if there's an error/something goes wrong in compeltion handler, pass back an empty array
                return
            }

            //filter usernames to prefix what you are searching
            let filtered = usernames.filter({
                $0.lowercased().hasPrefix(queryText.lowercased())
            })

            completion(filtered)
        }
    }
    
    func searchAllUsers(queryText: String, completion: @escaping ([User]) -> Void) {
        database.collection("users").getDocuments { snapshot, error in
            guard let objects = snapshot?.documents.compactMap({ $0.data() }), //returns an array of dictionaries
                  error == nil else {
                return
            }
            
            let users: [User] = objects.compactMap({//taking the text, sender, and created pieces out, casting them to appropriate expected types
                return User(
                    name: $0["username"] as? String ?? "",
                    numFriends: $0["numFriends"] as? Int ?? 0
                )
            })
                        
            //filter usernames to prefix what you are searching
            let filtered = users.filter({
                $0.name.lowercased().hasPrefix(queryText.lowercased())
            })

            completion(filtered)
        }
    }
    
    func searchVenues(queryText: String, completion: @escaping ([String]) -> Void) {
        database.collection("venues").getDocuments { snapshot, error in
            guard let venues = snapshot?.documents.compactMap({ $0.documentID }), //document id is the username
            error == nil else {
                completion([])//if there's an error/something goes wrong in compeltion handler, pass back an empty array
                return
            }

            //filter usernames to prefix what you are searching
            let filtered = venues.filter({
                $0.lowercased().hasPrefix(queryText.lowercased())
            })

            completion(filtered)
        }
    }
}

// Groups

extension AppStateModel {
    //change to create night
    func createGroup(selected: [String]) {
        for user in selected { //created for loop here
            for member in selected {
                database.collection("users")
                    .document(user)
                    .collection("groupMembers")
                    .document(member).setData(["name": member, "beerCount": 0])
            }
            database.collection("users")
                .document(user).setData(["inGroup": true], merge: true)
        }
    }
    
    //this listens for conversations to pop up in the chat view. So if someone starts a new chat, a new username will pop up that you can navigate to
    func getGroup() {
        conversationListener = database
            .collection("users")
            .document(currentUsername)//listen to the current users chats ; weak self prevents memory leak
            .collection("groupMembers").addSnapshotListener { [weak self] snapshot, error in
                if error == nil {
                    
                    if let snapshot = snapshot {
                        
                        DispatchQueue.main.async {
                            self?.currentGroup = snapshot.documents.map { data in
                                return GroupUser(
                                    name: data["name"] as? String ?? "",
                                    beerCount: data["beerCount"] as? Int ?? 0
                                )
                            }
                        }
                    }
                }
            }
    }
        
    func leaveGroup() {
        for user in currentGroup { //created for loop here
            database.collection("users")
                .document(user.name)
                .collection("groupMembers")
                .document(currentUsername).delete()
            if (currentUsername != user.name) {
                database.collection("users")
                    .document(currentUsername)
                    .collection("groupMembers")
                    .document(user.name).delete()
            }
        }
        
        database.collection("users")
            .document(currentUsername).setData(["inGroup" : false], merge: true)
        
        for message in messages {
            database.collection("users")
                .document(currentUsername)
                .collection("messages")
                .document(message.id).delete()
        }

    }
}

// Get Chat / Send Messages

extension AppStateModel {
    func observeChat() {
        chatListener = database
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
                        created: date
                    )
                }).sorted(by: { first, second in
                    return first.created < second.created
                })
                

                DispatchQueue.main.async {
                    self?.messages = messages
                }
            }
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
            "created": dateString
        ]

        //loop here forEach username in GCUsers
        for user in currentGroup {
            database.collection("users")
                .document(user.name) // should be each user
                .collection("messages")
                .document(newMessageId)
                .setData(data)
        }
    }
}


// Sign In & Sign Up

extension AppStateModel {
    func signIn(username: String, password: String) {
        // Get email from DB
        database.collection("users").document(username).getDocument { [weak self] snapshot, error in
            guard let email = snapshot?.data()?["email"] as? String, error == nil else {
                return
            }

            // Try to sign in
            self?.auth.signIn(withEmail: email, password: password, completion: { result, error in
                guard error == nil, result != nil else {
                    return
                }

                DispatchQueue.main.async {
                    self?.currentEmail = email
                    self?.currentUsername = username
                    self?.showingSignIn = false
                    self?.currentGroup = []
                }
            })
        }
    }

    func signUp(email: String, username: String, password: String) {
        // Create Account
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            
            self?.database
                .collection("users")
                .document(username)
                .setData([
                    "email": email,
                    "username": username,
                    "inGroup": false,
                    "numFriends": 0
                ]) { error in
                    guard error == nil else {
                        return
                    }

                    DispatchQueue.main.async {
                        self?.currentUsername = username
                        self?.currentEmail = email
                        self?.showingSignIn = false
                        self?.currentGroup = []
                    }
                }
        }

    }

    func signOut() {
        do {
            try auth.signOut()
            self.showingSignIn = true
        }
        catch {
            print(error)
        }
    }
}

// Beer

extension AppStateModel {
    func increaseDrink() {
        for user in currentGroup {
            database.collection("users")
                .document(user.name)
                .collection("groupMembers")
                .document(currentUsername).updateData(["beerCount": FieldValue.increment(Int64(1))])
        }
    }
    
    func resetDrink() {
        for user in currentGroup {
            database.collection("users")
                .document(user.name)
                .collection("groupMembers")
                .document(currentUsername).setData(["beerCount": 0], merge: true)
        }
    }
}

// Friends

extension AppStateModel {
    func requestFriend(username: String) {
        database.collection("users")
            .document(currentUsername)
            .collection("sentRequests")
            .document(username).setData(["isCreated": true])
        
        database.collection("users")
            .document(username)
            .collection("recievedRequests")
            .document(currentUsername).setData(["isCreated": true])
    }
    
    func acceptRequest(username: String) {
        removeRequest(username: username)
        
        database.collection("users")
            .document(currentUsername)
            .collection("friends")
            .document(username).setData(["isCreated": true])
        
        database.collection("users")
            .document(username)
            .collection("friends")
            .document(currentUsername).setData(["isCreated": true])
        
        database.collection("users")
            .document(currentUsername).updateData(["numFriends": FieldValue.increment(Int64(1))])
        
        database.collection("users")
            .document(username).updateData(["numFriends": FieldValue.increment(Int64(1))])
    }
    
    func removeRequest(username: String) {
        database.collection("users")
            .document(currentUsername)
            .collection("recievedRequests")
            .document(username).delete()
        
        database.collection("users")
            .document(username)
            .collection("sentRequests")
            .document(currentUsername).delete()
    }
    
    func checkSentRequest(username: String, completion: @escaping (Bool) -> Void) {
        var requested: Bool = false
        database.collection("users")
            .document(currentUsername)
            .collection("sentRequests")
            .getDocuments { snapshot, error in
            guard let requests = snapshot?.documents.compactMap({ $0.documentID }), //document id is the username
            error == nil else {
                return
            }

            if requests.contains(where: { $0 == username }) {
                requested = true
            }
            completion(requested)
        }
    }
    
    func checkReceivedRequest(username: String, completion: @escaping (Bool) -> Void) {
        var requested: Bool = false
        database.collection("users")
            .document(username)
            .collection("sentRequests")
            .getDocuments { snapshot, error in
            guard let requests = snapshot?.documents.compactMap({ $0.documentID }), //document id is the username
            error == nil else {
                return
            }

                if requests.contains(where: { $0 == self.currentUsername }) {
                requested = true
            }
            completion(requested)
        }
    }
}
