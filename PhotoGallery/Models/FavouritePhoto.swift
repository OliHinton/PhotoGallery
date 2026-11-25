//
//  FavouritePhoto.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import Foundation
import SwiftData

@Model
final class FavouritePhoto {
    @Attribute(.unique) var photoID: String
    var author: String
    var width: Int
    var height: Int
    var downloadURL: String
    var dateAdded: Date

    init(photo: Photo) {
        self.photoID = photo.id
        self.author = photo.author
        self.width = photo.width
        self.height = photo.height
        self.downloadURL = photo.downloadURL
        self.dateAdded = .now
    }

    var asPhoto: Photo {
        Photo(
            id: photoID,
            author: author,
            width: width,
            height: height,
            url: "",
            downloadURL: downloadURL
        )
    }
}
