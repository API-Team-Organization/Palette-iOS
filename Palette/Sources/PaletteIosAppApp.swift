import SwiftUI
import FlowKit

@main

// TODO :: Token 인증 로직 구현
// TODO :: 여기서 토큰 여부에 따라 즉시 네비게이션 구현
// TODO :: 채팅뷰 통신구조 변경 (Feat @jombidev)
// TODO :: 채팅뷰 하단 입력파트 입력 타입따라 다양화 (Grid, Picker)
// TODO :: 이미지 로딩 파트 개선
// TODO :: 채팅 Pageing
// TODO :: 로딩화면 처리
// TODO :: 화면 전환에 토큰갱신 API 삽입
// TODO :: 로그인 과정 Exception Case 디양화

struct PaletteIosAppApp: App {
    var body: some Scene {
        WindowGroup {
            FlowPresenter(rootView: StartView())
                .ignoresSafeArea()
        }
    }
}
