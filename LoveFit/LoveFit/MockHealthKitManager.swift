import SwiftUI
import Combine

// ── Mock 版本（iPad / 沒有 HealthKit 時用）
final class MockHeartRateManager: ObservableObject {
    @Published var currentHeartRate: Double = 70
    private var timer: AnyCancellable?

    func start() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.currentHeartRate = Double.random(in: 65...160) }
    }
    func stop() { timer?.cancel() }
}
