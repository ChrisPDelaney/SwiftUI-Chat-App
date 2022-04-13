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

    @State var usernames: [String] = []
    @State var venues: [String] = []
    
    var body: some View {//test comment
        let binding = Binding<String>(get: {
            self.text
        }, set: {
            self.text = $0
            guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            if (searchPeople) {
                model.searchAllUsers(queryText: text) { usernames in
                    self.usernames = usernames
                }
            }
            else {
                model.searchVenues(queryText: text) { venues in
                    self.venues = venues
                }
            }
        })
        
        VStack {
            TextField(searchPeople ? "Search people" : "Search venues", text: binding) //the text the user is typing in
            .modifier(CustomField())
            
            ToggleItem(isOn: searchPeople)
                .onTapGesture {
                    searchPeople.toggle()
                    text = ""
                    venues = []
                    usernames = []
                }

            List {
                if (searchPeople) {
                    ForEach(usernames, id: \.self) { name in //JP
                        if name != model.currentUsername {
                            HStack {
                                Image("photo1")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 55, height: 55)
                                    .clipShape(Circle())

                                Text(name) //JP
                                    .font(.system(size: 24))
                            } //open up
                            .onTapGesture {
                                print("aloha")
                            }
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
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
