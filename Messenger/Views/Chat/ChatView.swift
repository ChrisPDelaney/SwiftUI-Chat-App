//
//  ChatView.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import SwiftUI

//Custom field for text fields, specifically for searches
struct CustomField: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(7)
    }
}

struct ChatView: View {
    @State var message: String = ""
    @EnvironmentObject var model: AppStateModel
    @EnvironmentObject var model2: GroupStateModel
    
    var body: some View {
        VStack { 
            
            //This is going to nest a bunch of chat
            ScrollView(.vertical) {
                ForEach(model2.messages, id: \.self) { message in
                    ChatRow(text: message.text,
                            type: message.type,
                            sender: message.sender)
                        .padding(3)
                }
            }

            // Field, send button
            HStack {
                TextField("Message...", text: $message)
                    .modifier(CustomField())

                SendButton(text: $message)
            }
            .padding()
        }
        .navigationBarTitle(model2.currentDate, displayMode: .inline) //JP FIX
        .toolbar {
            //leave button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    model2.leaveGroup2()
                }) {
                    Text("Leave")
                }
            }
        }
        .onAppear { //start observing the conversation that we're in
            model2.inChat = true
            print("The bool inChat is \(model2.inChat)")
            model2.getMsgsFromGroupDoc()
            model2.getNewMsgs()
        }
    }
}
