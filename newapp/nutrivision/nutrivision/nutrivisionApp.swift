//
//  nutrivisionApp.swift
//  nutrivision
//
//  Created by elizabeth song on 4/24/25.
//

import SwiftUI

@main
struct nutrivisionApp: App {
    init() {
            let attrs = [
                NSAttributedString.Key.font: UIFont(name: "ChunkFive-Regular", size: 28)!
            ]
            UINavigationBar.appearance().titleTextAttributes = attrs
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.white)
                .foregroundColor(.black)
                .tint(.accentColor)
                .preferredColorScheme(.light)
//                .font(.custom("ChunkFive-Regular", size: 18))
        }
    }
}
