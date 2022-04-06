//
//  SearchView.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import SwiftUI

struct SearchView: View {
    
    //Allows you to dismiss given presentation by using this property wrapper
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var model: AppStateModel
    @State var text: String = ""

    @State var usernames: [String] = []
    @State var selected: [String] = []
        
    let completion: (([String]) -> Void)

    init(completion: @escaping (([String]) -> Void)) {
        self.completion = completion
    }
    
    var body: some View {//test comment
        VStack {
            TextField("Username...", text: $text) //the text the user is typing in
                .modifier(CustomField())

            Button("Search") { //ensures that user is not just searching for whitespace
                guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return
                }

                model.searchUsers(queryText: text) { usernames in
                    self.usernames = usernames
                }
            }

            List {
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView() { _  in }
            .preferredColorScheme(.dark)
    }
}
