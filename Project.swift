import ProjectDescription

let project = Project(
    name: "Palette",
    targets: [
        .target(
            name: "Palette",
            destinations: .iOS,
            product: .app,
            bundleId: "xyz.paleteapp.ios",
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Palette",
                    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
                    "NSAppTransportSecurity": ["NSAllowsArbitraryLoads": true],
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "UIAppFonts": [
                        "Pretendard-Black.otf",
                        "Pretendard-Bold.otf",
                        "Pretendard-ExtraBold.otf",
                        "Pretendard-ExtraLight.otf",
                        "Pretendard-Light.otf",
                        "Pretendard-Medium.otf",
                        "Pretendard-Regular.otf",
                        "Pretendard-SemiBold.otf",
                        "Pretendard-Thin.otf",
                        "SUIT-Bold.otf",
                        "SUIT-ExtraBold.otf",
                        "SUIT-ExtraLight.otf",
                        "SUIT-Heavy.otf",
                        "SUIT-Light.otf",
                        "SUIT-Medium.otf",
                        "SUIT-Regular.otf",
                        "SUIT-SemiBold.otf",
                        "SUIT-Thin.otf",
                   ]
                ]
            ),
            sources: ["Palette/Sources/**"],
            resources: ["Palette/Resources/**"],
            dependencies: [
                .external(name: "LDSwiftEventSource"),
                .external(name: "Alamofire"),
                .external(name: "RiveRuntime"),
                .external(name: "Realm"),
                .external(name: "SocketIO"),
                .external(name: "Kingfisher"),
                .external(name: "FlowKit"),
                .external(name: "SkeletonUI"),
            ]
        ),
        .target(
            name: "PaletteIosAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "xyz.paleteapp.iosAppTests",
            infoPlist: .default,
            sources: ["Palette/Tests/**"],
            resources: [],
            dependencies: [
              .target(name: "Palette")
            ]
        ),
    ]
)
