import Foundation
import Combine

struct StorySegment: Identifiable {
    let id = UUID()
    let runTime: Int // in minutes
    let title: String
    let text: String
    let options: [String]?
    let isHeartRateWarning: Bool
    let isChaseScene: Bool
    let isFinale: Bool
}

class StoryManager: ObservableObject {
    @Published var currentSegmentIndex = 0
    @Published var isRunning = false
    @Published var elapsedTime = 0 // in seconds
    @Published var selectedOption: String? = nil
    
    let storySegments: [StorySegment] = [
        // Start
        StorySegment(
            runTime: 0,
            title: "The Beginning",
            text: "You're at the edge of a forest park. Legend says a Jade Amulet is hidden here. A man in a green hoodie approaches. 'Hey, looking for the Jade Amulet? I'm Riley. Let's team up? I know some clues.'",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false
        ),
        
        // First 5 minutes
        StorySegment(
            runTime: 5,
            title: "First Clue",
            text: "'First clue: Where the sundial's shadow points north, begin under the stone lion's gaze.' I know where the sundial is. This way!",
            options: ["Go LEFT toward sundial", "Go RIGHT, shorter path"],
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false
        ),
        
        // 5-10 minutes
        StorySegment(
            runTime: 10,
            title: "Stone Lion",
            text: "You see a weathered stone lion statue. A word is carved on its base: TRUST. Riley says: 'TRUST... Let's remember that.'",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false
        ),
        
        // Heart Rate Warning
        StorySegment(
            runTime: 10,
            title: "Heart Rate High!",
            text: "Riley looks concerned. 'Hey! Your heart rate is too high! Walk fast for 2 minutes, or do 10 push-ups. Then we can run again.'",
            options: ["Switch to Walking", "Do Push-ups"],
            isHeartRateWarning: true,
            isChaseScene: false,
            isFinale: false
        ),
        
        // Continue story...
        StorySegment(
            runTime: 15,
            title: "Greenhouse",
            text: "You reach an old greenhouse. Riley unlocks it with a 'lucky' key. Inside, a mosaic tile says: BUT DECEIT IS THE KEY.",
            options: ["Agree - weird", "Disagree - suspicious"],
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false
        ),
        
        // Chase Scene
        StorySegment(
            runTime: 25,
            title: "THE TRUTH",
            text: "TRUST... BUT DECEIT IS THE KEY... HIS GUIDANCE LEADS TO THE END... It's YOU Riley! He smiles coldly. 'Clever. Too late.' RUN! NOW! MAXIMUM EFFORT! ESCAPE!",
            options: ["SPRINT TO ESCAPE!"],
            isHeartRateWarning: false,
            isChaseScene: true,
            isFinale: false
        ),
        
        // Finale
        StorySegment(
            runTime: 30,
            title: "The Joke",
            text: "You burst out of the trees, exhausted. Riley walks out, holding a camera. Others are laughing. 'Sorry! We're a Fitness Story studio! The killer plot was motivation! Congrats Survivor!'",
            options: ["Finish Adventure"],
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: true
        )
    ]
    
    var currentSegment: StorySegment {
        guard currentSegmentIndex < storySegments.count else {
            return storySegments.last!
        }
        return storySegments[currentSegmentIndex]
    }

    var elapsedMinutes: Int { elapsedTime / 60 }

    /// Pick the last segment whose runTime <= elapsedMinutes
    func updateSegmentForElapsedIfNeeded() {
        if let idx = storySegments.lastIndex(where: { $0.runTime <= elapsedMinutes }) {
            if idx != currentSegmentIndex { currentSegmentIndex = idx }
        }
    }

    func choose(_ option: String) {
        selectedOption = option
        nextSegment()
    }
    
    func nextSegment() {
        if currentSegmentIndex < storySegments.count - 1 {
            currentSegmentIndex += 1
        }
    }
    
    func startRun() {
        isRunning = true
        currentSegmentIndex = 0
        elapsedTime = 0
        selectedOption = nil
    }

    func pause() { isRunning = false }
    
    func reset() {
        isRunning = false
        currentSegmentIndex = 0
        elapsedTime = 0
        selectedOption = nil
    }
}