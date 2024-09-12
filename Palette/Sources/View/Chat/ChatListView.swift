//
//  ChatListView.swift
//  Palette
//
//  Created by 4rNe5 on 6/20/24.
//
import SwiftUI
import Alamofire
import FlowKit
import Combine


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
        let url = "https://api.paletteapp.xyz/room/list"
        let decoder = JSONDecoder()

        AF.request(url, method: .get, headers: getHeaders())
            .validate(statusCode: 200..<300) // Add validation to ensure the response is valid
            .responseDecodable(of: ChatRoomResponseModel<ChatRoomModel>.self, decoder: decoder) { [weak self] response in
                switch response.result {
                case .success(let chatRoomResponse):
                    DispatchQueue.main.async {
                        self?.chatRooms = chatRoomResponse.data
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Raw response: \(str)")
                    }
                }
            }
    }

    func deleteChatRoom(roomID: Int) {
        let url = "https://api.paletteapp.xyz/room/\(roomID)"

        AF.request(url, method: .delete, headers: getHeaders())
            .validate(statusCode: 200..<300) // Add validation to ensure the response is valid
            .response { [weak self] response in
                switch response.result {
                case .success:
                    DispatchQueue.main.async {
                        self?.getChatRoomData() // Refresh chat room list
                    }
                case .failure(let error):
                    print("Error deleting room: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Raw response: \(str)")
                    }
                }
            }
    }
}

struct ChatListView: View {
    @State var uName: String = "유저"
    @StateObject private var viewModel = ChatRoomViewModel()
    @State private var showingNewChatView = false
    @State private var newRoomID: Int?
    @Flow var flow

    func getProfileData() async {
        let url = "https://api.paletteapp.xyz/info/me"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        AF.request(url, method: .get, headers: getHeaders())
            .validate(statusCode: 200..<300) // Add validation to ensure the response is valid
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

    func createNewChatRoom() {
        let url = "https://api.paletteapp.xyz/room"
        let decoder = JSONDecoder()

        AF.request(url, method: .post, headers: getHeaders())
            .validate(statusCode: 200..<300) // Add validation to ensure the response is valid
            .responseDecodable(of: CreateRoomResponseModel<CreateRoomModel>.self, decoder: decoder) { response in
                switch response.result {
                case .success(let createRoomResponse):
                    DispatchQueue.main.async {
                        debugPrint("Success")
                        flow.push(PaletteChatView(roomTitleprop: "새 채팅방 이름", roomID: createRoomResponse.data.id, isNewRoom: true))
                    }
                case .failure(let error):
                    print("Error creating room: \(error.localizedDescription)")
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Raw response: \(str)")
                }
            }
        }
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
                            Text("\(Text(uName).font(.custom("SUIT-ExtraBold", size: 25)))님 환영합니다!")
                                .font(.custom("SUIT-ExtraBold", size: 25))
                                .padding(.leading, 20)
                                .foregroundStyle(.black)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    AddChatButton(action: createNewChatRoom)
                    HStack {
                        Text("내가 만든 포스터")
                            .font(.custom("SUIT-Bold", size: 18))
                            .foregroundStyle(.black)
                            .padding(.leading, 25)
                        Spacer()
                        VStack {
                            Spacer()
                            Button(action: {
                                
                            }) {
                                Text("전체보기")
                                    .font(.custom("SUIT-Medium", size: 14))
                                    .foregroundStyle(Color("AccentColor"))
                                    .padding(.trailing, 25)
                                    
                            }
                        }
                    }
                    VStack(spacing: 10) {
                        ForEach(viewModel.chatRooms, id: \.id) { room in
                            ChatRoomButton(roomTitle: room.title, roomID: room.id, lastMessage: room.message, onDelete: { roomID in
                                viewModel.deleteChatRoom(roomID: roomID)
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
                    await getProfileData()
                    await viewModel.getChatRoomData()
                }
            }
        }
    }
    
}
