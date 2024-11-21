import SwiftUI
import Kingfisher

struct StaggeredGridView: View {
    let images: [String]
    let onImageTap: (UIImage) -> Void
    let onSave: (String) -> Void
    let onLoadMore: () -> Void
    
    @State private var imageHeights: [String: CGFloat] = [:]
    
    private var splitArray: [[String]] {
        var result: [[String]] = []
        
        var list1: [String] = []
        var list2: [String] = []
        
        images.enumerated().forEach { index, image in
            if index % 2 == 0 {
                list1.append(image)
            } else {
                list2.append(image)
            }
        }
        result.append(list1)
        result.append(list2)
        return result
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width - 30
            let itemWidth = (width - 25) / 2
            
            ScrollView {
                HStack(alignment: .top, spacing: 10) {
                    LazyVStack(spacing: 8) {
                        ForEach(splitArray[0], id: \.self) { imageUrl in
                            createImageTile(imageUrl: imageUrl, itemWidth: itemWidth)
                        }
                    }
                    
                    LazyVStack(spacing: 8) {
                        ForEach(splitArray[1], id: \.self) { imageUrl in
                            createImageTile(imageUrl: imageUrl, itemWidth: itemWidth)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 75)
            }
            .onChange(of: images) { newValue in
                if !newValue.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onLoadMore()
                    }
                }
            }
        }
    }
    
    private func createImageTile(imageUrl: String, itemWidth: CGFloat) -> some View {
        KFImage.url(URL(string: imageUrl))
            .placeholder {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .frame(width: itemWidth, height: itemWidth)
            }
            .loadDiskFileSynchronously()
            .cacheMemoryOnly()
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: .fit) // 유지 원본 비율
            .frame(width: itemWidth)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
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
                Button(action: {
                    if let url = URL(string: imageUrl) {
                        KingfisherManager.shared.retrieveImage(with: url) { result in
                            switch result {
                            case .success(let value):
                                let image = value.image
                                let activityViewController = UIActivityViewController(
                                    activityItems: [image],
                                    applicationActivities: nil
                                )
                                
                                // Optional: Exclude certain activity types
                                activityViewController.excludedActivityTypes = [
                                    .addToReadingList,
                                    .assignToContact,
                                    .print
                                ]
                                
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootViewController = windowScene.windows.first?.rootViewController {
                                    rootViewController.present(activityViewController, animated: true, completion: nil)
                                }
                            case .failure(let error):
                                print("Image download failed: \(error)")
                            }
                        }
                    }
                }) {
                    Text("이미지 공유하기")
                    Image(systemName: "square.and.arrow.up")
                }
            }
    }
}
