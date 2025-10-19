import SwiftUI

struct LoveFitAppView: View {
    @State private var tab = 0
    private let barHeight: CGFloat = 84  // 你的底欄可視高度

    var body: some View {
        NavigationStack {
            content
                // iOS 17：讓內容自動為底欄留空
                .contentMargins(.bottom, barHeight)

                // 把底欄插到安全區底部（會自動貼底，不會把它擠掉）
                .safeAreaInset(edge: .bottom) {
                    GeometryReader { geo in
                        LFBottomNav(tab: $tab)
                            .frame(height: barHeight)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            // 依裝置安全區自動補底部間距（Home indicator）
                            .padding(.bottom, max(8, geo.safeAreaInsets.bottom))
                            .background(.ultraThinMaterial)
                    }
                    .frame(height: barHeight) // 這一層的高度保持為內容高（safeArea 額外 padding 在內部處理）
                }
        }
        // 🔴 關鍵：鍵盤出現時，不讓底欄被往上頂
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(LFColor.bg.ignoresSafeArea())
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case 0: DashboardView()
        case 1: StoryView()
        case 2: WorkoutView()
        case 3: FoodRecordView()
        default: ProfileCGView()
        }
    }
}
