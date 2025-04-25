//
//  BreakdownVM.swift
//  nutrivision
//
//  Created by elizabeth song on 4/24/25.
//

import Foundation


final class BreakdownVM: ObservableObject {
    @Published var nutrients: Nutrients = MockNutrients.mockNutrients
    
    init() { }
    
    func loadNutrients() {
        APIServices.shared.loadNutrients(food: ""){(nutrientsResponse) in
            self.nutrients = nutrientsResponse
        }
    }
}
 
