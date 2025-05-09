//
//  Untitled.swift
//  nutrivision
//
//  Created by elizabeth song on 5/8/25.
//


import SwiftUI
//
//  Untitled.swift
//  nutrivision
//
//  Created by elizabeth song on 5/8/25.
//




import UIKit

func printAllFonts() {
    for family in UIFont.familyNames.sorted() {
        print("Font family: \(family)")
        for name in UIFont.fontNames(forFamilyName: family) {
            print("  - \(name)")
        }
    }
}

// Call this manually from somewhere like AppDelegate or SceneDelegate if needed

struct TestView: View {
    var body: some View {
        VStack {
            Text("Font List Printed to Console")
        }
        .onAppear {
            printAllFonts()
        }
    }
}



struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
