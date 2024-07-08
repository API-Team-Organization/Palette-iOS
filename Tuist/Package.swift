// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Blank
    )
#endif

let package = Package(
    name: "PaletteIosApp",
    dependencies: [
        .package(url: "https://github.com/LaunchDarkly/swift-eventsource", from: "3.3.0"),
         .package(url: "https://github.com/Alamofire/Alamofire", from: "5.9.1"),
         .package(url: "https://github.com/rive-app/rive-ios", from: "5.11.2"),
         .package(url: "https://github.com/realm/realm-swift", from: "10.50.0"),
         .package(url: "https://github.com/socketio/socket.io-client-swift", from: "16.1.0"),
         .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0"),
         .package(url: "https://github.com/Mercen-Lee/FlowKit", .branch("main")),
         .package(url: "https://github.com/CSolanaM/SkeletonUI", .branch("master")),
    ]
)
