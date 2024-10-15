//
//  SettingButton.swift
//  Palette
//
//  Created by 4rNe5 on 9/11/24.
//
import SwiftUI
import UIKit
import FlowKit

enum settingPage {
    case notification
    case privacy
    case evolved
    case appinfo
}

struct SettingButton: View {
    @Flow var flow
    var buttonTitle: String
    var settingPage: settingPage
    
    
    var body: some View {
        Button(action: {
            switch settingPage {
            case .notification:
                flow.push(Text("Notification"))
            case .privacy:
                OpenURL(url: "https://dgsw-team-api.notion.site/cc32c87f614e4798893293abfe5ca72a?pvs=74")
            case .evolved:
                flow.push(Text("evolved"))
            case .appinfo:
                flow.push(AppInfoView(), animated: true)
            }
        }) {
            HStack {
                switch settingPage {
                case .notification:
                    Image("Notification")
                        .resizable()
                        .frame(width: 13, height: 16)
                        .padding(.trailing, 8)
                case .privacy:
                    Image("Bookmark")
                        .resizable()
                        .frame(width: 12, height: 15)
                        .padding(.trailing, 8)
                case .evolved:
                    Image("Stat")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .padding(.trailing, 8)
                case .appinfo:
                    Image("Info")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .padding(.trailing, 8)
                }
                Text(buttonTitle)
                    .font(.custom("SUIT-SemiBold", size: 18))
                    .foregroundStyle(.black)
                Spacer()
                Image("Arrow")
                    .resizable()
                    .frame(width: 7, height: 11)
            }
            .padding(.horizontal, 20)
        }
    }
}
