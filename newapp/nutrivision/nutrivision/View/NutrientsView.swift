//
//  NutrientsView.swift
//  Munch
//
//
import SwiftUI
import Charts

import SwiftUI

struct RecipeSuggestion: Codable {
    let name: String
    let ingredients: [String]
    let userAllergies: [String]
    let instructions: [String]
    let difficulty: String
    let preparationTime: Int
    let servings: Int
}

struct NutrientsView: View {
    let recipe: RecipeSuggestion
    let food: String
    @State private var goHome = false
    @AppStorage("savedRecipes") private var savedRecipesData: Data = Data()
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(recipe.name)
                        .font(.custom("ChunkFive-Regular", size: 34))
                        .bold()
                        .padding(.bottom)
                    Group {
                        Text("🛒 Ingredients")
                            .font(.custom("ChunkFive-Regular", size: 22))
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            Text("• \(ingredient)").font(.custom("ChunkFive-Regular", size: 16))
                        }
                    }
                    Group {
                        Text("⚠️ Allergies to Avoid")
                            .font(.custom("ChunkFive-Regular", size: 22))
                        if recipe.userAllergies.isEmpty {
                            Text("• None 🎉").font(.custom("ChunkFive-Regular", size: 16))
                        } else {
                            ForEach(recipe.userAllergies, id: \.self) { allergy in
                                Text("• \(allergy)").font(.custom("ChunkFive-Regular", size: 16))
                            }
                        }
                    }

                    Group {
                        Text("🧑‍🍳 Instructions")
                            .font(.custom("ChunkFive-Regular", size: 22))
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                            Text("\(index + 1). \(step)").font(.custom("ChunkFive-Regular", size: 16))
                        }
                    }

                    Group {
                        Text("📋 Summary")
                            .font(.custom("ChunkFive-Regular", size: 22))
                        Text("Difficulty: \(recipe.difficulty)").font(.custom("ChunkFive-Regular", size: 16))
                        Text("Preparation Time: \(recipe.preparationTime) minutes").font(.custom("ChunkFive-Regular", size: 16))
                        Text("Servings: \(recipe.servings)").font(.custom("ChunkFive-Regular", size: 16))
                    }
                    Button(action: saveCurrentRecipe) {
                        Text("💾 Save Recipe")
                            .font(.custom("ChunkFive-Regular", size: 16))
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        goHome = true
                    }) {
                        Label("Home", systemImage: "house")
                    }
                }
            }
            .navigationDestination(isPresented: $goHome) {
                ContentView().navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func saveCurrentRecipe() {
        var saved: [RecipeSuggestion] = []
        if let decoded = try? JSONDecoder().decode([RecipeSuggestion].self, from: savedRecipesData) {
            saved = decoded
        }
        if !saved.contains(where: { $0.name == recipe.name }) {
            saved.append(recipe)
            if let encoded = try? JSONEncoder().encode(saved) {
                savedRecipesData = encoded
            }
        }
    }
    
    struct NutrientsView_Previews: PreviewProvider {
        static var previews: some View {
            NutrientsView(recipe: RecipeSuggestion(
                name: "Garlic Shrimp Pasta",
                ingredients: ["Shrimp", "Garlic", "Olive Oil"],
                userAllergies: ["Dairy", "Gluten"],
                instructions: ["Boil pasta", "Cook shrimp", "Mix ingredients"],
                difficulty: "Easy",
                preparationTime: 30,
                servings: 4
            ), food: "Shrimp")
        }
    }
    //
    //struct NutrientsView: View {
    //
    //
    //    let food: String
    //    // this is pretty repetitive
    //    var ageFloat: Double {
    //        let age_string = UserDefaults.standard.string(forKey: "Age") ?? "0.0"
    //        return Double(age_string) ?? 0.0
    //    }
    //    var weightFloat: Double {
    //        let weight_string = UserDefaults.standard.string(forKey: "Weight") ?? "0.0"
    //        return Double(weight_string) ?? 0.0
    //    }
    //    var heightFloat: Double {
    //        let height_string = UserDefaults.standard.string(forKey: "Height") ?? "0.0"
    //        return Double(height_string) ?? 0.0
    //    }
    //
    //    // harris-benedict equation??
    //    // we can change the equations later if these are wrong
    //    let gender = UserDefaults.standard.string(forKey: "Sex") ?? "Male"
    //
    //    var protein_count: Double {
    //        if gender == "Male" {
    //            return 0.8 * ( weightFloat / 2.2)
    //        } else {
    //            return 0.8 * ( weightFloat / 2.2)
    //        }
    //    }
    //
    //
    //    var fat_count: Double {
    //        if gender == "Male" {
    //            return 0.3 * (66.47 + (6.24 * weightFloat) + (12.7 * heightFloat) - (6.75 * ageFloat))
    //        } else {
    //            return 0.3 *  (65.51 + (4.35 * weightFloat) + (4.7 * heightFloat) - (4.7 * ageFloat))
    //        }
    //    }
    //
    //
    //    var carb_count: Double {
    //        if gender == "Male" {
    //            return 0.45 * (66.47 + (6.24 * weightFloat) + (12.7 * heightFloat) - (6.75 * ageFloat))
    //        } else {
    //            return 0.45 * (65.51 + (4.35 * weightFloat) + (4.7 * heightFloat) - (4.7 * ageFloat))
    //        }
    //    }
    //
    //    @StateObject private var viewModel = NutrientsVM()
    //
    //    var body: some View {
    //        VStack{
    //            Text(food.replacingOccurrences(of: "%20", with: " ").uppercased())
    //                .font(.title)
    //                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
    //
    //            if #available(iOS 16.0, *) {
    //                Text("Macronutrient vs % of Daily Value")
    //                    .padding(.top)
    //                Chart {
    //                    BarMark(
    //                        x: .value("Macro Category", "Carbs"),
    //                        y: .value("% DV", viewModel.nutrients.carbs/carb_count*100)
    //                    ).foregroundStyle(Color(red: 0.8745098039215686, green: 0.34509803921568627, blue: 0.35294117647058826))
    //                    BarMark(
    //                        x: .value("Macro Category", "Fats"),
    //                        y: .value("% DV", viewModel.nutrients.fats/fat_count*100)
    //                    ).foregroundStyle(Color(red:0.44313725490196076, green:0.6745098039215687, blue:0.6039215686274509 ))
    //                    BarMark(
    //                        x: .value("Macro Category", "Protein"),
    //                        y: .value("% DV", viewModel.nutrients.protein/protein_count*100)
    //                    ).foregroundStyle(Color.yellow)
    //
    //                }.padding(.top)
    //                    .frame(width: 300, height: 300)
    //                    .chartXAxisLabel("Macronutrient Name", alignment: .center)
    //                    .chartYAxisLabel("% of Daily Value")
    //                    .chartYAxis {
    //                        AxisMarks(
    //                            //values: [0, 50, 100]
    //                        ) {
    //                            AxisValueLabel(format: Decimal.FormatStyle.Percent.percent.scale(1))
    //                        }
    //
    //                        AxisMarks(
    ////                            values: [0, 25, 50, 75, 100]
    //                        ) {
    //                            AxisGridLine()
    //                        }
    //
    //                    }.onLoad(perform:
    //                                { () in
    //                        viewModel.loadNutrients(food: food)
    //                    })
    //            } else {
    //                Text("Charts only available in iOS 16.0+")
    //            }
    //
    //            // actually pass in values
    //            let list_data = [["Carbs (g)", String(Int(carb_count))], ["Fats (g)", String(Int(fat_count))], ["Protein (g)", String(Int(protein_count))]]
    //            List(list_data, id: \.self) { item in
    //                nutrientInfoRow(metric: item[0], amount: item[1])
    //            }
    //        }.padding(.top, 50)
    //    }
    //    private func nutrientInfoRow(metric:String, amount:String)  -> some View {
    //        HStack{
    //            Text(metric)
    //                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
    //            Spacer()
    //            Text(amount)
    //                .fontWeight(.medium)
    //                .italic()
    //        }
    //    }
    //}
    //
//    struct NutrientsView_Previews: PreviewProvider {
//        static var previews: some View {
//            NutrientsView(food: "Churros")
//        }
//    }
}
