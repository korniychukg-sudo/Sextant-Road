import SwiftUI

enum Sea {
    static let paper = Color(red: 0.929, green: 0.894, blue: 0.824)
    static let paperDeep = Color(red: 0.875, green: 0.827, blue: 0.737)
    static let card = Color(red: 0.961, green: 0.933, blue: 0.878)
    static let cardSunk = Color(red: 0.906, green: 0.867, blue: 0.796)

    static let ink = Color(red: 0.114, green: 0.157, blue: 0.208)
    static let inkSoft = Color(red: 0.227, green: 0.290, blue: 0.349)
    static let inkPale = Color(red: 0.435, green: 0.490, blue: 0.545)

    static let brass = Color(red: 0.690, green: 0.541, blue: 0.243)
    static let brassLight = Color(red: 0.851, green: 0.714, blue: 0.396)
    static let oxblood = Color(red: 0.545, green: 0.239, blue: 0.180)
    static let wave = Color(red: 0.302, green: 0.427, blue: 0.510)
    static let deep = Color(red: 0.184, green: 0.290, blue: 0.376)
    static let moss = Color(red: 0.353, green: 0.435, blue: 0.353)

    static let hairline = Color(red: 0.114, green: 0.157, blue: 0.208).opacity(0.16)
}

enum SeaFont {
    static func title(_ size: CGFloat) -> Font { .custom("Georgia-Bold", size: size) }
    static func body(_ size: CGFloat) -> Font { .custom("Georgia", size: size) }
    static func italic(_ size: CGFloat) -> Font { .custom("Georgia-Italic", size: size) }
    static func mono(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold, design: .monospaced) }
}

struct SeaMetrics {
    static var isPad: Bool { UIScreen.main.bounds.width >= 700 }
    static var contentWidth: CGFloat { isPad ? 660 : UIScreen.main.bounds.width }
    static var gutter: CGFloat { isPad ? 34 : 18 }
    static func scaled(_ v: CGFloat) -> CGFloat { isPad ? v * 1.16 : v }
}

extension View {
    func seaPage() -> some View {
        self.background(Sea.paper.ignoresSafeArea())
    }

    func centreColumn() -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            self.frame(maxWidth: SeaMetrics.contentWidth)
            Spacer(minLength: 0)
        }
    }
}
