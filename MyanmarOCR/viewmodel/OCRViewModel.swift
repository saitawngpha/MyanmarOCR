//
//  OCRViewModel.swift
//  MyanmarOCR
//
//  Created by Steve Pha on 04/09/2024.
//

import Foundation
import SwiftyTesseract
import SwiftUI

class OCRViewModel: ObservableObject {
    @Published var recognizedText: String = ""
    
    private let tesseract = Tesseract(language: .custom("mya"))
    
    func recognizeText(from image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("Failed to convert UIImage to Data.")
            return
        }
        
        // Perform OCR synchronously
        let result: Result<String, Tesseract.Error> = tesseract.performOCR(on: imageData)
        
        // Update recognizedText on the main thread
        DispatchQueue.main.async {
            switch result {
            case .success(let text):
                self.recognizedText = text
            case .failure(let error):
                print("OCR failed: \(error.localizedDescription)")
                self.recognizedText = "OCR failed."
            }
        }
    }
}
