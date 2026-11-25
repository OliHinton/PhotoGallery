//
//  Photogridcell.swift
//  PhotoGallery
//
//  Created by Oli Hinton on 13/11/2026.
//

import SwiftUI

struct PhotoGridCell: View {
    let photo: Photo
    let namespace: Namespace.ID

    var body: some View {
        NavigationLink(value: photo) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    CachedImage(url: photo.thumbnailURL)
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .matchedTransitionSource(id: photo.id, in: namespace)
        .accessibilityLabel("Photo by \(photo.author)")
        .accessibilityHint("Opens the photo")
    }
}

#Preview {
    @Previewable @Namespace var namespace

    NavigationStack {
        PhotoGridCell(photo: .sample, namespace: namespace)
    }
}
