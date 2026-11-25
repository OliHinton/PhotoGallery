//
//  PhotoGalleryTests.swift
//  PhotoGalleryTests
//
//  Created by Oli Hinton on 13/11/2026.
//

import Testing
import Foundation
@testable import PhotoGallery


@MainActor
struct ArtworkDecodingTests {

    @Test func decodesArtworksAndSkipsOnesWithoutImages() throws {
        let json = """
        {
            "data": [
                {
                    "id": 27992,
                    "artist_title": "Georges Seurat",
                    "image_id": "2d484387-2509-5e8e-2c43-22f9981972eb",
                    "thumbnail": { "width": 3000, "height": 2016 }
                },
                {
                    "id": 12345,
                    "artist_title": null,
                    "image_id": null,
                    "thumbnail": null
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ArtworksResponse.self, from: json)
        let photos = response.data.compactMap(\.asPhoto)

        #expect(photos.count == 1)  
        let photo = try #require(photos.first)
        #expect(photo.id == "2d484387-2509-5e8e-2c43-22f9981972eb")
        #expect(photo.author == "Georges Seurat")
        #expect(photo.width == 3000)
    }

    @Test func missingArtistBecomesUnknown() throws {
        let artwork = Artwork(id: 1, artistTitle: nil, imageID: "abc", thumbnail: nil)

        let photo = try #require(artwork.asPhoto)

        #expect(photo.author == "Unknown artist")
    }

    @Test func imageURLsUseTheMuseumImageServer() {
        let photo = Photo(id: "abc", author: "Test", width: 3000, height: 2000,
                          url: "", downloadURL: "")

        #expect(photo.thumbnailURL == URL(string: "https://www.artic.edu/iiif/2/abc/full/400,/0/default.jpg"))
        #expect(photo.largeURL() == URL(string: "https://www.artic.edu/iiif/2/abc/full/843,/0/default.jpg"))
    }
}

@MainActor
struct PhotosViewModelTests {

    @Test func firstPageLoads() async {
        let viewModel = PhotosViewModel(service: MockPhotoService(), pageSize: 30)

        await viewModel.loadFirstPage()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.photos.count == 30)
        #expect(viewModel.canLoadMore)
    }

    @Test func scrollingToTheEndLoadsTheNextPage() async throws {
        let viewModel = PhotosViewModel(service: MockPhotoService(), pageSize: 30)
        await viewModel.loadFirstPage()
        let lastPhoto = try #require(viewModel.photos.last)

        await viewModel.loadMoreIfNeeded(currentPhoto: lastPhoto)
        #expect(viewModel.photos.count == 45)   

        let newLast = try #require(viewModel.photos.last)
        await viewModel.loadMoreIfNeeded(currentPhoto: newLast)
        #expect(viewModel.photos.count == 45)
        #expect(!viewModel.canLoadMore)
    }

    @Test func photoAtTheTopDoesNotTriggerNextPage() async throws {
        let viewModel = PhotosViewModel(service: MockPhotoService(), pageSize: 30)
        await viewModel.loadFirstPage()
        let firstPhoto = try #require(viewModel.photos.first)

        await viewModel.loadMoreIfNeeded(currentPhoto: firstPhoto)

        #expect(viewModel.photos.count == 30)
    }

    @Test func failureShowsErrorState() async {
        let viewModel = PhotosViewModel(service: MockPhotoService(shouldFail: true))

        await viewModel.loadFirstPage()

        guard case .failed = viewModel.state else {
            Issue.record("Expected failed state, got \(viewModel.state)")
            return
        }
        #expect(viewModel.photos.isEmpty)
    }
}

actor DownloadCounter {
    private(set) var count = 0
    func increment() { count += 1 }
}

actor FlakyDownloader {
    private(set) var calls = 0
    let data: Data

    init(data: Data) { self.data = data }

    func download() throws -> Data {
        calls += 1
        if calls == 1 { throw URLError(.timedOut) }
        return data
    }
}

@MainActor
struct ImageLoaderTests {

    let url = URL(string: "https://example.com/photo.png")!

    let sampleData = Data([1, 2, 3])

    @Test func simultaneousRequestsDownloadOnlyOnce() async throws {
        let counter = DownloadCounter()
        let sampleData = self.sampleData
        let loader = ImageLoader(fetch: { _ in
            await counter.increment()
            try await Task.sleep(for: .milliseconds(100))
            return sampleData
        })

        async let first = loader.imageData(for: url)
        async let second = loader.imageData(for: url)
        _ = try await (first, second)

        #expect(await counter.count == 1)
    }

    @Test func secondRequestComesFromCache() async throws {
        let counter = DownloadCounter()
        let sampleData = self.sampleData
        let loader = ImageLoader(fetch: { _ in
            await counter.increment()
            return sampleData
        })

        _ = try await loader.imageData(for: url)
        _ = try await loader.imageData(for: url)

        #expect(await counter.count == 1)
    }

    @Test func failedDownloadCanBeRetried() async throws {
        let flaky = FlakyDownloader(data: sampleData)
        let loader = ImageLoader(fetch: { _ in try await flaky.download() })

        await #expect(throws: URLError.self) {
            _ = try await loader.imageData(for: url)
        }

        _ = try await loader.imageData(for: url)

        #expect(await flaky.calls == 2)
    }
}
