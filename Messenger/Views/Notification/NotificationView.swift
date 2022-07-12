//
//  NotificationView.swift
//  Messenger
//
//  Created by JP Mancini on 7/12/22.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var model: AppStateModel
    @State var requests: [String] = []
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                ForEach(requests, id: \.self) { name in //JP
                    NotificationRow(name: name)
                }
            }
        }
        .navigationBarTitle("Activity", displayMode: .inline)
        .onAppear {
            model.getAllRequests() { requests in
                self.requests = requests
            }
        }
    }
    
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
