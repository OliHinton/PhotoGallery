//
//  Cachedimage.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import SwiftUI
import ImageIO

struct CachedImage: View {
    var contentMode: ContentMode = .fill
    var image: Image?
    @Environment(PhotosViewModel.self) private var viewModel

    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity)
            } else if viewModel.failed {
                Rectangle()
                    .fill(.quaternary)
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            } else {
                Rectangle()
                    .fill(.quaternary)
                ProgressView()
            }
        }
        .task(id: viewModel.url) {
            await viewModel.load()
        }
    }
}

#Preview {
    CachedImage()
}

extension Image {
    init?(data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        self.init(decorative: cgImage, scale: 1)
    }
}
