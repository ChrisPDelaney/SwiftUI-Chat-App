//
//  CurrentUserRow.swift
//  After Five Prototype
//
//  Created by JP Mancini on 4/13/22.
//

import SwiftUI

struct CurrentUserRow: View {
    @EnvironmentObject var model: AppStateModel
    @EnvironmentObject var beerModel: BeerStateModel
    
    let user: GroupUser
    
    @State private var showingBeerAlert = false
        
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
            
            Button(action: { //maybe move outside of scroll view
                // ignore
            }) {
                Image("drink")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 65)
            }
            .simultaneousGesture(LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                showingBeerAlert = true
            })
            .simultaneousGesture(TapGesture().onEnded {
                beerModel.increaseDrink()
            })
            .alert(isPresented: $showingBeerAlert) {
                Alert(
                    title: Text("Are you sure you want to reset drinks?"),
                    primaryButton: .destructive(Text("Reset")) {
                        beerModel.resetDrink()
                    },
                    secondaryButton: .cancel()
                )
            }
            
            Text("X\(user.beerCount)")
                .font(.title)
        }
        .padding()
    }
}

struct CurrentUserRow_Previews: PreviewProvider {
    static var previews: some View {
        let test = GroupUser(name: "", beerCount: 0)
        GroupMemberRow(user: test)
    }
}
