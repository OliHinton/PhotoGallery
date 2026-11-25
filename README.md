Photo Gallery

A SwiftUI art gallery built on the free Art Institute of Chicago API, which needs no API key. Browse an endlessly scrolling grid of artworks, open any one full size, and save favourites that persist between launches.

Features

Infinite scrolling grid: loads 30 artworks at a time, fetching the next page as you near the bottom
Actor-based image cache: every image is downloaded once, even when several cells ask for it at the same moment
Detail screen: full-size image with pinch-to-zoom, the artist and dimensions, and a share button
Favourites: saved with SwiftData and shown in their own tab
Zoom transition from the grid into the detail screen
2 or 3 column layout, remembered with @AppStorage
Loading, error (with retry) and empty states, pull-to-refresh, haptics and VoiceOver labels

Tech

SwiftUI · Swift Concurrency (async/await, actors) · SwiftData · Observation (@Observable) · Swift Testing · iOS 18+

Architecture

View  →  PhotosViewModel  →  PhotoServiceProtocol  →  Art Institute of Chicago API
  │
  ├──→  FavouritesViewModel  →  SwiftData
  │
  └──→  CachedImage  →  ImageLoader (actor)  →  cache, or network

Design decisions

Why the image loader is an actor. Many cells request images at once, and the cache is shared mutable state, so an actor protects it from data races.
De-duplicating in-flight downloads. Actors are reentrant: while one request is suspended waiting for the network, a second request for the same URL can run, and with a plain cache both would miss and download twice. The loader stores the in-progress Task before awaiting it, so the second caller finds it and awaits the same download. Failed downloads are removed so they can be retried.
The same rule in the view model. isLoadingMore is set before the page request is awaited, so two cells appearing at the same time can't trigger the same page twice.
API model vs app model. Artwork mirrors the museum's JSON, with optional fields, and maps to the app's Photo. Artworks without an image are dropped with compactMap.
Favourites in a view model. FavouritesViewModel owns the SwiftData ModelContext, injected once at the app root, so all favourites logic lives in one testable place and every screen reads from a single source of truth.
Thumbnails vs full size. The grid requests 400-wide images and the detail screen 843-wide ones, both sizes the museum caches, so the grid never downloads full-size originals.
.task(id:) for image loading. Each cell's load starts when it appears and is cancelled automatically when it scrolls away.
