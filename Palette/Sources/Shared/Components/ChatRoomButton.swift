import SwiftUI
import FlowKit

struct ChatRoomButton: View {
    @Flow var flow
    var roomTitle: String
    var roomID: Int
    
    var body: some View {
        Button(action: {
            flow.push(Text("Tex"))
        }) {
            ZStack {
                Color(Color("ButtonBG"))
                HStack {
                    Image("PaletteLogo")
                        .resizable()
                        .frame(width: 58, height: 58)
                        .padding(.leading, 20)
                    
                    VStack(alignment: .leading) {
                        Text("\(Text("Palette").font(.custom("SUIT-Regular", size: 19))) 어시스턴트")
                            .font(.custom("Pretendard-Regular", size: 19))
                            .foregroundStyle(Color("LightDark"))
                            .padding(.bottom, -6)
                        
                        MarqueeText(text: roomTitle, font: .custom("Pretendard-Bold", size: 23), startDelay: 1.0)
                            .foregroundStyle(.black)
                            .frame(height: 30)
                    }
                    .padding(.leading, 15)
                    Spacer()
                }
            }
            .frame(width: 340, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
    }
}

struct ChatRoomButton_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomButton(roomTitle: "번역 서비스 포스터 제작 - 매우 긴 제목 테스트입니다", roomID: 1)
    }
}
