//
//  AnimatedUnderline.swift
//  Palette
//
//  Created by 4rNe5 on 10/15/24.
//
import SwiftUI

struct AnimatedUnderline: View {
    let color: Color
    let isActive: Bool
    @State private var width: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Color.clear
                Rectangle()
                    .fill(color)
                    .frame(width: isActive ? geometry.size.width : width, height: 1)
            }
            .onAppear {
                width = 0
            }
            .onChange(of: isActive) { newValue in
                withAnimation(newValue ? .easeOut(duration: 0.2) : .easeIn(duration: 0.2)) {
                    width = newValue ? geometry.size.width : 0
                }
            }
        }
        .frame(height: 1)
    }
}
