//
//  PastRecipesView.swift
//  nutrivision
//
//  Created by elizabeth song on 4/25/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: RecipeSuggestion

    var body: some View {
        ScrollView {
            Spacer()
            Spacer()
            Spacer()
            Spacer()
            
            Text("Your recipe:")
                .font(.custom("ChunkFive-Regular", size: 20))
                .padding(.horizontal, 35)
            Spacer()
            Spacer()
            
            VStack(alignment: .leading, spacing: 20) {
                Text(recipe.name)
                    .font(.custom("ChunkFive-Regular", size: 30))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .bold()
                    .padding(.bottom)
                
                Group {
                    Text("🛒 Ingredients")
                        .font(.custom("ChunkFive-Regular", size: 22))
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)").font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 40)
                Spacer()
                
                Group {
                    Text("⚠️ Allergies Avoided")
                        .font(.custom("ChunkFive-Regular", size: 22))
                        .frame(maxWidth: .infinity, alignment: .center)
                    if recipe.userAllergies.isEmpty {
                        Text("• None 🎉")
                            .font(.system(size: 14))
                    } else {
                        ForEach(recipe.userAllergies, id: \.self) { allergy in
                            Text("• \(allergy)")
                                .font(.system(size: 14))
                        }
                    }
                }
                .padding(.horizontal, 40)
                Spacer()
                
                Group {
                    Text("🧑‍🍳 Instructions")
                        .font(.custom("ChunkFive-Regular", size: 22))
                        .frame(maxWidth: .infinity, alignment: .center)
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal, 40)
                Spacer()
            }
            .padding(.top)
        }
    }
}

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
                    Text("Nothing here")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(recipes, id: \.name) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            Text(recipe.name)
                                .font(.custom("ChunkFive-Regular", size: 18))
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Spacer(minLength: 8)
                        Text("Past Recipes")
                            .font(.custom("ChunkFive-Regular", size: 35))
                    }
                }
            }
        }
    }
}

struct PastRecipesView_Previews: PreviewProvider {
    static var previews: some View {
        PastRecipesView()
    }
}
