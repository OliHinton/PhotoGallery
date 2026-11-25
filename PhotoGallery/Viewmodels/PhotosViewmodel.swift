//
//  PhotosViewmodel.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import Foundation
import Observation

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}

@MainActor
@Observable
final class PhotosViewModel {
    private(set) var photos: [Photo] = []
    private(set) var state: LoadState = .idle
    private(set) var isLoadingMore = false
    private(set) var canLoadMore = true

    private var nextPage = 1
    private let pageSize: Int
    private let service: PhotoServiceProtocol

    init(service: PhotoServiceProtocol? = nil, pageSize: Int = 30) {
        self.service = service ?? PhotoService()
        self.pageSize = pageSize
    }

    func loadFirstPage() async {
        
        if photos.isEmpty {
            
            state = .loading
        }

        do {
            
            let firstPage = try await service.fetchPhotos(page: 1, limit: pageSize)
            
            photos = firstPage
            
            nextPage = 2
            
            canLoadMore = firstPage.count == pageSize
            
            state = .loaded
            
        } catch {
            
            if photos.isEmpty {
                
                state = .failed(Self.message(for: error))
            }
        }
    }

    func loadMoreIfNeeded(currentPhoto: Photo) async {
        
        guard state == .loaded, canLoadMore, !isLoadingMore else { return }

        let thresholdIndex = max(photos.count - 6, 0)
        
        guard let index = photos.firstIndex(where: { $0.id == currentPhoto.id }),
              
        index >= thresholdIndex else { return }

        isLoadingMore = true
        
        defer { isLoadingMore = false }

        do {
            
            let page = try await service.fetchPhotos(page: nextPage, limit: pageSize)
            
            let existingIDs = Set(photos.map(\.id))
            
            photos.append(contentsOf: page.filter { !existingIDs.contains($0.id) })
            
            nextPage += 1
            
            canLoadMore = page.count == pageSize
            
        } catch {

            return
        }
    }

    private static func message(for error: Error) -> String {
        
        (error as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
    }
}
