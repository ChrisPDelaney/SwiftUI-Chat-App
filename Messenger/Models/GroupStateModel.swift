//
//  GroupStateModel.swift
//  Messenger
//
//  Created by Harrison Cooley on 11/7/22.
//

import Foundation
import SwiftUI

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

import WebKit

//Represents view model for all group management functionality

//In this model, all group information is stored in a centralized database document under "groups".
//So each member of the group listens to the group document's members collection as opposed to their own
// document's members collection

//At the moment there are problems for the listener, because of the case where a user is not in a group,
// there needs to be a check for a group name, which makes the real time aspect require reloading the page

class GroupStateModel: ObservableObject {
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
        print("In initialization for groupStateModel")
        let userEmail = Auth.auth().currentUser?.email
        print(userEmail)
        print(currentUsername)
        self.showingSignIn = Auth.auth().currentUser == nil
        print(self.showingSignIn)
    }
}


// Groups

extension GroupStateModel {
    //change to create night
    func createGroup2(groupName: String, selected: [String], groupLoc: String)
    {
        //set the local AppStorage groupName
        self.currentGroupName = groupName
        
        //set the group document up in Firebase
        database.collection("groups").document(groupName).setData([
                    "groupName": groupName,
                    "groupLocation": groupLoc]) { error in
                        guard error == nil else { return }
                        
                }
        //Add members to the group members collection.
        // And for each member set their inGroup to true along with a field for the groupName
        for user in selected{
            database.collection("groups").document(groupName).collection("members").document(user).setData(["name": user, "beerCount": 0])
            database.collection("users")
                .document(user).setData(["inGroup": true,
                                         "groupName": groupName], merge: true)
            
        }
        
        
    }
    
    //if we choose to go with an invite and accept style
    func joinGroup(groupName: String){
        //this is where the app storage currentGroupName needs to be set
        
        DispatchQueue.main.async {
            self.currentGroupName = groupName
        }
    }
    
    func addToGroup2(groupName: String, selected: [String], groupLoc: String)
    {
        //if this is a member without a group, they are creating a group
        if self.currentGroupName == ""
        {
            //set the local AppStorage groupName
            self.currentGroupName = groupName
            
            //set the group document up in Firebase
            database.collection("groups").document(groupName).setData([
                        "groupName": groupName,
                        "groupLocation": groupLoc]) { error in
                            guard error == nil else { return }
                            
                    }
        }
        
        for user in selected{
            //for all members being added, set their name and beerCount in the group member collection
            database.collection("groups").document(groupName).collection("members").document(user).setData(["name": user, "beerCount": 0])
            
            //in each member's individual document set their inGroup to true and their groupName to name
            database.collection("users")
                .document(user).setData(["inGroup": true,
                                         "groupName": groupName], merge: true)
            
            database.collection("users")
                .document(user).collection("myGroups")
                .document(groupName).setData(["inGroup": true,
                                              "groupName": groupName], merge: true)
            
        }//END for user
        
    }
    
    func getGroupName(){
        print("Inside getGroupName")
        print("Current user name is : \(currentUsername)")
        print("The profile URL is: \(profileUrl)" )
        
        
        //get the current groupName from the database from within the user's document
//        let docRef = database.collection("users").document(currentUsername)
//
//        print("completed document reference")
//
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//                //print("Document data: \(dataDescription)")
//                //print("The document is \(document.data()?["groupName"])")
//                self.currentGroupName = document.data()?["groupName"] as? String ?? ""
//                print("The current groupName is \(self.currentGroupName)")
//            } else {
//                print("Document to get groupName does not exist")
//            }
//        }
        
        groupNameListener = database
            .collection("users")
            .document(currentUsername)
            .collection("myGroups").addSnapshotListener { [weak self] snapshot, error in
                guard let objects = snapshot?.documents.compactMap({ $0.data() }), //returns an array of dictionaries
                      error == nil else {
                    print("Error accessing groupName: \(String(describing: error))")
                    return
                }
                
                //Optimization idea: Only query for groups with inGroup as true to begin with.
                
                let groups: [Group] = objects.compactMap({//taking the text, sender, and created pieces out, casting them to appropriate expected types
                    return Group(
                        name: $0["groupName"] as? String ?? "",
                        inGroup: $0["inGroup"] as? Bool ?? false
                    )
                })
                
                var newGroupName: String = ""
                
                for group in groups{
                    if group.inGroup == true{
                        print("Found the current group. Name is \(group.name)")
                        newGroupName = group.name
                    }
                }
                
                print("The newGroupName var is set to \(newGroupName)")
                
                //if new group name found is not empty and it does not equal the existing stored name
                if !newGroupName.isEmpty && self!.currentGroupName != newGroupName{
                    // AND statement for UI loading efficiency, don't want to call getGroup2 here if
                    // the group has not changed, bc for that case the UI view already called getGroup
                    DispatchQueue.main.async {
                        self?.currentGroupName = newGroupName
                        print("Just set the currentGroupName to \(self!.currentGroupName)")
                        self?.getGroup2()
                        print("Just called getGroup2 from inside getGroupName dispatch queue")
                    }
                }
                
            } //end groupListener
    }//END getGroupName
    
    func getGroup2(){
        print("Inside getGroup2")
        print("Current user name is :")
        print(currentUsername)
        print("The profile URL is: \(profileUrl)" )
        
//        if self.currentGroupName != ""
//        {
//            print("Inside while currentGroupName is not empty")
//
            print("The current groupName is \(self.currentGroupName)")
            
            groupListener = database
                .collection("groups")
                .document(currentGroupName)
                .collection("members").addSnapshotListener { [weak self] snapshot, error in
                    guard let objects = snapshot?.documents.compactMap({ $0.data() }), //returns an array of dictionaries
                          error == nil else {
                        return
                    }

                        DispatchQueue.main.async {
                            self?.currentGroup = objects.map { data in
                                return GroupUser(
                                    name: data["name"] as? String ?? "",
                                    beerCount: data["beerCount"] as? Int ?? 0
                                )
                            }
                        }
                    
                } //end groupListener
            
        //}//END if != ""
        
        
    }
    
    func leaveGroup2(){
        print("Leave group called")
        self.groupListener?.remove()
        //remove user from the group's members collection
        database.collection("groups")
            .document(currentGroupName)
            .collection("members")
            .document(currentUsername).delete()
        
        //set user's inGroup to false and groupName to ""
        database.collection("users")
            .document(currentUsername).setData(["inGroup": false,
                                     "groupName": ""], merge: true)
        
        //set the document in the user's groups collection to false
        database.collection("users")
            .document(currentUsername)
            .collection("myGroups")
            .document(currentGroupName).setData(["inGroup": false], merge: true)
        
        DispatchQueue.main.async {
            print("The group before setting to empty is \(self.currentGroup)")
            self.currentGroup = []
            print("Just set currentGroup to empty. Now it is \(self.currentGroup)")
            self.currentGroupName = ""
            self.getGroupName()
            print("Just called getGroupName inside of leaveGroup2's dispatch queue")
        }
        
    }
    

}
