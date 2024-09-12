//
//  AddChatButton.swift
//  Palette
//
//  Created by 4rNe5 on 6/5/24.
//

import SwiftUI
import FlowKit

struct AddChatButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Color(Color("ButtonBG"))
                HStack {
                    HStack {
                        Text("새 포스터 만들기")
                            .font(.custom("SUIT-Bold", size: 14))
                            .padding(.leading, 20)
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    Image("Arrow")
                        .resizable()
                        .frame(width: 6, height: 10)
                        .padding(.trailing, 20)
                }
            }
            .frame(width: 350, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .padding(.bottom, 30)
        }
    }
}
