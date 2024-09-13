import SwiftUI

struct FullScreenImageView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width - 40)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / self.lastScale
                                self.lastScale = value
                                self.scale *= delta
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    self.lastScale = 1.0
                                    if self.scale < 1 {
                                        self.scale = 1
                                    }
                                    self.offset = .zero
                                }
                            }
                        .simultaneously(with:
                            DragGesture()
                                .onChanged { value in
                                    if self.scale > 1 {
                                        self.offset = CGSize(
                                            width: self.lastOffset.width + value.translation.width,
                                            height: self.lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        self.lastOffset = .zero
                                        self.offset = .zero
                                    }
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            if scale > 1 {
                                scale = 1
                                offset = .zero
                            } else {
                                scale = 2
                            }
                        }
                    }
            }
            .onTapGesture {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}
