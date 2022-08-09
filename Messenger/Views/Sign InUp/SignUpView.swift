//
//  SignUpView.swift
//  Messenger
//
//  Created by Afraz Siddiqui on 4/17/21.
//

import SwiftUI

struct SignUpView: View {
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""

    @EnvironmentObject var model: AppStateModel
    
    //For profile image
    @State var showImagePicker: Bool = false
    @State var image: Image = Image(systemName: "person.circle.fill")
    @State var imageData: Data = Data()
    
    let imageModel: UIImage = UIImage(systemName: "person.circle.fill") ?? UIImage()

    var body: some View {
        VStack {
            // Heading
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .onTapGesture {
                    self.showImagePicker = true
                    
                }
                .onAppear {
                    imageData = self.imageModel.jpegData(compressionQuality: 0.05) ?? Data()
                }

            // Textfields

            VStack {
                TextField("Email Address", text: $email)
                    .modifier(CustomField())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                TextField("Username", text: $username)
                    .modifier(CustomField())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("Password", text: $password)
                    .modifier(CustomField())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                Button(action: {
                    self.signUp()
                }, label: {
                    Text("Sign Up")
                        .foregroundColor(Color.white)
                        .frame(width: 220, height: 50)
                        .background(Color.green)
                        .cornerRadius(6)
                })
            }
            .padding()

            Spacer()
        }
        .sheet(isPresented: $showImagePicker){
            
            ImagePicker(showImagePicker: self.$showImagePicker, pickedImage: self.$image,
                        imageData: self.$imageData, sourceType: .camera)
        }
        .navigationBarTitle("Create Account", displayMode: .inline)
    }

    func signUp() {
        print("Sign Up:")
        print(imageData)
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            return
        }
        model.signUp(email: email, username: username, password: password, imageData: imageData)
        print("goes past sign up function")
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
