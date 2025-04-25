//
//  PastRecipesView.swift
//  nutrivision
//
//  Created by elizabeth song on 4/25/25.
//

import SwiftUI

struct PastRecipesView: View {
    let recipes: [RecipeSuggestion]

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

                            if !recipe.ingredientsYouHave.isEmpty {
                                Text("You had:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(recipe.ingredientsYouHave.joined(separator: ", "))
                                    .font(.body)
                            }

                            if !recipe.ingredientsToBuy.isEmpty {
                                Text("Need to buy:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(recipe.ingredientsToBuy.joined(separator: ", "))
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
