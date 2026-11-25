//
//  GalleryView.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @Environment(PhotosViewModel.self) private var viewModel
    @AppStorage("gridColumns") private var columnCount = 3
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Gallery")
                .navigationDestination(for: Photo.self) { photo in
                    PhotoDetailView(photo: photo)
                        .navigationTransition(.zoom(sourceID: photo.id, in: namespace))
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(
                            columnCount == 3 ? "Bigger photos" : "Smaller photos",
                            systemImage: columnCount == 3 ? "square.grid.2x2" : "square.grid.3x3"
                        ) {
                            withAnimation {
                                columnCount = columnCount == 3 ? 2 : 3
                            }
                        }
                    }
                }
                .task {
                    if viewModel.state == .idle {
                        await viewModel.loadFirstPage()
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading photos…")

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't load photos", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    Task { await viewModel.loadFirstPage() }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityHint("Reloads the gallery")
            }

        case .loaded:
            photoGrid
        }
    }

    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columnCount),
                spacing: 4
            ) {
                ForEach(viewModel.photos) { photo in
                    PhotoGridCell(photo: photo, namespace: namespace)
                        .task {
                            await viewModel.loadMoreIfNeeded(currentPhoto: photo)
                        }
                }
            }
            .padding(.horizontal, 4)

            if viewModel.isLoadingMore {
                ProgressView()
                    .padding()
            }
        }
        .refreshable {
            await viewModel.loadFirstPage()
        }
    }
}

#Preview("Loaded") {
    GalleryView()
        .environment(PhotosViewModel(service: MockPhotoService()))
        .modelContainer(for: FavouritePhoto.self, inMemory: true)
}

#Preview("Error") {
    GalleryView()
        .environment(PhotosViewModel(service: MockPhotoService(shouldFail: true)))
        .modelContainer(for: FavouritePhoto.self, inMemory: true)
}

