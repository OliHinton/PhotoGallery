//
//  PhotoGalleryApp.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import SwiftUI
import SwiftData

@main
struct PhotoGalleryApp: App {
    let container: ModelContainer
    @State private var photosViewModel = PhotosViewModel()
    @State private var favouritesViewModel: FavouritesViewModel

    init() {
        do {
            let container = try ModelContainer(for: FavouritePhoto.self)
            self.container = container
            _favouritesViewModel = State(
                initialValue: FavouritesViewModel(modelContext: container.mainContext)
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(photosViewModel)
                .environment(favouritesViewModel)
        }
        .modelContainer(container)
    }
}

#Preview {
    RootView()
        .environment(PhotosViewModel(service: MockPhotoService()))
        .modelContainer(for: FavouritePhoto.self, inMemory: true)
}
