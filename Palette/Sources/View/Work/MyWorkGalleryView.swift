import SwiftUI
import Kingfisher
import FlowKit
import Alamofire

struct MyWorkGalleryView: View {
    @Flow var flow
    @State private var selectedTab = 0
    
    func generateItems() -> [Item] {
        return (1...6).map { _ in Item(image: Image(systemName: "paintpalette.fill")) }
    }
    
    
    var body: some View {
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
                GridView(items: generateItems())
            } else if selectedTab == 1 {
                GridView(items: generateItems())
            }
            Spacer()
        }
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
                            .frame(width: 170, height: 225)
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
