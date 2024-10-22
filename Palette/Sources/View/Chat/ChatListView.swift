//
//  ChatListView.swift
//  Palette
//
//  Created by 4rNe5 on 6/20/24.
//
import SwiftUI
import FlowKit
import Combine

class ChatRoomViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoomModel] = []
    @Published var uName: String = "유저"
    
    func getChatRoomData() async {
        let result = await PaletteNetworking.get("/room/list", res: DataResModel<[ChatRoomModel]>.self)
        switch result {
        case .success(let chatRoomResponse):
            await self.setChatRooms(chatRoomResponse.data)
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func getProfileData() async {
        let result = await PaletteNetworking.get("/info/me", res: DataResModel<ProfileDataModel>.self)
        switch result {
        case .success(let profileResponse):
            print(profileResponse.data.name)
            await self.setUsername(profileResponse.data.name)
            
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func setUsername(_ name: String) {
        uName = name
    }
    
    @MainActor
    func setChatRooms(_ res: [ChatRoomModel]) {
        self.chatRooms = res.reversed()
    }

    func deleteChatRoom(roomID: Int) async {
        await PaletteNetworking.delete("/room/\(roomID)", res: EmptyResModel.self)
        await self.getChatRoomData()
    }
}

struct ChatListView: View {
    @StateObject private var viewModel = ChatRoomViewModel()
    @State private var showingNewChatView = false
    @State private var newRoomID: Int?
    @Flow var flow

    func createNewChatRoom() async {
        let result = await PaletteNetworking.post("/room", res: DataResModel<CreateRoomModel>.self)
        
        switch result {
        case .success(let response):
            await MainActor.run {
                moveToChatView(response.data.id)
            }
        case .failure(let error):
            print("Error creating room: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func moveToChatView(_ id: Int) {
        flow.push(PaletteChatView(roomTitleprop: "새 채팅방 이름", roomID: id, isNewRoom: true))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                VStack {
                    HStack {
                        Image("PaletteLogo")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .padding(.leading, 20)
                            .padding(.top, 20)
                        Spacer()
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(Text(viewModel.uName).font(.custom("SUIT-ExtraBold", size: 25)))님 환영합니다!")
                                .font(.custom("SUIT-ExtraBold", size: 25))
                                .padding(.leading, 20)
                                .foregroundStyle(.black)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    AddChatButton(action: {
                        Task {
                            await createNewChatRoom()
                        }
                    })
                    HStack {
                        Text("내가 만든 포스터")
                            .font(.custom("SUIT-Bold", size: 18))
                            .foregroundStyle(.black)
                            .padding(.leading, 25)
                        Spacer() 
                    }
                    VStack(spacing: 10) {
                        ForEach(viewModel.chatRooms, id: \.id) { room in
                            ChatRoomButton(roomTitle: room.title, roomID: room.id, lastMessage: room.message, onDelete: { roomID in
                                Task {
                                    await viewModel.deleteChatRoom(roomID: roomID)
                                }
                            })
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BackgroundColor"))
            .onAppear {
                Task {
                    await (viewModel.getProfileData(), viewModel.getChatRoomData())
                }
            }
        }
    }
    
}

#Preview {
    ChatListView()
}
