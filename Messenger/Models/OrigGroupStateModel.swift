//
//  OriginalGroupStateModel.swift
//  Messenger
//
//  Created by Harrison Cooley on 11/8/22.
//

import Foundation
import SwiftUI

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

import WebKit

class OrigGroupStateModel: ObservableObject {
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

    var groupListener: ListenerRegistration?
    var groupNameListener: ListenerRegistration?
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

// Groups

extension OrigGroupStateModel {
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
        
        //first for everyone being added
        for user in selected { //created for loop here
            //populate their groupMembers collection with other new groupMembers
            for member in selected {
                database.collection("users")
                    .document(user)
                    .collection("groupMembers")
                    .document(member).setData(["name": member, "beerCount": 0])
            }
            //then populate their groupMembers collection with already existing groupMembers
            for currentMember in currentGroup {
                database.collection("users")
                    .document(user)
                    .collection("groupMembers")
                    .document(currentMember.name).setData(["name": currentMember.name, "beerCount": 0])
            }
            database.collection("users")
                .document(user).setData(["inGroup": true], merge: true)
                //.document(user).setData(["inGroup": true,"groupName": ], merge: true)
        }
        //then for all the members who were already in the group before the additions
        for user in currentGroup {
            print("")
            print("")
            print("")
            print(user.name)
            print("")
            print("")
            print("")
            //add all the new members to the exisiting member's groupMember collection
            for member in selected {
                database.collection("users")
                    .document(user.name)
                    .collection("groupMembers")
                    .document(member).setData(["name": member, "beerCount": 0])
            }
        }
    }
    
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



