import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var apiManager = APIManager()
    @State private var unlockedStories: [String] = []
    @State private var debugMessage: String = "Click the Sync button to start."
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Unlock the plot through sports.")
                    .font(.title)
                    .padding()
                
                Text(debugMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // 测试网络连接按钮
                Button("Test server connection") {
                    testServerConnection()
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                
                // 同步运动数据按钮
                Button("Synchronize motion data") {
                    syncWorkoutData()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                // 模拟数据测试按钮
                Button("Test with mock data") {
                    testWithMockData()
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                // 暂无解锁的剧情
                if unlockedStories.isEmpty {
                    Text("Unlocked stories not found.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(unlockedStories, id: \.self) { story in
                        Text("🎉 Unlocked story: \(story)")
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            healthKitManager.requestAuthorization { success in
                DispatchQueue.main.async {
                    if success {
                        // 已授权访问健康数据
                        debugMessage = "✅ Authorized access to health data."
                    } else {
                        // 请在健康App中允许LoveFit访问运动数据
                        debugMessage = "⚠️ Please allow LoveFit to access exercise data in the health App."
                    }
                }
            }}
    }
    
    // 测试服务器连接
    private func testServerConnection() {
        debugMessage = "Testing server connection..."
        
        guard let url = URL(string: "http://10.228.17.21:5001/api/test") else {
            debugMessage = "❌ Wrong URL format"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.debugMessage = "❌ Connection failed: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.debugMessage = "✅ Server Connected!"
                    } else {
                        self.debugMessage = "❌ The server returned error: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
    
    // 使用模拟数据测试
    private func testWithMockData() {
        debugMessage = "Testing with mock data..."
        
        // 模拟跑步数据 - 100米，10分钟（能解锁story_1）
        apiManager.submitWorkoutData(type: "running", distance: 1000, duration: 600) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Mock data respond: \(response)")
                    if let newStories = response["newly_unlocked"] as? [String], !newStories.isEmpty {
                        self.unlockedStories.append(contentsOf: newStories)
                        self.debugMessage = "🎉 Mock data successfully unlock story: \(newStories.joined(separator: ", "))"
                    } else {
                        self.debugMessage = "⚠️ Mock data successfully synchronized，but new unlocked story not found."
                        // 显示当前进度
                        if let progress = response["total_progress"] as? [String: Any] {
                            print("Current progress: \(progress)")
                        }
                    }
                case .failure(let error):
                    self.debugMessage = "❌ Simulation data failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func syncWorkoutData() {
        debugMessage = "Fetching workouts data..."
        
        healthKitManager.fetchRecentWorkouts { workouts in
            DispatchQueue.main.async {
                guard let workouts = workouts, !workouts.isEmpty else {
                    self.debugMessage = "❌ No workouts data was found. Please add some test records in the Health App."
                    return
                }
                
                self.debugMessage = "📊 Found \(workouts.count) workouts record，synchronizing..."
                self.processWorkouts(workouts)
            }
        }
    }
    
    private func processWorkouts(_ workouts: [HKWorkout]) {
        let recentWorkouts = Array(workouts.prefix(3))
        var processedCount = 0
        
        for workout in recentWorkouts {
            let type = workoutTypeToString(workout.workoutActivityType)
            let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0
            let duration = Int(workout.duration)
            
            print("processing workout: \(type), distance: \(distance)m, duration: \(duration)s")
            
            apiManager.submitWorkoutData(
                type: type,
                distance: distance,
                duration: duration
            ) { result in
                processedCount += 1
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        print("✅ Motion data response: \(response)")
                        if let newStories = response["newly_unlocked"] as? [String], !newStories.isEmpty {
                            self.unlockedStories.append(contentsOf: newStories)
                            self.debugMessage = "🎉 New unlocked story: \(newStories.joined(separator: ", "))"
                        }
                        
                        if processedCount == recentWorkouts.count {
                            if self.unlockedStories.isEmpty {
                                self.debugMessage = "✅ All data synchronization has been completed, but no new plot has been unlocked."
                            }
                        }
                        
                    case .failure(let error):
                        self.debugMessage = "❌ Submission failed: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    private func workoutTypeToString(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running: return "running"
        case .walking: return "walking"
        case .hiking: return "hiking"
        case .cycling: return "cycling"
        default: return "other"
        }
    }
}
