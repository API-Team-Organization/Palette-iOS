//
//  ChatListView.swift
//  Palette
//
//  Created by 4rNe5 on 6/20/24.
//

import SwiftUI
import Alamofire
import FlowKit


func getHeaders() -> HTTPHeaders {
    let token: String
    if let tokenData = KeychainManager.load(key: "accessToken"),
       let tokenString = String(data: tokenData, encoding: .utf8) {
        token = tokenString
    } else {
        token = ""
    }
    
    let headers: HTTPHeaders = [
        "x-auth-token": token
    ]
    return headers
}

class ChatRoomViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoomModel] = []
    
    func getChatRoomData() {
        let url = "https://paletteapp.xyz/room/list"
        let decoder = JSONDecoder()
        
        AF.request(url, method: .get, headers: getHeaders())
            .responseDecodable(of: ChatRoomResponseModel<ChatRoomModel>.self, decoder: decoder) { [weak self] response in
                switch response.result {
                case .success(let chatRoomResponse):
                    DispatchQueue.main.async {
                        self?.chatRooms = chatRoomResponse.data
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
    }
}

struct ChatListView: View {
    
    @State var uName: String = "유저"
    @StateObject private var viewModel = ChatRoomViewModel()
    
    func getProfileData() async {
        let url = "https://paletteapp.xyz/info/me"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        AF.request(url, method: .get, headers: getHeaders())
            .responseDecodable(of: ProfileResponseModel<ProfileDataModel>.self, decoder: decoder) { response in
                switch response.result {
                case .success(let profileResponse):
                    print(profileResponse.data.name)
                    uName = profileResponse.data.name
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Raw response: \(str)")
                    }
                }
            }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(uName)님!")
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
                AddTaskButtom(destinationView: PaletteChatView(roomTitle: "AND 포스터 제작", roomID: 1))
                VStack(spacing: 10) {
                    ForEach(viewModel.chatRooms, id: \.id) { room in
                        ChatRoomButton(roomTitle: room.title, roomID: room.id)
                    }
                }
                
            }
        }
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            Task {
                await getProfileData()
                viewModel.getChatRoomData()
            }
        }
    }
}

#Preview {
    ChatListView()
}
