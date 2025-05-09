//
//  LoadingVM.swift
//  Munch
//
//
import Foundation

final class MacrosVM: ObservableObject {
    @Published var food_name: String = ""
    @Published var isReady: Bool = false
    @Published var recipeSuggestion: RecipeSuggestion = RecipeSuggestion(
        name: "",
        ingredients: [],
        userAllergies: [],
        instructions:[],
        difficulty: "",
        preparationTime:0,
        servings: 0
        
    )
    
    func runModel(labels: [String], userData: UserData) {
        self.isReady = false

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

        APIServices.shared.runModel(labels: labels, allergies: allergyList) { result in
            DispatchQueue.main.async {
                self.recipeSuggestion = result
                self.food_name = result.name
                self.isReady = true
            }
        }
    }
}
