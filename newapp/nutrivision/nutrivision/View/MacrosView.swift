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
                    .frame(width: 150, height: 37.5)
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .padding(.top, 80)
                    .padding(.vertical)
                
                Spacer()

                Text("Loading...")
                    .font(.title)
                    .padding(.bottom, 64)
                    
                HStack {
                    Group {
                        Image("Apple")
                            .resizable()
                            .frame(width: 40, height: 45, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom, 64)
                            .scaleEffect(isBouncing ? 1.2 : 1.0)
                            .onAppear() {
                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    isBouncing.toggle()
                                }
                            }
                        
                        Image("Egg")
                            .resizable()
                            .frame(width: 40, height: 45, alignment: .center)
                            .padding(.horizontal)
                            .padding(.bottom, 64)
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(isBouncing ? 1.2 : 1.0)
                            .onAppear() {
                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    isBouncing.toggle()
                                }
                            }
                        
                        Image("Sandwich")
                            .resizable()
                            .frame(width: 40, height: 45)
                            .padding(.horizontal)
                            .padding(.bottom, 64)
                            .aspectRatio(contentMode: .fit)
                            .frame(alignment: Alignment.trailing)
                            .scaleEffect(isBouncing ? 1.2 : 1.0)
                            .onAppear() {
                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    isBouncing.toggle()
                                }
                            }
                    }
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
                        .navigationBarBackButtonHidden(false)
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

