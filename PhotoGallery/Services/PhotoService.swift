//
//  PhotoService.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import Foundation

protocol PhotoServiceProtocol: Sendable {
    func fetchPhotos(page: Int, limit: Int) async throws -> [Photo]
}

struct PhotoService: PhotoServiceProtocol {
    func fetchPhotos(page: Int, limit: Int) async throws -> [Photo] {
        var components = URLComponents(string: "https://api.artic.edu/api/v1/artworks")
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit)),
         
            URLQueryItem(name: "fields", value: "id,artist_title,image_id,thumbnail")]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.setValue("PhotoGallery portfolio app", forHTTPHeaderField: "AIC-User-Agent")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError {
            throw APIError.network(urlError)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        do {
           let decoded = try JSONDecoder().decode(ArtworksResponse.self, from: data)
            
            return decoded.data.compactMap(\.asPhoto)
        } catch {
            throw APIError.decodingFailed
        }
    }
}

struct MockPhotoService: PhotoServiceProtocol {
    var allPhotos: [Photo] = Photo.makeSamples(count: 45)
    var shouldFail = false

    func fetchPhotos(page: Int, limit: Int) async throws -> [Photo] {
        if shouldFail {
            throw APIError.network(URLError(.notConnectedToInternet))
        }

        let start = (page - 1) * limit
        guard start < allPhotos.count else { return [] }
        let end = min(start + limit, allPhotos.count)
        return Array(allPhotos[start..<end])
    }
}
