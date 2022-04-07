//
//  ContentView.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import SwiftUI

struct GroupHome: View {
    @EnvironmentObject var model: AppStateModel
    @State var otherUsernames: [String] = []
    @State var dayString: String = ""
    @State var showChat = false
    @State var showSearch = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical) {
                    ForEach(model.currentGroup, id: \.self) { user in
                        GroupMemberRow(user: user)
                    }
                }
                HStack {
                    NavigationLink( //Where you're linking to
                        destination: ChatView(),//destination is the user's view //JP FIX
                        //model.currentGroup = selected, //retrieved from compeltion handler of SearchView //JP
                        label: {
                            Image("chat")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 65, height: 65)
                        }
                    )
                    Spacer()
                    Button( action: {
                        model.increaseDrink()
                    }) {
                        Image("drink")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                    }
                }
                .padding()
            }
            .navigationTitle(model.currentDate)
            //.navigationBarItems(trailing: Text(model.currentVenue))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button( action: {
                        self.signOut()
                    }) {
                        Text(model.currentUsername)
                            .foregroundColor(.black)
                            .font(.custom("Sacramento-Regular", size: 40))
                    }
                }
                //search bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink( //name will be the other user's name we tapped to start a convo with
                        destination: SearchView { selected  in //JP
                            self.showSearch = false

                            //we want to wait for the search view to disappear before we try to show the chat view
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) { //add delay to assigning those //Consider changing
                                self.showChat = true //breakpoint
                                model.createGroup(selected: selected)
                            }
                        },
                        isActive: $showSearch,
                        label: {
                            Image(systemName: "magnifyingglass")
                        })
                }
            }
            .fullScreenCover(isPresented: $model.showingSignIn, content: {
                SignInView()
            })
            .onAppear {
                //make sure the user is signed in, don't want to get conversations if there's no user
                guard model.auth.currentUser != nil else {
                    return
                }
                
                model.getGroup()
            }
        }
    }

    func signOut() {
        model.signOut()
    }
}

struct GroupHomeView_Previews: PreviewProvider {
    static var previews: some View {
        GroupHome()
    }
}
