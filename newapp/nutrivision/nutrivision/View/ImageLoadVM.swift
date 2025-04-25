//
//  ImageLoadVM.swift
//  Munch
//
//

import Foundation
import SwiftUI

final class ImageLoadVM: ObservableObject {
    @Published var detectedIngredients: [String] = []
    @Published var isReady: Bool = false

    var userData: UserData?

    /// Uploads an image to the backend for segmentation and analysis.
    /// Once ingredients are returned, it passes them along with allergy info to `MacrosVM` to generate recipe suggestions.
    func postImage(img: Image, userData: UserData, macrosVM: MacrosVM, purpose: String = "segment_and_analyze") {
        self.userData = userData
        self.isReady = false
        self.detectedIngredients = []

        print("📤 Starting image upload for segmentation + analysis...")

        APIServices.shared.segmentAndDetectIngredients(image: img, purpose: purpose) { result in
            switch result {
            case .success(let ingredients):
                DispatchQueue.main.async {
                    self.detectedIngredients = ingredients
                    print("✅ Segmentation successful. Ingredients: \(ingredients)")
                    
                    // Pass segmented ingredients + allergies to MacrosVM
                    macrosVM.runModel(labels: ingredients, userData: userData)
                }
            case .failure(let error):
                print("❌ Segmentation/Detection failed: \(error)")
            }
        }
    }
}
