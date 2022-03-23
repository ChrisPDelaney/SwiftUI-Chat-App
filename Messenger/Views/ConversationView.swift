//
//  ContentView.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import SwiftUI

struct ConversationListView: View {
    @EnvironmentObject var model: AppStateModel
    @State var otherUsername: String = ""
    @State var showChat = false
    @State var showSearch = false

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ForEach(model.conversations, id: \.self) { name in
                    NavigationLink( //Where you're linking to
                        destination: ChatView(otherUsername: name),//destination is the user's view
                        label: {
                            HStack {
                                Image(model.currentUsername == "Matt" ? "photo1" : "photo2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 65, height: 65)
                                    .foregroundColor(Color.pink)
                                    .clipShape(Circle())

                                Text(name)
                                    .bold()
                                    .foregroundColor(Color(.label))
                                    .font(.system(size: 32))

                                Spacer()
                            }
                            .padding()
                        })
                }

                //open up chat view automatically by tapping something in search?
                if !otherUsername.isEmpty {
                    NavigationLink("",
                                   destination: ChatView(otherUsername: otherUsername),
                                   isActive: $showChat)
                }
            }
            .navigationTitle("Conversations")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        self.signOut()
                    }
                }
                //search bar
                ToolbarItem(placement: .navigationBarTrailing) { 
                    NavigationLink(         //name will be the other user's name we tapped to start a convo with
                        destination: SearchView { name in
                            self.showSearch = false
                            print("hello")
                           //we want to wait for the search view to disappear before we try to show the chat view
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) { //add delay to assigning those
                                self.showChat = true
                                self.otherUsername = name //retrieved from compeltion handler of SearchView
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

                model.getConversations()
            }
        }
    }

    func signOut() {
        model.signOut()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationListView()
    }
}
