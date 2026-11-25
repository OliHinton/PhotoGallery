//
//  Photo.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import Foundation

struct Photo: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadURL: String
    
    static let imageBaseURL = "https://www.artic.edu/iiif/2"

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }
    
    var thumbnailURL: URL? {
            URL(string: "\(Self.imageBaseURL)/\(id)/full/400,/0/default.jpg")
        }
    
    
    func largeURL(width targetWidth: Int = 843) -> URL? {
            URL(string: "\(Self.imageBaseURL)/\(id)/full/\(targetWidth),/0/default.jpg")
        }
    
    var aspectRatio: Double {
        Double(width) / Double(max(height, 1))
    }

    var sizeDescription: String {
        "\(width) × \(height)"
    }
}

extension Photo {
    static let sample = Photo(
        id: "sample-image",
        author: "Claude Monet",
        width: 3000,
        height: 2000,
        url: "https://www.artic.edu/artworks/16568",
        downloadURL: "\(imageBaseURL)/sample-image/full/843,/0/default.jpg"
    )

    static func makeSamples(count: Int) -> [Photo] {
        (0..<count).map { index in
            Photo(
                id: "sample-\(index)",
                author: "Artist \(index)",
                width: 3000,
                height: 2000,
                url: "https://example.com/\(index)",
                downloadURL: "\(imageBaseURL)/sample-\(index)/full/843,/0/default.jpg"
            )
        }
    }
}

