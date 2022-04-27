//
//  ProfileView.swift
//  Messenger
//
//  Created by JP Mancini on 4/11/22.
//

import SwiftUI
import URLImage

struct ProfileView: View {
    @EnvironmentObject var model: AppStateModel
    
    @State var showSearch = false
    @State var showDiscover = false
    
    //For profile image
    @State var showImagePicker: Bool = false
    @State var image: Image = Image(systemName: "person.crop.circle.badge.plus")
    @State var imageData: Data = Data()
    
    var body: some View {
        
            VStack {
                HStack {
                    Spacer()
                }
                .padding(.horizontal, 25)
                     
                
                URLImage(URL(string: model.profileUrl)! ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 245, height: 245)
                        .clipShape(Circle())
                }

                
                Text(model.currentUsername) //name
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("37 Mutuals") //mutuals
                    .font(.title2)
                
            }.sheet(isPresented: $showImagePicker){
                ImagePicker(showImagePicker: self.$showImagePicker, pickedImage: self.$image,
                            imageData: self.$imageData)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
