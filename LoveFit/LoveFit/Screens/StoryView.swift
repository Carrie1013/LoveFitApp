import SwiftUI
import Combine

struct StoryView: View {
    @StateObject private var manager = StoryManager()
    @StateObject private var hr = MockHeartRateManager()
    
    // 🕒 狀態管理
    @State private var countdown = 15
    @State private var isCountingDown = false
    @State private var isSectionUnlocked = false

    // 💓 心跳波動畫
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 1️⃣ 背景 CG
            Image("riley")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea(edges: [.top])

            // 2️⃣ 心跳波
            HeartWave(amplitude: CGFloat(mapHeartRateToAmplitude(hr.currentHeartRate)),
                      phase: wavePhase)
                .stroke(LinearGradient(colors: [.red, .pink],
                                       startPoint: .leading, endPoint: .trailing),
                        lineWidth: 3)
                .frame(height: 120)
                .padding(.horizontal, 30)
                .opacity(0.8)
                .blendMode(.screen)
                .offset(y: -40)

            // 3️⃣ 劇情容器
            VStack(spacing: 12) {
                Spacer()

                VStack(spacing: 12) {
                    // Title
                    Text(manager.currentSegment.title)
                        .font(LFFont.title(22))
                        .foregroundColor(LFColor.textMain)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Dialogue
                    Text(manager.currentSegment.text)
                        .font(LFFont.body(17))
                        .foregroundColor(.black)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3)))
                        .transition(.opacity)
                        .animation(.easeInOut, value: manager.currentSegment.id)
                    
                    // Option buttons
                    if let opts = manager.currentSegment.options, !opts.isEmpty {
                        HStack(spacing: 12) {
                            ForEach(opts, id: \.self) { opt in
                                Button(opt) {
                                    manager.choose(opt)
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(colors: [LFColor.primary, LFColor.primaryDark],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .foregroundColor(.white)
                            }
                        }
                    } else {
                        Button(manager.currentSegment.isFinale ? "Finish" : "Next") {
                            handleNextPress()
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [LFColor.primary, LFColor.primaryDark],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .foregroundColor(.white)
                    }
                    
                    // Heart rate + countdown timer
                    HStack {
                        Text("❤️ \(Int(hr.currentHeartRate)) BPM")
                            .font(.headline)
                            .foregroundColor(.red)
                        Spacer()
                        
                        // ⏳ 倒數顯示
                        Text(String(format: "⏳ %02d", countdown))
                            .font(.headline)
                            .foregroundColor(countdown <= 5 ? .red : .gray)
                            .monospacedDigit()
                        
                        // 控制鍵（暫停 / 播放）
                        Button(action: { isCountingDown.toggle() }) {
                            Image(systemName: isCountingDown ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 24))
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .shadow(radius: 12)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            hr.start()
            manager.startRun()
            isCountingDown = true // ✅ 啟動第一章節倒數
        }
        .onReceive(ticker) { _ in
            tickUpdate()
        }
    }
    
    // MARK: - 🔧 邏輯處理區
    
    private func tickUpdate() {
        // 倒數邏輯
        if isCountingDown && countdown > 0 {
            countdown -= 1
        } else if isCountingDown && countdown == 0 && !isSectionUnlocked {
            // 🔓 解鎖下一章
            isSectionUnlocked = true
            isCountingDown = false
        }
        
        // 心跳動畫
        if manager.isRunning {
            withAnimation(.linear(duration: 0.5)) {
                wavePhase -= .pi / 8
            }
        }
    }
    
    private func handleNextPress() {
        // 判斷下一段是否存在
        guard manager.currentSegmentIndex + 1 < manager.storySegments.count else { return }
        let next = manager.storySegments[manager.currentSegmentIndex + 1]
        
        // ✅ 同章節（runtime 相同）可直接顯示
        if next.runTime == manager.currentSegment.runTime {
            manager.nextSegment()
        } else {
            // 🚫 下一章節鎖定時阻擋
            if isSectionUnlocked {
                manager.nextSegment()
                startNextSectionCountdown()
            } else {
                print("⏳ Workout not finished yet.")
            }
        }
    }
    
    private func startNextSectionCountdown() {
        countdown = 15
        isCountingDown = true
        isSectionUnlocked = false
    }
    
    private func mapHeartRateToAmplitude(_ bpm: Double) -> Double {
        min(max((bpm - 60) / 2, 10), 50)
    }
}