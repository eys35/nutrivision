//
//  ImageLoadView.swift
//  Munch
//
//

import SwiftUI

struct ImageLoadViewWrapper: UIViewControllerRepresentable {
    @Binding var isShowingImageLoadView: Bool
    var selectedImage: Image?
    var userData: UserData?
    var macrosVM: MacrosVM

    func makeUIViewController(context: Context) -> UIViewController {
        guard isShowingImageLoadView, let selectedImage = selectedImage else {
            return UIViewController()
        }
        let imageLoadView = ImageLoadView(selectedImage: selectedImage, userData: userData, macrosVM: macrosVM)
        return UIHostingController(rootView: imageLoadView)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}


struct ImageLoadView: View {
    var selectedImage: Image
    var userData: UserData?
    var macrosVM: MacrosVM
    @StateObject private var viewModel = ImageLoadVM()
    @State private var isLoading: Bool = false
    @State private var triggerError: Bool = false
    @State private var buttonShow: Bool = false
    @State private var isPosted: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    
    var body: some View {
        NavigationView {
            
            VStack{
                //view #1: before continuing, has image and continue button
                Image("LogoWithBg") // dummy image
                    .resizable()
                    .frame(width:  300, height: 185)
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical)
                    .scaledToFit()
                Text("Your image is being segmented:")
                    .font(.custom("ChunkFive-Regular", size: 16))
                    .padding(.bottom)
                Text("Press back to select a different image.")
                    .font(.custom("ChunkFive-Regular", size: 13))
                    .padding(.bottom)
                selectedImage
                    .resizable()
                    .cornerRadius(25.0)
                    .scaledToFit()
                    .padding(.bottom)
                    .padding()
                HStack{
                NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                                 Text("BACK")
                                     .padding()
                                     .background(Color(red:0.3686, green:0.4157, blue:0.4980))
                                     .foregroundColor(Color.white)
                                     .cornerRadius(10)
                                     .frame(alignment: .leading)
                             }
                                 
        
                
                    if viewModel.isReady, let userData = userData {
                        NavigationLink(
                            destination: MacrosView(
                                labels: viewModel.detectedIngredients,
                                userData: userData
                            )
                            .navigationBarBackButtonHidden(true)
                        ) {
                            Text("CONTINUE")
                                .padding()
                                .background(Color(red: 0.8745, green: 0.3451, blue: 0.3529))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
            
                }
                Spacer()
                if let userData = userData {
                    VStack(alignment: .center, spacing: 4) {
                        Text("YOUR ALLERGIES:")
                            .font(.custom("ChunkFive-Regular", size: 19))
                            .underline()
                        
                        if userData.isAllergicToPeanuts { Text("• Peanuts") }
                        if userData.isAllergicToDairy { Text("• Dairy") }
                        if userData.isAllergicToShellfish { Text("• Shellfish") }
                        if userData.isAllergicToGluten { Text("• Gluten") }
                        if userData.isAllergicToEggs { Text("• Eggs") }
                        if userData.isAllergicToTreeNuts { Text("• Tree Nuts") }
                        if userData.isAllergicToWheat { Text("• Wheat") }
                        if userData.isAllergicToSoy { Text("• Soy") }
                        if userData.isAllergicToFish { Text("• Fish") }

                        // If no allergies are marked true:
                        if !(userData.isAllergicToPeanuts || userData.isAllergicToDairy || userData.isAllergicToShellfish ||
                              userData.isAllergicToGluten || userData.isAllergicToEggs || userData.isAllergicToTreeNuts ||
                              userData.isAllergicToWheat || userData.isAllergicToSoy || userData.isAllergicToFish) {
                            Text("• None")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }.onAppear {
                if let userData = userData {
                    print("📤 Uploading image for segmentation and analysis...")
                    viewModel.postImage(
                        img: selectedImage,
                        userData: userData, macrosVM: macrosVM,
                        purpose: "segment_and_analyze"
                    )
                    isLoading = true
                } else {
                    print("⚠️ Warning: userData was nil on ImageLoadView.onAppear")
                }
            }
        }
    }
//    
//    
//    struct ImageLoadView_Previews: PreviewProvider {
//        static var previews: some View {
//            ImageLoadView(selectedImage: Image("Logo"), macrosVM: MacrosVM())
//        }
//    }
}

extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
 // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

struct ImageLoadView_Previews: PreviewProvider {
      static var previews: some View {
          ImageLoadView(selectedImage: Image("AppIcon"),
                        userData: UserData(
                            age: "20", weight: "130", height: "170", gender: "Female",
                            isAllergicToPeanuts: false, isAllergicToDairy: false,
                            isAllergicToShellfish: false, isAllergicToGluten: false,
                            isAllergicToEggs: false, isAllergicToTreeNuts: false,
                            isAllergicToWheat: false, isAllergicToSoy: false, isAllergicToFish: false
                        ), macrosVM: MacrosVM())
      }
  }
