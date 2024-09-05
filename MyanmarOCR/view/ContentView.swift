//
//  ContentView.swift
//  MyanmarOCR
//
//  Created by Steve Pha on 04/09/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = OCRViewModel()
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                Text(viewModel.recognizedText)
                    .padding()
            } else {
                Text("Select an image to recognize text.")
                    .padding()
            }
            
            Button("Pick Image") {
                isImagePickerPresented.toggle()
                imagePickerSourceType = .camera
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented, onDismiss: {
            if let image = selectedImage {
                viewModel.recognizeText(from: image)
            }
        }) {
            ImagePicker(image: $selectedImage, sourceType: imagePickerSourceType)
        }
        .onChange(of: selectedImage) { image in
            if let unwrappedImage = image {
                    viewModel.recognizeText(from: unwrappedImage)
            }else {
                print("No image selected.")
            }
        }
    }
}

#Preview {
    ContentView()
}
