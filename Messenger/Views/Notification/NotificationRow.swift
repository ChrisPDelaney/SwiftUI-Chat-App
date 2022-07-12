//
//  NotificationRow.swift
//  Messenger
//
//  Created by JP Mancini on 7/12/22.
//

import SwiftUI

struct NotificationRow: View {
    //let user: User
    
    var body: some View {
        HStack {
            Image("photo1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .clipShape(Circle())

            Text("user.name sent you a friend request") //JP
                .font(.system(size: 18))
            
            Spacer()
            
            Button(action: {
                //model.acceptRequest()
            }, label: {
                Text("Accept")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .frame(width: 80, height: 35)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
            })
            
            Button(action: {
                //model.denyRequest()
            }, label: {
                Image(systemName: "xmark")
                    .foregroundColor(Color.black)
            })
        }
        .padding(.horizontal)
    }
}
