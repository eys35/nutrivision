//
//  ImageLoadVM.swift
//  Munch
//
//

import Foundation
import SwiftUI

final class ImageLoadVM: ObservableObject {
    @Published var food_id: String = ""
    @Published var isReady: Bool = false
    @Published var detectedIngredients: [String] = []
    @Published var suggestedRecipes: [String] = []

    var userData: UserData?

    func postImage(img: Image, userData: UserData) {
        self.userData = userData

        // 1. Step: Send image to API for segmentation + ingredient detection
//        APIServices.shared.segmentAndDetectIngredients(image: img) { result in
//            switch result {
//            case .success(let ingredients):
//                DispatchQueue.main.async {
//                    self.detectedIngredients = ingredients
//                }
//
//                // 2. Step: Send ingredients + allergies to GPT to get recipe ideas
//                self.fetchRecipes(from: ingredients, with: userData)
//                
//            case .failure(let error):
//                print("Segmentation/Detection failed: \(error)")
//            }
//        }
    }

    func fetchRecipes(from ingredients: [String], with userData: UserData) {
        let allergies = [
            "Peanuts": userData.isAllergicToPeanuts,
            "Dairy": userData.isAllergicToDairy,
            "Shellfish": userData.isAllergicToShellfish,
            "Gluten": userData.isAllergicToGluten,
            "Eggs": userData.isAllergicToEggs,
            "TreeNuts": userData.isAllergicToTreeNuts,
            "Wheat": userData.isAllergicToWheat,
            "Soy": userData.isAllergicToSoy,
            "Fish": userData.isAllergicToFish
        ]
        
        let allergyList = allergies.filter { $0.value }.map { $0.key }
//
//        APIServices.shared.generateRecipes(
//            ingredients: ingredients,
//            allergies: allergyList,
//            onSuccess: { recipes in
//                DispatchQueue.main.async {
//                    self.suggestedRecipes = recipes
//                    self.isReady = true
//                }
//            }
//        )
    }
}
 
