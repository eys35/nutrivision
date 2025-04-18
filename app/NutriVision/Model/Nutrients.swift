//
//  Nutrients.swift
//  Munch
//
//

import Foundation

struct Nutrients: Codable {
    var carbs: Float64
    var fats: Float64
    var protein: Float64
}

struct MockNutrients {
    static let mockNutrients = Nutrients(carbs:0.0, fats:0.0, protein:0.0)
}
