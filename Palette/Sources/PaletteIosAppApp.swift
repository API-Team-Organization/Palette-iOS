import SwiftUI
import FlowKit

@main

// TODO :: Token 인증 로직 구현
// TODO :: 여기서 토큰 여부에 따라 즉시 네비게이션 구현
// TODO :: 이미지 로딩 파트 개선?
// TODO :: 채팅 Pageing
// TODO :: 로딩화면 처리
// TODO :: 화면 전환에 토큰갱신 API 삽입

struct PaletteIosAppApp: App {
    var body: some Scene {
        WindowGroup {
            FlowPresenter(rootView: StartView())
                .ignoresSafeArea()
        }
    }
}
