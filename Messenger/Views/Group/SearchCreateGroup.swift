//
//  SearchCreateGroup.swift
//  Messenger
//
//  Created by Harrison Cooley on 11/16/22.
//

import SwiftUI

struct SearchCreateGroup: View {
    
    @State var rootIsActive : Binding<Bool>
    
    //Allows you to dismiss given presentation by using this property wrapper
    //@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    //Got rid of using presentationMode.dismiss() because it is not efficient for loading views
    // According to https://jayeshkawli.ghost.io/correct-way-to-dismiss-screen-in-swiftui/
    
    //Would also need to use the newer version for iOS 15 anyway
    //@Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var model: AppStateModel
    @State var text: String = ""

    @State var usernames_available: [String] = []
    @State var usernames_unavailable: [String] = []
    @State var selected: [String] = []
        
    let completion: (([String], String) -> Void)

    init(isActive: Binding<Bool>, completion: @escaping (([String], String) -> Void)) {
        //requires this syntax bc its a state variable and a binding. Should look into reasoning more
        self._rootIsActive = State(initialValue: isActive)
        self.completion = completion
        print("In init for SearchCreateGroup")
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
        
        VStack{
            
            VStack(alignment: .leading){
                
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
                
                

                Spacer()
                
            }//END Vstack
            
            HStack(){
                
                NavigationLink{
                    //selected.append(model.currentUsername)
                    //presentationMode.wrappedValue.dismiss()//this will dismiss the search view
                    //completion(selected) //date not name JP
                    ChooseGroupName(shouldPopToRootView: self.rootIsActive){ name in
                        selected.append(model.currentUsername)
                        
                        //this will dismiss the search view
                        //presentationMode.wrappedValue.dismiss()
                        
                        self.rootIsActive = .constant(false)
                        
                        print("Just dismissed the presentationMode on SearchCreateGroup")
                        completion(selected, name)
                        
                    }
                    
                }
                label: {
                    Text("Continue")
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
                } //END navLink label
                .isDetailLink(false)
                
            }//END hstack
            
        }//END outer Vstack
        .navigationTitle("Search Users")
    }
}

//struct SearchCreateGroup_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchCreateGroup(isActive: true){ name, _  in
//
//        }
//            .preferredColorScheme(.dark)
//    }
//}
