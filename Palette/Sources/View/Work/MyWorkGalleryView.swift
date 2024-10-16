import SwiftUI
import Kingfisher
import FlowKit

struct MyWorkGalleryView: View {
    @Flow var flow
    @State private var selectedTab = 0
    @State private var page = 0
    @State private var images: [String] = []
    @State private var isLoading = false
    @State private var hasMorePages = true
    @State private var fullscreenImage: UIImage?
    @State private var showingSaveSuccessAlert = false
    @Binding var isFullScreenPresented: Bool

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("내 작업물")
                        .font(.custom("SUIT-ExtraBold", size: 25))
                        .foregroundStyle(.black)
                        .padding(.top, 45)
                        .padding(.leading, 25)
                        .padding(.bottom, 30)
                    Spacer()
                }
                
                SegmentedPicker(preselectedIndex: $selectedTab,
                                options: ["이미지", "동영상"])
                
                if selectedTab == 0 {
                    GridView(images: images, onImageTap: { image in
                        self.fullscreenImage = image
                        self.isFullScreenPresented = true
                    }, onSave: { imageUrl in
                        saveImageToGallery(imageUrl: imageUrl)
                    }, onLoadMore: {
                        if !isLoading && hasMorePages {
                            Task {
                                await loadMoreImages()
                            }
                        }
                    })
                } else if selectedTab == 1 {
                    VStack(alignment: .center){
                        Spacer()
                        Text("동영상 기능은 아직 구현되지 않았습니다.")
                            .foregroundStyle(.black)
                            .font(.custom("SUIT-Bold", size: 18))
                        Spacer()
                    }
                }
                
                if isLoading {
                    ProgressView()
                }
                
                Spacer()
            }
            
            if isFullScreenPresented, let image = fullscreenImage {
                FullScreenImageView(image: image, isPresented: $isFullScreenPresented)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
        }
        .alert(isPresented: $showingSaveSuccessAlert) {
            Alert(title: Text("이미지 저장 완료!"),
                  message: Text("이미지가 사진첩에 저장되었어요!"),
                  dismissButton: .default(Text("확인")))
        }
        .onAppear {
            Task {
                await loadMoreImages()
            }
        }
    }
    
    func loadMoreImages() async {
        guard !isLoading && hasMorePages else { return }
        await MainActor.run {
            isLoading = true
        }
        
        let result = await PaletteNetworking.get("/chat/my-image?page=\(page)&size=10", res: DataResModel<ImageListModel>.self)
        
        await MainActor.run {
            isLoading = false
            switch result {
            case .success(let imageResponse):
                self.images.append(contentsOf: imageResponse.data.images)
                self.page += 1
                self.hasMorePages = !imageResponse.data.images.isEmpty
            case .failure(let error):
                print("Error loading images: \(error)")
            }
        }
    }
    
    func saveImageToGallery(imageUrl: String) {
        KingfisherManager.shared.retrieveImage(with: URL(string: imageUrl)!) { result in
            switch result {
            case .success(let value):
                UIImageWriteToSavedPhotosAlbum(value.image, nil, nil, nil)
                showingSaveSuccessAlert = true
            case .failure(let error):
                print("Error saving image: \(error)")
            }
        }
    }
    
}
