
import SwiftUI

struct LFPrimaryButton: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(LFFont.body(17)).foregroundColor(.white)
                .frame(maxWidth: 150, minHeight: 52)
                .background(
                    LinearGradient(colors: [LFColor.primary, LFColor.primaryDark],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(16)
                .shadow(color: LFColor.primary.opacity(0.25), radius: 10, y: 6)
        }
    }
}

struct LFCard<Content: View>: View {
    var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(.white))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(LFColor.surface, lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }
}

struct LFDialog: View {
    var text: String
    var body: some View {
        Text(text)
            .font(LFFont.body(16))
            .foregroundColor(LFColor.textMain)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 20).fill(LFColor.surface))
            .overlay(
                Image(systemName: "heart.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(LFColor.primary)
                    .offset(x: -8, y: -8),
                alignment: .topTrailing
            )
    }
}

struct LFBottomNav: View {
    @Binding var tab: Int
    var body: some View {
        HStack(spacing: 0) {
            navItem(icon: "house.fill",  index: 0, label: "Home")
            navItem(icon: "book.fill",   index: 1, label: "Story")
            navItem(icon: "figure.walk", index: 2, label: "Workout")
            navItem(icon: "fork.knife",  index: 3, label: "Food")
            navItem(icon: "person.fill", index: 4, label: "Profile")
        }
        .padding(.top, 12)
        .padding(.bottom, 12)                // 內容內距保留
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: LFColor.primary.opacity(0.2), radius: 10, y: -2)
        .padding(.horizontal, 16)            // 底部 padding 交給外層 GeometryReader 處理
    }

    private func navItem(icon: String, index: Int, label: String) -> some View {
        Button { tab = index } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(tab == index ? LFColor.primary : LFColor.border)
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(tab == index ? LFColor.primary : LFColor.border)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // 提升點擊容忍度
        }
    }
}



struct HeartWave: Shape {
    var amplitude: CGFloat
    var phase: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let midY = rect.midY

        path.move(to: .zero)
        for x in stride(from: 0, through: width, by: 2) {
            let relativeX = x / width
            let y = midY + sin(relativeX * .pi * 4 + phase) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(amplitude, phase) }
        set {
            amplitude = newValue.first
            phase = newValue.second
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .padding(12)
                .foregroundColor(message.isUser ? .white : LFColor.textMain)
                .background(message.isUser ? LFColor.mainGradientEnd : Color.white)
                .cornerRadius(16)
                .shadow(radius: 1)
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
