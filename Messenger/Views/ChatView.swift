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

    var body: some View {
        VStack { 
            
            //This is going to nest a bunch of chat
            ScrollView(.vertical) {
                ForEach(model.messages, id: \.self) { message in
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
        .navigationBarTitle(model.currentDate, displayMode: .inline) //JP FIX
        .onAppear { //start observing the conversation that we're in
            model.observeChat()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .preferredColorScheme(.dark)
    }
}
