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
import FirebaseStorage

import WebKit

//Represents all the data and operations our app needs to do
    //If we're chatting with somebody, sending a new message, etc.
    //TESTING
class AppStateModel: ObservableObject {
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("currentEmail") var currentEmail: String = ""
    @AppStorage("profileUrl") var profileUrl: String = ""
    @AppStorage("currentNumFriends") var currentNumFriends: Int = 0
    
    @AppStorage("currentDate") var currentDate: String = "2022-01-27" //added
    @AppStorage("currentVenue") var currentVenue: String = "The Tombs" //added
    
    @Published var showingSignIn: Bool = true
    @Published var currentGroup: [GroupUser] = []
    @Published var messages: [Message] = []
    
    @Published var unReadMsgs: Int = 0
    @Published var inChat: Bool = false

    let database = Firestore.firestore()
    let auth = Auth.auth()

    var groupListener: ListenerRegistration?
    var newMsgListener: ListenerRegistration?
    var chatListener: ListenerRegistration?
    var beerListener: ListenerRegistration?

    private let defaults = UserDefaults.standard
    
    //immediatley when the app is opened, it che
    init() {
        print("In initialization")
        let userEmail = Auth.auth().currentUser?.email
        print(userEmail)
        print(currentUsername)
        self.showingSignIn = Auth.auth().currentUser == nil
        print(self.showingSignIn)
    }
}

// Search

extension AppStateModel {
    func searchUnavailableUsers(queryText: String, completion: @escaping ([String]) -> Void) {
        database.collection("users").whereField("inGroup", isGreaterThan: false).order(by: "inGroup").getDocuments { snapshot, error in //snapshot is the
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
    
    func addToGroup(selected: [String]) {

        print("ENTERED ADDTOGROUP FUNCTION")
        for user in selected { //created for loop here
            for member in selected {
                database.collection("users")
                    .document(user)
                    .collection("groupMembers")
                    .document(member).setData(["name": member, "beerCount": 0])
            }
            for currentMember in currentGroup {
                database.collection("users")
                    .document(user)
                    .collection("groupMembers")
                    .document(currentMember.name).setData(["name": currentMember.name, "beerCount": 0])
            }
            database.collection("users")
                .document(user).setData(["inGroup": true], merge: true)
        }
        for user in currentGroup {
            print("")
            print("")
            print("")
            print(user.name)
            print("")
            print("")
            print("")
            for member in selected {
                database.collection("users")
                    .document(user.name)
                    .collection("groupMembers")
                    .document(member).setData(["name": member, "beerCount": 0])
            }
        }
    }
    
    //test comment
    func getGroup() {
        print("Inside the get group function")
        print("Current user name is :")
        print(currentUsername)
        print("The profile URL is: \(profileUrl)" )

        groupListener = database
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
    
    func observeChat() {
        print("Inside observe chat")
        
        for msg in self.messages{
            if msg.read == false
            {
                print("Message id is \(msg.id)")
                self.database.collection("users").document(self.currentUsername ).collection("messages").document(msg.id).setData([ "read": true ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            }//END if msg read == false
        }//END for loop
        
        print("Exited for loop")
        
        DispatchQueue.main.async {
            self.unReadMsgs = 0
        }
        
        //print("The size of self.messages is \(self.messages.count)")
        
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
            
            guard let url = snapshot?.data()?["profileUrl"] as? String, error == nil else {
                return
            }
            
            guard let numFriends = snapshot?.data()?["numFriends"] as? Int, error == nil else {
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
                    self?.profileUrl = url
                    self?.currentNumFriends = numFriends
                    self?.showingSignIn = false
                    self?.currentGroup = []
                }
            })
        }
    }
    func signUp(email: String, username: String, password: String, imageData: Data) {
        // Create Account
        print("ENTERS FUNCTION")
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                print("Error Here:")
                print(error)
                return
            }
            

            let storageRoot = Storage.storage().reference(forURL: "gs://messenger-swift-ui-7d80e.appspot.com")
            let usernameStorage = storageRoot.child("users")
            let userStorage = usernameStorage.child(username)
            let profilePic = userStorage.child("profile_pic")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            print("Image data:")
            print(imageData)
            
            print(profilePic)
            profilePic.putData(imageData, metadata: metadata) { (storageMetadata, error) in
                if error != nil {
                    print("Error Here:")
                    print(error)
                }
                print("inside profile put data")
                profilePic.downloadURL{ (url, error) in
                    print("enters download URL")
                    //maybe put change request in here later
                    if let metaImageUrl = url?.absoluteString {
                        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                            changeRequest.photoURL = url
                            changeRequest.displayName = username
                            changeRequest.commitChanges{ (error) in
                                if error != nil {
                                    print("ERROR IN CHANGE REQUEST COMMIT CHANGES")
                                    return
                                }
                            }
                        }
                        
                        self?.database.collection("users").document(username).setData([
                                    "email": email,
                                    "username": username,
                                    "inGroup": false,
                                    "numFriends": 0,
                                    "numMsgsRead": 0,
                                    "profileUrl": metaImageUrl ]) { error in
                                        guard error == nil else { return }
                                        DispatchQueue.main.async {
                                        self?.currentUsername = username
                                        self?.currentEmail = email
                                        self?.showingSignIn = false
                                        self?.profileUrl = metaImageUrl
                                        self?.currentGroup = []
                                    }
                                }
                        print("reaches end of meta image url function")
                    }
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
    
    func checkFriend(username: String, completion: @escaping (Bool) -> Void) {
        var friended: Bool = false
        database.collection("users")
            .document(currentUsername)
            .collection("friends")
            .getDocuments { snapshot, error in
            guard let friends = snapshot?.documents.compactMap({ $0.documentID }), //document id is the username
            error == nil else {
                return
            }

            if friends.contains(where: { $0 == username }) {
                friended = true
            }
            completion(friended)
        }
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
    
    func getAllRequests(completion: @escaping ([String]) -> Void) {
        database.collection("users")
            .document(currentUsername)
            .collection("recievedRequests")
            .getDocuments { snapshot, error in
            guard let requests = snapshot?.documents.compactMap({ $0.documentID }), //document id is the username
            error == nil else {
                return
            }
            
            completion(requests)
        }
    }
}
