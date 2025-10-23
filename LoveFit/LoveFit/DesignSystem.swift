
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
    static let bg             = Color(hex: "#FFF58F")
    static let surface        = Color(hex: "#FFE3E8")
    static let border         = Color(hex: "#BFBFC2")
    static let textMain       = Color(hex: "#2C2C2C")
    static let textAccent     = Color(hex: "#FF7B8E")
    static let highlight      = Color(hex: "#FFB84C")
    
    // 🌸 Brand gradients
    static let mainGradientStart = Color(hex: "#FFB088")
    static let mainGradientEnd   = Color(hex: "#FF9A9E")

    static let yellowGradientStart = Color(hex: "#FFC76D")
    static let yellowGradientEnd   = Color(hex: "#FFEAA7")

    // 🌷 Background gradient
    static let bgTop    = Color(hex: "#FFFBF0")
    static let bgBottom = Color(hex: "#FFF5F8")

    // 🖋️ Text colors
//    static let textMain = Color(hex: "#5D5569")
//    static let textSub  = Color(hex: "#9B8FA6")

    // 🧱 Neutral & border
//    static let border = Color(hex: "#BFBFC2")

    // 🧁 Legacy fallback / compatibility
//    static let surface = Color(hex: "#FFE3E8")
}

extension LFColor {
    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [bgTop, bgBottom],
                       startPoint: .top,
                       endPoint: .bottom)
    }

    static var mainGradient: LinearGradient {
        LinearGradient(colors: [mainGradientStart, mainGradientEnd],
                       startPoint: .leading,
                       endPoint: .trailing)
    }

    static var yellowGradient: LinearGradient {
        LinearGradient(colors: [yellowGradientStart, yellowGradientEnd],
                       startPoint: .leading,
                       endPoint: .trailing)
    }
}



enum LFFont {
    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .serif) }
    static func body(_ size: CGFloat)  -> Font { .system(size: size, weight: .regular, design: .rounded) }
}
