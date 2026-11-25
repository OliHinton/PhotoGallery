//
//  Artwork.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 15/11/2026.
//

import Foundation

struct ArtworksResponse: Codable {
    let data: [Artwork]
}

struct Artwork: Codable {
    let id: Int
    let artistTitle: String?
    let imageID: String?
    let thumbnail: Thumbnail?
    
    struct Thumbnail: Codable {
        let width: Int?
        let height: Int?
    }
    
    enum CodingKeys: String, CodingKey {
        case id, thumbnail
        case artistTitle = "artist_title"
        case imageID = "image_id"
    }
    
    var asPhoto: Photo? {
        guard let imageID else { return nil }

        return Photo(
            id: imageID,
            author: artistTitle ?? "Unknown artist",
            width: thumbnail?.width ?? 1,
            height: thumbnail?.height ?? 1,
            url: "https://www.artic.edu/artworks/\(id)",
            downloadURL: "\(Photo.imageBaseURL)/\(imageID)/full/843,/0/default.jpg"
        )
    }
}
