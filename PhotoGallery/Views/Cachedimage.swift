//
//  Cachedimage.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import SwiftUI
import ImageIO

struct CachedImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill

    @State private var image: Image?
    @State private var failed = false

    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity)
            } else if failed {
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
        .task(id: url) {
            await load()
        }
    }

    private func load() async {

        guard let url else { failed = true

            return
        }
        
        failed = false
        
        do {
            
            let data = try await ImageLoader.shared.imageData(for: url)
            
            if let loaded = Image(data: data) {
                
                withAnimation(.easeIn(duration: 0.2)) {
                    
                    image = loaded
                }
                
            } else {
                print("Couldn't turn data into an image for \(url)")
                
                failed = true
                
            }
            
        } catch {
            print("Image failed for \(url): \(error)")
            
            if !Task.isCancelled {
                
                failed = true
            }
        }
    }
}

#Preview {
    CachedImage(url: Photo.sample.thumbnailURL)
        .frame(width: 200, height: 200)
        .clipped()
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
