//
//  BeerStateModel.swift
//  Messenger
//
//  Created by Harrison Cooley on 11/10/22.
//

import Foundation
import SwiftUI

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

import WebKit


class BeerStateModel: ObservableObject {
    @AppStorage("currentUsername") var currentUsername: String = ""
    @AppStorage("currentEmail") var currentEmail: String = ""
    @AppStorage("profileUrl") var profileUrl: String = ""
    @AppStorage("currentNumFriends") var currentNumFriends: Int = 0
    
    @AppStorage("currentDate") var currentDate: String = "2022-01-27" //added
    @AppStorage("currentVenue") var currentVenue: String = "The Tombs" //added
    @AppStorage("currentGroupName") var currentGroupName: String = ""

    let database = Firestore.firestore()
    let auth = Auth.auth()
    
    private let defaults = UserDefaults.standard
    
    

}

extension BeerStateModel {
    func increaseDrink() {
        database.collection("groups")
            .document(currentGroupName)
            .collection("members")
            .document(currentUsername).updateData(["beerCount": FieldValue.increment(Int64(1))])
    }
    
    func resetDrink() {
        database.collection("groups")
            .document(currentGroupName)
            .collection("members")
            .document(currentUsername).setData(["beerCount": 0], merge: true)
    }
}
