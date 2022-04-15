//
//  userProfile.swift
//  Messenger
//
//  Created by JP Mancini on 4/13/22.
//

import SwiftUI

struct userProfile: View {
    @EnvironmentObject var model: AppStateModel
    @State private var isRequested: Bool = false
        
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
            
            Button(action: {
                model.requestFriend(username: user.name)
                self.isRequested = true
            }) {
                Text(isRequested ? "Requested" : "Add Friend")
                    .font(.title)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .border(Color.black, width: 1)
                    .onAppear{
                        model.checkRequested(username: user.name) { requested in
                            self.isRequested = requested
                        }
                    }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            
            Spacer()
        }
    }
}
