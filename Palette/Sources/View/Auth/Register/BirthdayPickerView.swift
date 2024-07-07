//
//  BirthdayPickerView.swift
//  Palette
//
//  Created by 4rNe5 on 5/23/24.
//

import SwiftUI
import FlowKit

struct BirthdayPickerView: View {
    
    var email: String
    var pw: String
    var pwCheck: String
    @State private var birthDay = Date()
    @Flow var flow
    
    var body: some View {
        ZStack {
            Color(.white).ignoresSafeArea()
            VStack {
                HStack {
                    Text("생년월일을 선택해주세요!")
                        .font(.custom("Pretendard-ExtraBold", size: 27))
                        .padding(.leading, 15)
                        .foregroundStyle(.black)
                    Spacer()
                }
                .padding(.bottom, 2)
                .padding(.top, 50)
                HStack {
                    Text("(당신의 생년월일이 궁금하다는 그런 내용)")
                        .font(.custom("SUIT-Bold", size: 15))
                        .padding(.leading, 17)
                        .foregroundStyle(Color("DescText"))
                    Spacer()
                }
                Spacer()
                Spacer()
                HStack {
                    DatePicker("Please enter a date", selection: $birthDay, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                            .colorScheme(.light)
                            
                }
                Spacer()
                Spacer()
                Spacer()
                Button(action: {
                    flow.push(NameInputView(email: email,pw: pw, pwCheck: pwCheck, birthday: formattedDate(date: birthDay)))
                }) {
                    Text("다음으로")
                        .font(.custom("Pretendard-ExtraBold", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 363, height: 55)
                        .background(Color("AccentColor"))
                        .cornerRadius(12)
                        .padding(.bottom, 30)
                }
            }
            .onTapGesture {
                self.endTextEditing()
            }
        }
    }
}

#Preview {
    BirthdayPickerView(email: "me@4rne5.dev", pw: "", pwCheck: "")
}
