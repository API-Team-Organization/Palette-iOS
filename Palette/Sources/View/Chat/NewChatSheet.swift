//
//  NewChatSheet.swift
//  Palette
//
//  Created by 4rNe5 on 7/10/24.
//

import SwiftUI

struct NewChatSheet: View {
    @Binding var roomTitle: String
//    var onSubmit: () -> Any
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("채팅방 이름", text: $roomTitle)
            }
            .navigationBarTitle("새 채팅방", displayMode: .inline)
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("생성") {
//                    onSubmit()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

