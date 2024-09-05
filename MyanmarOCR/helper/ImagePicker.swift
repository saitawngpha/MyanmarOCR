//
//  ImagePicker.swift
//  MyanmarOCR
//
//  Created by Steve Pha on 04/09/2024.
//

import Foundation
import SwiftUI
import PhotosUI
import CropViewController
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // For PHPicker (Photo Library)
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        if let uiImage = image as? UIImage {
                            self.showCropViewController(for: uiImage)
                        }
                    }
                }
            }
        }
        
        // For UIImagePickerController (Camera)
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            
            if let uiImage = info[.originalImage] as? UIImage {
                self.showCropViewController(for: uiImage)
            }
        }
        
        func showCropViewController(for image: UIImage) {
            let cropViewController = CropViewController(image: image)
            cropViewController.delegate = self
            cropViewController.aspectRatioPreset = .presetCustom
            cropViewController.aspectRatioLockEnabled = false
            
            if let topViewController = UIApplication.shared.windows.first?.rootViewController {
                topViewController.present(cropViewController, animated: true)
            }
        }
        
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
            parent.image = image
            cropViewController.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        if sourceType == .camera {
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = .camera
            cameraPicker.delegate = context.coordinator
            return cameraPicker
        } else {
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = context.coordinator
            return picker
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

//import SwiftUI
//import UIKit
//
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var isPresented: Bool
//    @Binding var image: UIImage?
//    var onImagePicked: (UIImage?) -> Void
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
//        if !isPresented {
//            uiViewController.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        var parent: ImagePicker
//        
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let pickedImage = info[.originalImage] as? UIImage {
//                parent.image = pickedImage
//                parent.onImagePicked(pickedImage)
//            }
//            parent.isPresented = false
//        }
//        
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.isPresented = false
//        }
//    }
//}
