//
//  NotificationView.swift
//  Messenger
//
//  Created by JP Mancini on 7/12/22.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var model: AppStateModel
    @State var otherUsernames: [String] = []
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                NotificationRow()
                NotificationRow()
            }
        }
        .navigationBarTitle("Activity", displayMode: .inline)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
