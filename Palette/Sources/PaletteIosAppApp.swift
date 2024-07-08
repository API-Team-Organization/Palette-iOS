import SwiftUI
import FlowKit

@main

// TODO : Token 인증 로직 구현
// TODO : 여기서 토큰 여부에 따라 즉시 네비게이션 구현
// TODO : 채팅 컴포넌트 제작 (아이디 맵핑, 넘겨서 채팅 조회 및 SSE 연결)
// TODO : Server-Sent-Event 핸들러 제작
// TODO : 채팅뷰 만들기
// TODO : 로딩화면 처리
// TODO : 화면 전환에 토큰갱신 API 삽입

struct PaletteIosAppApp: App {
    var body: some Scene {
        WindowGroup {
            FlowPresenter(rootView: StartView())
                .ignoresSafeArea()
        }
    }
}
