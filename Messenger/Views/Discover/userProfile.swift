//
//  userProfile.swift
//  Messenger
//
//  Created by JP Mancini on 4/13/22.
//

import SwiftUI

struct UserProfile: View {
    @EnvironmentObject var model: AppStateModel
    
    @State private var isFriend: Bool = false
    @State private var sentRequest: Bool = false
    @State private var receivedRequest: Bool = false
        
    let user: User
    
    var body: some View {
        VStack {
            Image("photo1") //profile picture
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 245, height: 245)
                .clipShape(Circle())
            
            Text(user.name) //name
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(user.numFriends) Friends") //mutuals
                .font(.title2)
            
            if isFriend {
                Text("Current Friend")
                    .font(.title)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .border(Color.black, width: 1)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            else if sentRequest {
                Text("Requested")
                    .font(.title)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .border(Color.black, width: 1)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            else if receivedRequest {
                HStack {
                    Button(action: {
                        model.acceptRequest(username: user.name)
                        self.receivedRequest = false
                    }) {
                        Text("Accept")
                            .font(.title)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.black, width: 1)
                    }
                    Button(action: {
                        model.removeRequest(username: user.name)
                        self.receivedRequest = false
                    }) {
                        Text("Decline")
                            .font(.title)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .border(Color.red, width: 1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            else {
                Button(action: {
                    model.requestFriend(username: user.name)
                    self.sentRequest = true
                }) {
                    Text("Add Friend")
                        .font(.title)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .border(Color.black, width: 1)
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            
            Spacer()
        }
        .onAppear{
            model.checkFriend(username: user.name) { friended in
                self.isFriend = friended
            }
            model.checkSentRequest(username: user.name) { requested in
                self.sentRequest = requested
            }
            model.checkReceivedRequest(username: user.name) { requested in
                self.receivedRequest = requested
            }
        }
    }
}
