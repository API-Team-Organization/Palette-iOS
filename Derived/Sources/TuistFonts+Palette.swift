// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  import UIKit.UIFont
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum PaletteFontFamily {
  public enum Pretendard {
    public static let black = PaletteFontConvertible(name: "Pretendard-Black", family: "Pretendard", path: "Pretendard-Black.otf")
    public static let bold = PaletteFontConvertible(name: "Pretendard-Bold", family: "Pretendard", path: "Pretendard-Bold.otf")
    public static let extraBold = PaletteFontConvertible(name: "Pretendard-ExtraBold", family: "Pretendard", path: "Pretendard-ExtraBold.otf")
    public static let extraLight = PaletteFontConvertible(name: "Pretendard-ExtraLight", family: "Pretendard", path: "Pretendard-ExtraLight.otf")
    public static let light = PaletteFontConvertible(name: "Pretendard-Light", family: "Pretendard", path: "Pretendard-Light.otf")
    public static let medium = PaletteFontConvertible(name: "Pretendard-Medium", family: "Pretendard", path: "Pretendard-Medium.otf")
    public static let regular = PaletteFontConvertible(name: "Pretendard-Regular", family: "Pretendard", path: "Pretendard-Regular.otf")
    public static let semiBold = PaletteFontConvertible(name: "Pretendard-SemiBold", family: "Pretendard", path: "Pretendard-SemiBold.otf")
    public static let thin = PaletteFontConvertible(name: "Pretendard-Thin", family: "Pretendard", path: "Pretendard-Thin.otf")
    public static let all: [PaletteFontConvertible] = [black, bold, extraBold, extraLight, light, medium, regular, semiBold, thin]
  }
  public enum Suit {
    public static let bold = PaletteFontConvertible(name: "SUIT-Bold", family: "SUIT", path: "SUIT-Bold.otf")
    public static let extraBold = PaletteFontConvertible(name: "SUIT-ExtraBold", family: "SUIT", path: "SUIT-ExtraBold.otf")
    public static let extraLight = PaletteFontConvertible(name: "SUIT-ExtraLight", family: "SUIT", path: "SUIT-ExtraLight.otf")
    public static let heavy = PaletteFontConvertible(name: "SUIT-Heavy", family: "SUIT", path: "SUIT-Heavy.otf")
    public static let light = PaletteFontConvertible(name: "SUIT-Light", family: "SUIT", path: "SUIT-Light.otf")
    public static let medium = PaletteFontConvertible(name: "SUIT-Medium", family: "SUIT", path: "SUIT-Medium.otf")
    public static let regular = PaletteFontConvertible(name: "SUIT-Regular", family: "SUIT", path: "SUIT-Regular.otf")
    public static let semiBold = PaletteFontConvertible(name: "SUIT-SemiBold", family: "SUIT", path: "SUIT-SemiBold.otf")
    public static let thin = PaletteFontConvertible(name: "SUIT-Thin", family: "SUIT", path: "SUIT-Thin.otf")
    public static let all: [PaletteFontConvertible] = [bold, extraBold, extraLight, heavy, light, medium, regular, semiBold, thin]
  }
  public static let allCustomFonts: [PaletteFontConvertible] = [Pretendard.all, Suit.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct PaletteFontConvertible {
  public let name: String
  public let family: String
  public let path: String

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    #if os(macOS)
    return SwiftUI.Font.custom(font.fontName, size: font.pointSize)
    #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    return SwiftUI.Font(font)
    #endif
  }
  #endif

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return Bundle.module.url(forResource: path, withExtension: nil)
  }
}

public extension PaletteFontConvertible.Font {
  convenience init?(font: PaletteFontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(macOS)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}
// swiftlint:enable all
// swiftformat:enable all
