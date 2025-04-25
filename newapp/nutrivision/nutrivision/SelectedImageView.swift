//
//  SelectedImageView.swift
//  nutrivision
//
//  Created by elizabeth song on 4/24/25.
//

import SwiftUI

struct SelectedImageView: View {
    var selectedImage: Image

    var body: some View {
        VStack {
            selectedImage
                .resizable()
                .scaledToFit()
                .padding()

            // You can add more UI components or modify the layout as needed
        }
    }
}
