//
//  ChatRow.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import SwiftUI

struct ChatRow: View {
    let type: MessageType
    @EnvironmentObject var model: AppStateModel

    var isSender: Bool {
        return type == .sent
    }

    let text: String

    //let's us know if the row is something we sent or received
    init(text: String, type: MessageType) {
        self.text = text //the text the user or other person sent/received
        self.type = type
    }

    var body: some View {
        HStack {
            
            //pushes to the right if not sender
            if isSender { Spacer() }

            //if it's not the sender
            if !isSender {
                VStack {
                    Spacer()
                    Image(model.currentUsername == "Matt" ? "photo1" : "photo2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundColor(Color.pink)
                        .clipShape(Circle())
                }
            }

            HStack {
                Text(text)
                    .foregroundColor(isSender ? Color.white : Color(.label)) //label color accomodates light/dark mode
                    .padding()
            }
            .background(isSender ? Color.blue : Color(.systemGray4))
            .padding(isSender ? .leading : .trailing, //cuts off message so it doesn't take up width of whole screen
                     isSender ? UIScreen.main.bounds.width/3 : UIScreen.main.bounds.width/5)
            .cornerRadius(6)

            if !isSender { Spacer() }

        }
    }
}

struct ChatRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatRow(text: "Test", type: .sent)
                .preferredColorScheme(.dark)
            ChatRow(text: "Test", type: .received)
                .preferredColorScheme(.light)

        }
    }
}
