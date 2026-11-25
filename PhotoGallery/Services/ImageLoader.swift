//
//  ImageLoader.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import Foundation

actor ImageLoader {
    static let shared = ImageLoader()

    typealias Fetch = @Sendable (URL) async throws -> Data 

    private let fetch: Fetch
    private var cache: [URL: Data] = [:]
    private var inProgress: [URL: Task<Data, Error>] = [:]

    init(fetch: @escaping Fetch = ImageLoader.networkFetch) {
        self.fetch = fetch
    }

    func imageData(for url: URL) async throws -> Data {
        if let cached = cache[url] {
            return cached
        }

        if let existing = inProgress[url] {
            return try await existing.value
        }

        let fetch = self.fetch
        let task = Task { try await fetch(url) }

        inProgress[url] = task
      
        do {
            let data = try await task.value
            cache[url] = data
            inProgress[url] = nil
            return data
        } catch {
            inProgress[url] = nil
            throw error
        }
    }

    func clearCache() {
        cache.removeAll()
    }

    static let networkFetch: Fetch = { url in
        var request = URLRequest(url: url)
        
        request.setValue("Mozilla/5.0 (iPhone) PhotoGallery", forHTTPHeaderField: "User-Agent")
        request.setValue("PhotoGallery portfolio app", forHTTPHeaderField: "AIC-User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
