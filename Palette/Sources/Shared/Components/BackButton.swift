//
//  BackButton.swift
//  Palette
//
//  Created by 4rNe5 on 7/9/24.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18))
                    .bold()
                    .foregroundStyle(Color("LightDark"))
                    .padding(.leading, 0)
                Text("돌아가기")
                    .font(.custom("SUIT-SemiBold", size: 17))
                    .foregroundStyle(Color("LightDark"))
            }
        }
    }
}

#Preview {
    BackButton()
}
