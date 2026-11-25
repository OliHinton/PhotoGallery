//
//  FavouritesView.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import SwiftUI
import SwiftData

struct FavouritesView: View {
    @Environment(FavouritesViewModel.self) private var viewModel
    @AppStorage("gridColumns") private var columnCount = 3
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favourites.isEmpty {
                    ContentUnavailableView(
                        "No Favourites Yet",
                        systemImage: "heart",
                        description: Text("Tap the heart on a photo to save it here.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columnCount),
                            spacing: 4
                        ) {
                            ForEach(viewModel.favourites) { favourite in
                                PhotoGridCell(photo: favourite.asPhoto, namespace: namespace)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
            .navigationTitle("Favourites")
            .navigationDestination(for: Photo.self) { photo in
                PhotoDetailView(photo: photo)
                    .navigationTransition(.zoom(sourceID: photo.id, in: namespace))
            }
        }
    }
}

#Preview("Empty") {
    FavouritesView()
        .modelContainer(for: FavouritePhoto.self, inMemory: true)
}
