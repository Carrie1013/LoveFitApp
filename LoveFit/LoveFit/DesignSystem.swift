
import SwiftUI

extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0; Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int>>8)*17, (int>>4 & 0xF)*17, (int & 0xF)*17)
        case 6: (a, r, g, b) = (255, int>>16, int>>8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int>>24, int>>16 & 0xFF, int>>8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 255, 255, 255)
        }
        self = Color(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

enum LFColor {
    static let primary        = Color(hex: "#FF5C70")
    static let primaryDark    = Color(hex: "#FF2F5B")
    static let bg             = Color(hex: "#FFF9FA")
    static let surface        = Color(hex: "#FFE3E8")
    static let border         = Color(hex: "#BFBFC2")
    static let textMain       = Color(hex: "#2C2C2C")
    static let textAccent     = Color(hex: "#FF7B8E")
    static let highlight      = Color(hex: "#FFB84C")
}

enum LFFont {
    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func body(_ size: CGFloat)  -> Font { .system(size: size, weight: .regular, design: .rounded) }
}
