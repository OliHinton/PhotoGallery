//
//  ApiError.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed
    case network(URLError)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The request couldn't be created."
        case .invalidResponse:
            "The server sent an unexpected response."
        case .httpStatus(let code):
            "The server returned an error (\(code)). Please try again later."
        case .decodingFailed:
            "We couldn't read the photos from the server."
        case .network(let error):
            error.code == .notConnectedToInternet
                ? "You appear to be offline. Check your connection and try again."
                : "A network error occurred. Please try again."
        }
    }
}
