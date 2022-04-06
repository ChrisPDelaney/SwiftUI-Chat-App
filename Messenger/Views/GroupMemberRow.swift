//
//  NightOutMember.swift
//  After Five Prototype
//
//  Created by JP Mancini on 3/16/22.
//

import SwiftUI

struct NightOutMember: View {
    var body: some View {
        HStack {
            Image("Chris")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            
            Text("Christopher")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Image("drink")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
            Text("X7")
                .font(.title)
        }
        .padding()
    }
}

struct NightOutMember_Previews: PreviewProvider {
    static var previews: some View {
        NightOutMember()
    }
}
