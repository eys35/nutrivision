//
//  MacrosView.swift
//  Munch
//
//

import SwiftUI

struct MacrosView: View {
    let labels: [String]
    let userData: UserData
    
    @StateObject private var viewModel = MacrosVM()
    @State private var isBouncing = false
    @State private var isReady = false
  //  @State private var showMacrosView: Bool = false;

    var body: some View {
        ZStack(alignment: .center) {

            VStack{
                
                Image("LogoWithBg")
                    .resizable()
                    .frame(width: 300, height: 185)
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 80)
                    .padding(.vertical)
                
                Spacer()

                Text("Loading...")
                    .font(.custom("ChunkFive-Regular", size: 28))
                    .padding(.bottom, 64)
                    
                if !labels.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🧪 Detected Ingredients:")
                            .font(.custom("ChunkFive-Regular", size: 20))
                            .padding(.bottom, 4)
                        ForEach(labels, id: \.self) { label in
                            Text("• \(label)")
                                .font(.custom("ChunkFive-Regular", size: 16))
                                .scaleEffect(isBouncing ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isBouncing)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }

//
//
//
//                }
                Spacer()
                if (viewModel.isReady) {
                    NavigationLink(
                        destination: NutrientsView(
                            recipe: viewModel.recipeSuggestion,
                            food: viewModel.food_name
                        )
                        .navigationBarBackButtonHidden(true)
                    ) {
                        Text("CONTINUE")
                            .padding()
                            .background(Color(red: 0.8745098039215686, green: 0.34509803921568627, blue: 0.35294117647058826))
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                }
            }.onLoad {
                viewModel.runModel(labels: labels, userData: userData)
                isBouncing = true
            }
            
        }
      
       
    }
}
struct MacrosView_Previews: PreviewProvider {
    static var previews: some View {
        MacrosView(
            labels: ["apple", "egg", "bread"],
            userData: UserData(
                age: "25",
                weight: "140",
                height: "170",
                gender: "Female",
                isAllergicToPeanuts: false,
                isAllergicToDairy: true,
                isAllergicToShellfish: false,
                isAllergicToGluten: false,
                isAllergicToEggs: false,
                isAllergicToTreeNuts: false,
                isAllergicToWheat: false,
                isAllergicToSoy: false,
                isAllergicToFish: false
            )
        )
    }
}
