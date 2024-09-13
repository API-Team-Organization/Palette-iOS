import SwiftUI
import Kingfisher
import FlowKit
import Alamofire

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
                            loadMoreImages()
                        }
                    })
                } else if selectedTab == 1 {
                    Text("동영상 기능은 아직 구현되지 않았습니다.")
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
            loadMoreImages()
        }
    }
    
    func loadMoreImages() {
            guard !isLoading && hasMorePages else { return }
            isLoading = true
            
            let url = "https://api.paletteapp.xyz/chat/my-image"
            let parameters: [String: Any] = ["page": page, "size": 10]
            
            AF.request(url, method: .get, parameters: parameters, headers: getHeaders())
                .responseDecodable(of: ImageResponse.self) { response in
                    isLoading = false
                    switch response.result {
                    case .success(let imageResponse):
                        self.images.append(contentsOf: imageResponse.data)
                        self.page += 1
                        self.hasMorePages = !imageResponse.data.isEmpty
                    case .failure(let error):
                        print("Error loading images: \(error)")
                    }
                }
        }
    
    func getHeaders() -> HTTPHeaders {
        let token: String
        if let tokenData = KeychainManager.load(key: "accessToken"),
           let tokenString = String(data: tokenData, encoding: .utf8) {
            token = tokenString
        } else {
            token = ""
        }
        let headers: HTTPHeaders = [
            "x-auth-token": token
        ]
        return headers
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

struct ImageResponse: Codable {
    let code: Int
    let message: String
    let data: [String]
}
