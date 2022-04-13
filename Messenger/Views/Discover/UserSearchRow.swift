//
//  UserSearchRow.swift
//  Messenger
//
//  Created by JP Mancini on 4/13/22.
//

import SwiftUI

struct UserSearchRow: View {
    let user: User
    
    var body: some View {
        HStack {
            Image("photo1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .clipShape(Circle())

            Text(user.name) //JP
                .font(.system(size: 24))
        } //open up
        .onTapGesture {
            print("aloha")
        }
    }
}
