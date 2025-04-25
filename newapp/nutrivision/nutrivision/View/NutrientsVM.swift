//
//  NutrientsVM.swift
//  Munch
//
//

import Foundation


final class NutrientsVM: ObservableObject {
    @Published var nutrients: Nutrients = MockNutrients.mockNutrients
    
    func loadNutrients(food: String) {
        APIServices.shared.loadNutrients(food: food, onSuccess: {(nutrientsResponse) in
            self.nutrients = nutrientsResponse
        })
    }
}
 
