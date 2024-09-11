import SwiftUI
import Kingfisher
import FlowKit
import Alamofire

struct MyWorkGalleryView: View {
    @Flow var flow
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            HStack {
                Text("내 작업물")
                    .font(.custom("SUIT-Bold", size: 25))
                    .foregroundStyle(.black)
                    .padding(.top, 45)
                    .padding(.leading, 25)
                    .padding(.bottom, 30)
                Spacer()
            }
            
            SegmentedPicker(preselectedIndex: $selectedTab,
                    options: ["이미지", "동영상"])
            }
            
            Spacer()
    }
}

struct GridView: View {
    let items: [Item]
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items) { item in
                    item.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct Item: Identifiable {
    let id = UUID()
    let image: Image
}

#Preview {
    MyWorkGalleryView()
}
