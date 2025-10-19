import SwiftUI
import Combine

struct StoryView: View {
    @StateObject private var manager = StoryManager()
    @StateObject private var hr = MockHeartRateManager()

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var wavePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // 1️⃣ Background CG (replace with your real image)
            Image("riley") // ⬅️ put CG name in Assets.xcassets
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // 2️⃣ Heartbeat waveform overlay (center)
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

            // 3️⃣ Transparent story container (bottom)
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
                        Button(manager.currentSegment.isFinale ? "完成" : "下一段") {
                            manager.nextSegment()
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

                    // Heart rate + timer
                    HStack {
                        Text("❤️ \(Int(hr.currentHeartRate)) BPM")
                            .font(.headline)
                            .foregroundColor(.red)
                        Spacer()
                        Text(timeString(manager.elapsedTime))
                            .foregroundColor(.gray)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 4)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .shadow(radius: 12)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .onAppear { hr.start() }
        .onReceive(ticker) { _ in
            guard manager.isRunning else { return }
            manager.elapsedTime += 1
            manager.updateSegmentForElapsedIfNeeded()
            withAnimation(.linear(duration: 0.5)) {
                wavePhase -= .pi / 8
            }
        }
    }

    private func mapHeartRateToAmplitude(_ bpm: Double) -> Double {
        // Normalize heart rate → wave amplitude
        return min(max((bpm - 60) / 2, 10), 50)
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}