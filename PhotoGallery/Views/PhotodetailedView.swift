//
//  PhotodetailedView.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import SwiftUI
import SwiftData

struct PhotoDetailView: View {
    let photo: Photo

    @Environment(FavouritesViewModel.self) private var viewModel
    @State private var zoom: CGFloat = 1

    private var isFavourite: Bool {
        viewModel.isFavourite(photo)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CachedImage(url: photo.largeURL(), contentMode: .fit)
                    .aspectRatio(photo.aspectRatio, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .scaleEffect(zoom)
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                zoom = min(max(value.magnification, 1), 4)
                            }
                            .onEnded { _ in
                                withAnimation(.spring) { zoom = 1 }
                            }
                    )
                    .accessibilityLabel("Photo by \(photo.author)")

                VStack(alignment: .leading, spacing: 4) {
                    Text(photo.author)
                        .font(.title2.bold())
                    Text(photo.sizeDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let shareURL = URL(string: photo.downloadURL) {
                    ShareLink(item: shareURL)
                }

                Button {
                    viewModel.toggleFavourite(photo)
                } label: {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavourite ? .red : .primary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .accessibilityLabel(isFavourite ? "Remove from favourites" : "Add to favourites")
                .sensoryFeedback(.selection, trigger: isFavourite)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: FavouritePhoto.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    NavigationStack {
        PhotoDetailView(photo: .sample)
            .environment(FavouritesViewModel(modelContext: container.mainContext))
    }
    .modelContainer(container)
}
