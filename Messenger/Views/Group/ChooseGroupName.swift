//
//  ChooseGroupName.swift
//  Messenger
//
//  Created by Harrison Cooley on 11/16/22.
//

import SwiftUI

struct ChooseGroupName: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var text: String = ""
    
    let completion: ((String) -> Void)

    init(completion: @escaping ((String) -> Void)) {
        self.completion = completion
    }
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.text
        }, set: { self.text = $0})
        
        VStack(alignment: .leading){
            
            Spacer()
            
            Text("Choose a name for your group")
                .font(.system(size: 20, weight: .bold, design: .default))
                .padding(.leading, 5)
            
            TextField("Group Name...", text: binding) //the text the user is typing in
            .modifier(CustomField())
            
            Spacer()
            
//            HStack {
//                Spacer()
//                NavigationLink {
//                    ChooseGroupVenue()
//                }
//                label: {
//                    Image(systemName: "arrowtriangle.right.fill")
//                        .resizable()
//                        .frame(width: 35, height: 35, alignment: .center)
//                        .foregroundColor(.blue)
//                        .padding()
//                }
//
//            } //END HStack
            
            HStack {
                Spacer()
                Button {
                    if self.text != ""{
                        presentationMode.wrappedValue.dismiss()//this will dismiss the view
                        completion(self.text)
                    }
                }
                label: {
                    Image(systemName: "arrowtriangle.right.fill")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .center)
                        .foregroundColor(.blue)
                        .padding()
                }

            } //END HStack
            
        }//END Vstack
        
    }
}

struct ChooseGroupName_Previews: PreviewProvider {
    static var previews: some View {
        ChooseGroupName(){ name in
            
        }
    }
}
