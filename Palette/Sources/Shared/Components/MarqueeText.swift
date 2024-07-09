//
//  MarqueeText.swift
//  Palette
//
//  Created by 4rNe5 on 7/9/24.
//

import SwiftUI

struct MarqueeText: View {
    let text: String
    let font: Font
    let startDelay: Double
    
    @State private var offset: CGFloat = 0
    @State private var animating = false
    
    var body: some View {
        GeometryReader { geometry in
            let textWidth = textSize().width
            let containerWidth = geometry.size.width
            let scrollDistance = max(0, textWidth - containerWidth)
            
            ZStack(alignment: .leading) {
                Text(text)
                    .font(font)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .offset(x: offset)
                    .onAppear {
                        guard scrollDistance > 0 else { return }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                            withAnimation(Animation.linear(duration: Double(scrollDistance) / 30).repeatForever(autoreverses: true)) {
                                offset = -scrollDistance
                            }
                        }
                    }
            }
            .frame(width: containerWidth, alignment: .leading)
            .clipShape(Rectangle())
        }
    }
    
    private func textSize() -> CGSize {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 23, weight: .bold)
        ]
        return (text as NSString).size(withAttributes: attributes)
    }
}
