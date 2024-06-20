//
//  AddTaskButtom.swift
//  Palette
//
//  Created by 4rNe5 on 6/5/24.
//

import SwiftUI
import FlowKit

struct AddTaskButtom <Content: View>: View {
    
    @Flow var flow
    var destinationView: Content
    
    var body: some View {
        Button (action: {
            flow.push(destinationView)
        }, label: {
            ZStack {
                Color(Color("ButtonBG"))
                HStack {
                    Image("Plus")
                        .padding(.leading, 5)
                    
                    VStack(alignment: .leading) {
                        Text("새 작업 시작하기 ")
                            .font(.custom("Pretendard-Bold", size: 24))
                            .foregroundStyle(.black)
                            .padding(.bottom, 5)
                        
                        Text("\(Text("Palette AI").font(.custom("SUIT-Bold", size: 18)))와 당신만의")
                            .font(.custom("Pretendard-SemiBold", size: 18))
                            .foregroundStyle(Color("DescText"))
                        Text("새로운 홍보물을 만들어보세요.")
                            .font(.custom("Pretendard-SemiBold", size: 18))
                            .foregroundStyle(Color("DescText"))
                    }
                    .padding(.leading, 15)
                }
                
            }
            .frame(width: 340, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        })
    }
}

#Preview {
    
    AddTaskButtom(destinationView: StartView())
    
}
