//
//  AppInfoView.swift
//  Palette
//
//  Created by 4rNe5 on 10/15/24.
//

import SwiftUI
import FlowKit

struct AppInfoView: View {
    
    @Flow var flow
    
    var body: some View {
        ZStack{
            Color(.white).ignoresSafeArea()
            VStack {
                HStack {
                    BackButton()
                        .padding(.leading, 15)
                        .padding(.top, 7)
                    Spacer()
                }
                Spacer()
                Image("PaletteLogo")
                    .resizable()
                    .frame(width: 150, height: 150)
                Text("\(Text("AI").font(.custom("SUIT-ExtraBold", size: 25)))로 그리다, \(Text("Palette").font(.custom("SUIT-ExtraBold", size: 25)))")
                    .font(.custom("Pretendard-ExtraBold", size: 25))
                    .foregroundStyle(Color.black)
                    .padding(.top, 15)
                    .padding(.bottom, 13)
                
                Text("Palette Version (0.1.0)")
                    .foregroundStyle(Color.black)
                    .font(.custom("SUIT-Bold", size: 18))
                Text("Platform : iOS")
                    .foregroundStyle(Color.black)
                    .font(.custom("SUIT-SemiBold", size: 18))
                Text("Made By \(Text("Team API").font(.custom("SUIT-ExtraBold", size: 18)))")
                    .foregroundStyle(Color.black)
                    .font(.custom("SUIT-SemiBold", size: 18))
                Spacer()
            }
        }
    }
}

#Preview {
    AppInfoView()
}
