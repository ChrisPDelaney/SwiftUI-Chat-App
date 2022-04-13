//
//  DiscoverHome.swift
//  Messenger
//
//  Created by JP Mancini on 4/11/22.
//

import SwiftUI

struct DiscoverHome: View {
    @EnvironmentObject var model: AppStateModel
    
    @State var showSearch = false
    @State var showDiscover = false

    var body: some View {
        VStack {
            Text("Discover Home")
        }
        .toolbar {
            //search bar
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink( //name will be the other user's name we tapped to start a convo with
                    destination: SearchAddToGroup { selected  in //JP
                        self.showSearch = false

                        //we want to wait for the search view to disappear before we try to show the chat view
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) { //add delay to assigning those //Consider changing
                            self.showDiscover = true //breakpoint
                            model.createGroup(selected: selected)
                        }
                    },
                    isActive: $showSearch,
                    label: {
                        Image(systemName: "magnifyingglass")
                    })
            }
        }
    }
}

struct DiscoverHome_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverHome()
    }
}
