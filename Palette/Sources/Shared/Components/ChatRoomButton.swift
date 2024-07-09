//
//  ChatRoomButton.swift
//  Palette
//
//  Created by 4rNe5 on 7/9/24.
//

import SwiftUI
import FlowKit

struct ChatRoomButton <Content: View>: View {
    @Flow var flow
    var destinationView: Content
    var roomTitle: String
    
    var body: some View {
        Button (action: {
            flow.push(destinationView)
        }, label: {
            ZStack {
                Color(Color("ButtonBG"))
                HStack {
                    Image("PaletteLogo")
                        .resizable()
                        .frame(width: 58, height: 58)
                        .padding(.leading, 10)
                    
                    VStack(alignment: .leading) {
                        Text("\(Text("Palette").font(.custom("SUIT-Regular", size: 19))) 어시스턴트")
                            .font(.custom("Pretendard-Regular", size: 19))
                            .foregroundStyle(Color("LightDark"))
                            .padding(.bottom, -6)
                        Text(roomTitle)
                            .font(.custom("Pretendard-Bold", size: 23))
                            .foregroundStyle(.black)

                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 10)
                }
                
            }
            .frame(width: 340, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        })
    }
}

#Preview {
    ChatRoomButton(destinationView: Text("ChatView"), roomTitle: "번역 서비스 포스터 제작")
}
