//
//  ChatListView.swift
//  Palette
//
//  Created by 4rNe5 on 6/20/24.
//

import SwiftUI

struct ChatListView: View {
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("박준현님!")
                                .font(.custom("SUIT-ExtraBold", size: 30))
                                .padding(.leading, 15)
                                .foregroundStyle(.black)
                            Text("오늘은 무엇을 해볼까요?")
                                .font(.custom("SUIT-ExtraBold", size: 30))
                                .padding(.leading, 15)
                                .foregroundStyle(.black)
                        }
                        .padding(.leading, 12)
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    AddTaskButtom(destinationView: Text("New"))
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ChatListView()
}
