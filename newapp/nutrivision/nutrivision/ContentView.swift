//
//  ContentView.swift
//  nutrivision
//
//  Created by elizabeth song on 4/24/25.
//



import SwiftUI
import Combine


struct UserData {
    var age: String
    var weight: String
    var height: String
    var gender: String
    
    var isAllergicToPeanuts: Bool
    var isAllergicToDairy: Bool
    var isAllergicToShellfish: Bool
    var isAllergicToGluten: Bool
    var isAllergicToEggs: Bool
    var isAllergicToTreeNuts: Bool
    var isAllergicToWheat: Bool
    var isAllergicToSoy: Bool
    var isAllergicToFish: Bool
}

    struct ContentView: View {
        @State private var path = NavigationPath()
        @State private var showPastRecipes = false
        @State private var showView : Bool = false
        @State private var showImagePicker: Bool = false
        @State private var image: Image? = nil
        @State private var showCamera: Bool = false
        @State private var showImageLoad: Bool = false
        @State private var selectedImage: Image? = nil
        @State private var isShowingPopup = false
        @State private var isImageLoadViewActive = false
        @State private var isShowingImageLoadView = false
        @State private var ageInput: String = ""
        @State private var weightInput: String = ""
        @State private var heightInput: String = ""
        @State private var gender: String = "Male"
        @State private var userData: UserData? = nil
        @State private var isAllergicToPeanuts = false
        @State private var isAllergicToDairy = false
        @State private var isAllergicToShellfish = false
        @State private var isAllergicToGluten = false
        @State private var isAllergicToEggs = false
        @State private var isAllergicToTreeNuts = false
        @State private var isAllergicToWheat = false
        @State private var isAllergicToSoy = false
        @State private var isAllergicToFish = false
        
        @State private var action: Int? = 0
         
        
        var body: some View {
            NavigationStack {
                VStack {
                        
                    
                    Spacer ()
                    Image("LogoWithBg")
                        .resizable()
                        .frame(width: 300, height: 185)
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .padding(.vertical)
                        .padding(.bottom)
                    Text("Welcome!")
                        .font(.custom("ChunkFive-Regular", size: 30))
                        //.foregroundColor(Color(red:0.3686, green:0.4157, blue:0.4980))
                    
                    Button("Upload from Gallery   ") {
                        if self.userData == nil {
                            self.userData = UserData(
                                age: "N/A", weight: "N/A", height: "N/A", gender: "Unspecified",
                                isAllergicToPeanuts: false, isAllergicToDairy: false, isAllergicToShellfish: false,
                                isAllergicToGluten: false, isAllergicToEggs: false, isAllergicToTreeNuts: false,
                                isAllergicToWheat: false, isAllergicToSoy: false, isAllergicToFish: false
                            )
                        }
                        self.showImagePicker = true
                        self.showView = false
                        action = 1
                    }.padding()
                        .background(Color(red:0.44313725490196076, green:0.6745098039215687, blue:0.6039215686274509 ))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .sheet(isPresented: self.$showImagePicker) {
                            PhotoCaptureView(showImagePicker: self.$showImagePicker, selectedImage: self.$selectedImage).navigationBarBackButtonHidden(true)
                        }
                    
                    
                    
                    
                    Button("Take A Photo               ") {
                        self.showCamera.toggle()
                        //will change this to camera opening
                    }.padding()
                        .background(Color(red: 0.8745098039215686, green: 0.34509803921568627, blue: 0.35294117647058826))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .sheet(isPresented: self.$showCamera) {
                            CameraView(selectedImage: self.$selectedImage, isShowingPopup: self.$isShowingPopup)
                        }
                        .navigationDestination(isPresented: $isShowingImageLoadView) {
                            ImageLoadViewWrapper(isShowingImageLoadView: $isShowingImageLoadView, selectedImage: self.selectedImage, macrosVM: MacrosVM())
                        }
                    if let selectedImage = self.selectedImage {
                        NavigationLink(destination: ImageLoadView(selectedImage: selectedImage, userData: userData, macrosVM: MacrosVM()).navigationBarBackButtonHidden(true)) {
                                               Image("next")
                                                   .resizable()
                                                   .padding(.top)
                                                   .padding(.top)
                                                   .frame(width: 130, height: 90)
                                                   .scaledToFit()
                                               
                                           }
                    }
                    Spacer()
                    
                HStack {
                    Button(action: {
                        self.showView.toggle()
                    }) {
                        Text("Enter User Details")
                    }
                    .padding()
                    .background(Color(red:0.3686, green:0.4157, blue:0.4980))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                    .sheet(isPresented: self.$showView) {
                        ScrollView {
                            VStack(spacing: 20) {
                                Spacer(minLength: 10)
                                
                                Image("Profile")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 180, height: 180)
                                    .clipShape(Circle())
                                    .padding(.bottom, 5)

                                Text("User Details")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)

                                Text("Select any allergies:")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    Toggle("Peanuts", isOn: $isAllergicToPeanuts)
                                    Toggle("Dairy", isOn: $isAllergicToDairy)
                                    Toggle("Shellfish", isOn: $isAllergicToShellfish)
                                    Toggle("Gluten", isOn: $isAllergicToGluten)
                                    Toggle("Eggs", isOn: $isAllergicToEggs)
                                    Toggle("Tree Nuts", isOn: $isAllergicToTreeNuts)
                                    Toggle("Wheat", isOn: $isAllergicToWheat)
                                    Toggle("Soy", isOn: $isAllergicToSoy)
                                    Toggle("Fish", isOn: $isAllergicToFish)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .teal))
                                .frame(maxWidth: .infinity)

                                Text("Select Gender:")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)

                                HStack(spacing: 20) {
                                    Button("Male") {
                                        self.gender = "Male"
                                        UserDefaults.standard.set("Male", forKey: "Sex")
                                    }
                                    .padding()
                                    .background(gender == "Male" ? Color(red:0.443, green:0.674, blue:0.604) : Color(red:0.3686, green:0.4157, blue:0.4980))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)

                                    Button("Female") {
                                        self.gender = "Female"
                                        UserDefaults.standard.set("Female", forKey: "Sex")
                                    }
                                    .padding()
                                    .background(gender == "Female" ? Color(red:0.443, green:0.674, blue:0.604) : Color(red:0.3686, green:0.4157, blue:0.4980))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }

                                Button("Close") {
                                    self.userData = UserData(
                                        age: ageInput,
                                        weight: weightInput,
                                        height: heightInput,
                                        gender: gender,
                                        isAllergicToPeanuts: isAllergicToPeanuts,
                                        isAllergicToDairy: isAllergicToDairy,
                                        isAllergicToShellfish: isAllergicToShellfish,
                                        isAllergicToGluten: isAllergicToGluten,
                                        isAllergicToEggs: isAllergicToEggs,
                                        isAllergicToTreeNuts: isAllergicToTreeNuts,
                                        isAllergicToWheat: isAllergicToWheat,
                                        isAllergicToSoy: isAllergicToSoy,
                                        isAllergicToFish: isAllergicToFish
                                    )
                                    self.showView.toggle()
                                }
                                .padding(.top, 10)
                                .padding(.bottom)
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.875, green: 0.345, blue: 0.353))
                                .foregroundColor(.white)
                                .cornerRadius(10)

                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal)
                        
                        }
                        
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showPastRecipes = true
                            }) {
                                Image(systemName: "clock.arrow.circlepath") // ⏳ history icon
                                    .imageScale(.large)
                            }
                        }
                    }
                    .sheet(isPresented: $showPastRecipes) {
                        PastRecipesView()
                    }
                }
                    
            }
                
        }
    }
}
    
    extension Color {
        func toHex() -> String? {
            let uic = UIColor(self)
            guard let components = uic.cgColor.components else {
                return nil
            }
            let r = components.count >= 1 ? Float(components[0]) : 0
            let g = components.count >= 2 ? Float(components[1]) : r
            let b = components.count >= 3 ? Float(components[2]) : r
            var a = Float(1.0)
            
            if components.count >= 4 {
                a = Float(components[3])
            }
            
            if a != Float(1.0) {
                return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
            } else {
                return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
            }
        }
    }
    
#Preview("Preview Test") {
    VStack {
        ContentView()
    }
}
