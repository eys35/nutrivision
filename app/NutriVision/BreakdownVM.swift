//
//  BreakdownViewModel.swift
//  Munch
//
//

import Foundation


final class BreakdownVM: ObservableObject {
    @Published var nutrients: Nutrients = MockNutrients.mockNutrients
    
    init() { }
    
    func loadNutrients() {
        APIServices.shared.loadNutrients(){(nutrientsResponse) in
            self.nutrients = nutrientsResponse
        }
    }
}
 
