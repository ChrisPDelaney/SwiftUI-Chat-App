//
//  GroupMemberRow.swift
//  After Five Prototype
//
//  Created by JP Mancini on 3/16/22.
//

import SwiftUI

struct GroupMemberRow: View {
    @EnvironmentObject var model: AppStateModel
    
    let user: GroupUser
        
    var body: some View {
        HStack {
            Image("photo1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            
            Text(user.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Image("drink")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
            Text("X\(user.beerCount)")
                .font(.title)
        }
        .padding()
    }
}

struct GroupMemberRow_Previews: PreviewProvider {
    static var previews: some View {
        let test = GroupUser(name: "", beerCount: 0)
        GroupMemberRow(user: test)
    }
}
