//
//  ContentView.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import SwiftUI

struct NotificationNumLabel : View {
    @Binding var digit : Int
    var body: some View {
        ZStack {
            if digit != 0
            {
                Capsule().fill(Color.red).frame(width: 20 * CGFloat(numOfDigits()), height: 35, alignment: .topTrailing).position(CGPoint(x: 75, y: 0))
                Text("\(digit)")
                    .foregroundColor(Color.white)
                    .font(Font.system(size: 20).bold()).position(CGPoint(x: 75, y: 0))
            }
            
        }
    }
    func numOfDigits() -> Float {
        let numOfDigits = Float(String(digit).count)
        return numOfDigits == 1 ? 1.5 : numOfDigits
    }
}

struct GroupHome: View {
    @EnvironmentObject var model: AppStateModel
    @State var otherUsernames: [String] = []
    @State var dayString: String = ""
    @State var showChat = false
    @State var showSearch = false
    
    @State var exampleNum: Int = 23

    var body: some View {
        NavigationView {
            VStack {
                //If a group exists then display the current user's name and picture with their beer count
                ScrollView(.vertical) {
                    if let user = model.currentGroup.first(where: {$0.name == model.currentUsername}) {
                        CurrentUserRow(user: user)
                    }
                    //If a group exists then display each persons name and picture with their beer count
                    // except the current user who is already displayed from previous if statement
                    ForEach(model.currentGroup, id: \.self) { user in
                        if(user.name != model.currentUsername) {
                            GroupMemberRow(user: user)
                        }
                    }
                }
                HStack {
                    Spacer()
                    NavigationLink( //Where you're linking to
                        destination: ChatView(),//destination is the user's view //JP FIX
                        //model.currentGroup = selected, //retrieved from compeltion handler of SearchAddToGroup //JP
                        label: {
                            Image(systemName: "message") //Image("chat")
                                .font(.system(size: 65))
                                .overlay(NotificationNumLabel(digit: $model.unReadMsgs))
                                //.overlay(NotificationNumLabel(digit: $exampleNum))
                                //.resizable()
                                //.scaledToFit()
                                //.frame(width: 65, height: 65)
                                //.foregroundColor(.black)
                                //.overlay(Text("❤️"), alignment: .topTrailing)
                                
                                
                        }
                    )
                }
                .padding()
            }
            .navigationTitle(model.currentDate)
            //.navigationBarItems(trailing: Text(model.currentVenue))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            self.showSearch = true
                        }) {
                            Text("Add Members to Group")
                        }
                        if #available(iOS 15.0, *) {
                            Button(role: .destructive, action: {
                                model.leaveGroup()
                            }) {
                                Text("Leave Group")
                            }
                        } else {
                            Button(action: {
                                model.leaveGroup()
                            }) {
                                Text("Leave Group")
                            }                        }
                        if #available(iOS 15.0, *) {
                            Button(role: .destructive, action: {
                                model.signOut()
                            }) {
                                Text("Sign Out")
                            }
                        } else {
                            Button(action: {
                                model.signOut()
                            }) {
                                Text("Sign Out")
                            }
                        }
                    }
                    label: {
                        Label("Options", systemImage: "ellipsis")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: NotificationView(),
                        label: {
                            Image(systemName: "bell")
                                .foregroundColor(.black)
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: $model.showingSignIn, content: {
                SignInView()
            })
            .onAppear {
                model.inChat = false
                print("The bool inChat is \(model.inChat)")
                //make sure the user is signed in, don't want to get conversations if there's no user
                print("BEFORE RETURNING CURRENT USER IN GROUP HOME")
                guard model.auth.currentUser != nil else {
                    print("There is no current user")
                    return
                }
                model.getGroup()
                print("MODEL.GETGROUP EXECUTED")
                
                //Here call the new function to get number of new messages
                model.getNewMsgs()
            }
            .background(
                NavigationLink( //name will be the other user's name we tapped to start a convo with
                    destination: SearchAddToGroup { selected  in //JP
                        self.showSearch = false

                        //we want to wait for the search view to disappear before we try to show the chat view
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) { //add delay to assigning those //Consider changing
                            model.addToGroup(selected: selected)
                        }
                    },
                    isActive: $showSearch
                ) { EmptyView() }
            )
        }
    }

    func signOut() {
        model.signOut()
    }
}
