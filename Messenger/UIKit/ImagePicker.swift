//
//  ImagePicker.swift
//  Messenger
//
//  Created by Christopher Delaney on 4/25/22.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var showImagePicker: Bool
    @Binding var pickedImage: Image
    @Binding var imageData: Data

    //the output of this method will be the controller want to present
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        //imagePicker.allowsEditing = true
        return imagePicker
    }

    //Can be used to initialize intial values, called right after the makeUIViewController compeletes its task
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        return // we just want to present a default image picker
    }

    //used to implement the necessary delegate, data source, or other classes
    func makeCoordinator() -> ImagePicker.Coordinator {
        //Coordinator(self)
        Coordinator.init(self)//Image picker needs to perform delegate method
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parentImagePicker: ImagePicker

        init(_ imagePicker: ImagePicker) {
            self.parentImagePicker = imagePicker
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            parentImagePicker.pickedImage = Image(uiImage: uiImage)
            if let mediaData = uiImage.jpegData(compressionQuality: 0.5) {
                parentImagePicker.imageData = mediaData
                print(parentImagePicker.imageData)
            }
            parentImagePicker.showImagePicker = false

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parentImagePicker.showImagePicker = false
        }

    }
}

