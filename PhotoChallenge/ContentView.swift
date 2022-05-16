//
//  ContentView.swift
//  PhotoChallenge
//
//  Created by Adrian Bilescu on 12.05.2022.
//

import SwiftUI
import CoreChallenge
import PresentationChallenge

struct ContentView: View {
    @ObservedObject var viewModel: GalleryViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    if !viewModel.photos.isEmpty {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], content: {
                            ForEach(viewModel.photos, id: \.id, content: { photo in
                                NavigationLink(destination: {
                                    DetailView(photo: photo)
                                        .transition(.opacity)
                                }, label: {
                                    AsyncImage(url: photo.url, content: { image in
                                        image
                                            .fitToAspect(1, contentMode: .fill)
                                    }, placeholder: {
                                        ProgressView()
                                    })
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .onAppear {
                                        viewModel.didLoad(photo: photo)
                                    }
                                })
                                
                            })
                        })
                    }
                    if viewModel.isFetching {
                        ProgressView("Loading content...")
                    }
                }.frame(maxHeight: .infinity)
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer)
    }
}

struct DetailView: View {
    let photo: Photo
    var body: some View {
        
        GeometryReader { proxy in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                
                AsyncImage(url: photo.url, content: { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width * self.scale, height: proxy.size.height * self.scale)
                }, placeholder: {
                    ProgressView()
                })
                
            }
            .gesture(MagnificationGesture()
                .updating($scaleOffset, body: { value, out, _ in
                    if currentScale * value > Self.minScale && currentScale * value < Self.maxScale {
                        out = value
                    }
                }).onEnded { value in
                    currentScale = (currentScale * value).clamp(Self.minScale, Self.maxScale)
                })
        }
    }
    @State private var currentScale: CGFloat = 1.0
    @GestureState private var scaleOffset: CGFloat = 0.0
    static let maxScale: CGFloat = 10.0
    static let minScale: CGFloat = 1.0
    
    var scale: CGFloat {
        scaleOffset != 0 ? currentScale * scaleOffset : currentScale
    }
}


extension Image {
    func fitToAspect(_ aspectRatio: Double, contentMode: SwiftUI.ContentMode) -> some View {
        self.resizable()
            .scaledToFill()
            .modifier(FitToAspectRatio(aspectRatio: aspectRatio, contentMode: contentMode))
    }
}

struct FitToAspectRatio: ViewModifier {
    
    let aspectRatio: Double
    let contentMode: SwiftUI.ContentMode
    
    func body(content: Content) -> some View {
        Color.clear
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay(
                content.aspectRatio(nil, contentMode: contentMode)
            )
            .clipShape(Rectangle())
    }
    
}

public extension Comparable {
    func clamp<T: Comparable>(_ lower: T, _ upper: T) -> T {
        return min(max(self as! T, lower), upper)
    }
}
