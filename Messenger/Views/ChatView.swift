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
    let otherUsername: String

    //for opening the chat view of a specific user
    init(otherUsername: String) {
        self.otherUsername = otherUsername
    }

    var body: some View {
        VStack { 
            
            //This is going to nest a bunch of chat
            ScrollView(.vertical) {
                ForEach(model.messages, id: \.self) { message in
                    ChatRow(text: message.text,
                            type: message.type)
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
        .navigationBarTitle(otherUsername, displayMode: .inline) //TESTING PULL
        .onAppear { //start observing the conversation that we're in
            model.otherUsername = otherUsername// this needs to set an array of the group chat of the other usernames
            model.observeChat()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(otherUsername: "Samantha")
            .preferredColorScheme(.dark)
    }
}
