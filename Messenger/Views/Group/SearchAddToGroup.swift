//
//  SearchAddToGroup.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import SwiftUI

struct SearchAddToGroup: View {
    
    //Allows you to dismiss given presentation by using this property wrapper
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var model: AppStateModel
    @State var text: String = ""

    @State var usernames_available: [String] = []
    @State var usernames_unavailable: [String] = []
    @State var selected: [String] = []
        
    let completion: (([String]) -> Void)

    init(completion: @escaping (([String]) -> Void)) {
        self.completion = completion
    }
    
    var body: some View {//test comment
        let binding = Binding<String>(get: {
            self.text
        }, set: {
            self.text = $0
            guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }

            model.searchAvailableUsers(queryText: text) { usernames in
                self.usernames_available = usernames
            }
            
            model.searchUnavailableUsers(queryText: text) { usernames in
                self.usernames_unavailable = usernames
            }
        })
        VStack {
            TextField("Username...", text: binding) //the text the user is typing in
            .modifier(CustomField())

            List {
                ForEach(usernames_available, id: \.self) { name in //JP
                    if name != model.currentUsername {
                        HStack {
                            Image("photo1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())

                            Text(name) //JP
                                .font(.system(size: 24))
                                    
                            Spacer()
                            
                            Image(systemName: selected.contains(name) ? "checkmark.circle.fill" : "circle") //if array contains name (fill/empty)
                                .resizable()
                                .foregroundColor(.blue)
                                .padding()
                                .frame(width: 55, height: 55)
                        } //open up
                        .onTapGesture { // add/remove to selected array
                            if let idx = selected.firstIndex(of: name) { // if in array
                                selected.remove(at: idx)
                            } else { // if not in array
                                selected.append(name)
                            }
                        }
                    }
                }
                
                ForEach(usernames_unavailable, id: \.self) { name in //JP
                    if name != model.currentUsername {
                        HStack {
                            Image("photo1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())

                            Text(name) //JP
                                .font(.system(size: 24))
                                    
                            Spacer()
                            
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .foregroundColor(.blue)
                                .padding()
                                .frame(width: 55, height: 55)
                        } //open up
                    }
                }
            }
            
            Button(action: {
                selected.append(model.currentUsername)
                presentationMode.wrappedValue.dismiss()//this will dismiss the search view
                completion(selected) //date not name JP
            }) {
                Text("Add to Group")
                    .font(.largeTitle)
                    .foregroundColor(selected.isEmpty ? Color.blue : Color.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 3)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selected.isEmpty ? Color.white : Color.blue)
                            )
                    )
            }

            Spacer()
        }   
        .navigationTitle("Search")
    }
}

struct SearchAddToGroup_Previews: PreviewProvider {
    static var previews: some View {
        SearchAddToGroup() { _  in }
            .preferredColorScheme(.dark)
    }
}
