//
//  RootView.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Gallery", systemImage: "photo.on.rectangle") {
                GalleryView()
            }

            Tab("Favourites", systemImage: "heart") {
                FavouritesView()
            }
        }
    }
}

#Preview {
    RootView()
}
