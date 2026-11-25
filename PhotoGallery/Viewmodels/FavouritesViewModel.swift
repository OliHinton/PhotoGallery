//
//  FavouritesViewModel.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 15/11/2026.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
class FavouritesViewModel {
    private(set) var favourites: [FavouritePhoto] = []
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchFavourites()
    }
    
    func fetchFavourites() {
          let descriptor = FetchDescriptor<FavouritePhoto>(
              sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
          )
          favourites = (try? modelContext.fetch(descriptor)) ?? []
      }
    
    func isFavourite(_ photo: Photo) -> Bool {
         favourites.contains { $0.photoID == photo.id }
     }
    
    func toggleFavourite(_ photo: Photo) {
        if let existing = favourites.first(where: { $0.photoID == photo.id }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavouritePhoto(photo: photo))
        }
        fetchFavourites()
    }
}

