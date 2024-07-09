//
//  ChatListView.swift
//  Palette
//
//  Created by 4rNe5 on 6/20/24.
//

import SwiftUI

struct ChatListView: View {
    
    func getProfileData() async {
        
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("박준현님!")
                            .font(.custom("SUIT-ExtraBold", size: 31))
                            .padding(.leading, 15)
                            .foregroundStyle(.black)
                        Text("오늘은 무엇을 해볼까요?")
                            .font(.custom("SUIT-ExtraBold", size: 31))
                            .padding(.leading, 15)
                            .foregroundStyle(.black)
                    }
                    .padding(.leading, 15)
                    Spacer()
                }
                .padding(.top, 70)
                .padding(.bottom, 30)
                AddTaskButtom(destinationView: Text("New"))
                VStack(spacing: 10) {
                    ChatRoomButton(destinationView: Text("NewRoom"), roomTitle: "모디모디모디모디모디모디 홍보 포스터 제작")
                    ChatRoomButton(destinationView: Text("NewRoom"), roomTitle: "AND 홍보 포스터 제작")
                    ChatRoomButton(destinationView: Text("NewRoom"), roomTitle: "CommandCommand 홍보 포스터 제작")
                }
                
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear(
            
        )
    }
}

#Preview {
    ChatListView()
}
