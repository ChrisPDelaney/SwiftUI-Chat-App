//
//  SearchView.swift
//  Messenger
//
//  Created by JP Mancini on 4/13/22.
//

import SwiftUI

struct ToggleItem: View {
    var isOn:Bool
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .foregroundColor(Color.gray.opacity(0.3))
            .frame(width: 350, height: 45)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
                    .frame(width: 175, height: 35)
                    .padding([.leading, .trailing], 5),
                alignment: isOn ? .trailing : .leading
            )
            .animation(.linear(duration: 0.1))
            .overlay(
                Text("Venues")
                    .padding(.leading, 55),
                alignment: .leading
            )
            .overlay(
                Text("People")
                    .padding(.trailing, 55),
                alignment: .trailing
            )
    }
}

struct SearchView: View {
    @EnvironmentObject var model: AppStateModel
    @State var text: String = ""
    
    @State var searchPeople: Bool = false
    
    @State var users: [User] = []
    @State var venues: [String] = []
    
    var body: some View {//test comment
        let binding = Binding<String>(get: {
            self.text
        }, set: {
            self.text = $0
            guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            //getting the users from firebase
            if (searchPeople) {
                model.searchAllUsers(queryText: text) { users in
                    self.users = users
                }
            }
            else {
                //getting the venues from firebase
                model.searchVenues(queryText: text) { venues in
                    self.venues = venues
                }
            }
        })
        
        NavigationView{
            VStack {
                TextField(searchPeople ? "Search people" : "Search venues", text: binding) //the text the user is typing in
                .modifier(CustomField())
                
                ToggleItem(isOn: searchPeople)
                    .onTapGesture {
                        searchPeople.toggle()
                        text = ""
                        venues = []
                        users = []
                    }

                List {
                    if (searchPeople) {
                        ForEach(users, id: \.self) { user in //JP
                            if user.name != model.currentUsername {
                                NavigationLink(
                                    destination: UserProfile(user: user),
                                    label: {
                                        UserSearchRow(user: user)
                                    }
                                )
                            }
                        }
                    }
                    else {
                        ForEach(venues, id: \.self) { venue in //JP
                            HStack {
                                Image("photo2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())

                                Text(venue) //JP
                                    .font(.system(size: 24))
                            } //open up
                            .onTapGesture {
                                print("aloha")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
