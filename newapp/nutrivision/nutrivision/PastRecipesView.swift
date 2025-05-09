//
//  PastRecipesView.swift
//  nutrivision
//
//  Created by elizabeth song on 4/25/25.
//

import SwiftUI

struct PastRecipesView: View {
    @AppStorage("savedRecipes") private var savedRecipesData: Data = Data()
    
    var recipes: [RecipeSuggestion] {
        if let decoded = try? JSONDecoder().decode([RecipeSuggestion].self, from: savedRecipesData) {
            return decoded
        }
        return []
    }

    var body: some View {
        NavigationView {
            List {
                if recipes.isEmpty {
                    Text("No past recipes yet.")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(recipes, id: \.name) { recipe in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.name)
                                .font(.headline)

                            if !recipe.ingredients.isEmpty {
                                Text("You needed:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(recipe.ingredients.joined(separator: ", "))
                                    .font(.body)
                            }


                            if !recipe.userAllergies.isEmpty {
                                Text("Avoided (allergies):")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                Text(recipe.userAllergies.joined(separator: ", "))
                                    .font(.body)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Past Recipes")
        }
    }
}
