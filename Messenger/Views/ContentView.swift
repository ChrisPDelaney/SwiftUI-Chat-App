//
//  ContentView.swift
//  After Five Prototype
//
//  Created by JP Mancini on 2/28/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppStateModel
    
    @State private var selection: Tab = .group

    enum Tab {
        case discover
        case group
        case profile
    }
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    var body: some View {
        TabView(selection: $selection) { //find way to show/hide tabbar
            SearchView()
                .tabItem {
                    Image(systemName: "pin.fill")
                }
                .tag(Tab.discover)
            GroupHome()
                .tabItem {
                    Image(systemName: "house.fill")
                }
                .tag(Tab.group)
            DiscoverHome()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                }
                .tag(Tab.profile)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppStateModel())

    }
}
