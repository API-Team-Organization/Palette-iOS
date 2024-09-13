//
//  GridView.swift
//  Palette
//
//  Created by 4rNe5 on 9/13/24.
//
import SwiftUI
import Kingfisher

struct GridView: View {
    let images: [String]
    let onImageTap: (UIImage) -> Void
    let onSave: (String) -> Void
    let onLoadMore: () -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(images, id: \.self) { imageUrl in
                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 225)
                        .background(Color.white)
                        .cornerRadius(10)
                        .onTapGesture {
                            KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!) { result in
                                if case .success(let value) = result {
                                    onImageTap(value.image)
                                }
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                onSave(imageUrl)
                            }) {
                                Text("갤러리에 저장하기")
                                Image(systemName: "square.and.arrow.down")
                            }
                        }
                }
            }
            .padding()
            .padding(.bottom, 75)
        }
        .onChange(of: images) { _ in
            if !images.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onLoadMore()
                }
            }
        }
    }
}
