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
    let backgroundImage: String?
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
            text: "(Start here)\n\nYou're at the edge of a forest park. Legend says a \"Jade Amulet\" is hidden here. As you warm up, a man in a dark green hoodie approaches. He looks friendly but tired.",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),

        StorySegment(
            runTime: 0,
            title: "The Beginning",
            text: "Stranger:\n Hey, looking for the Jade Amulet? I'm Riley. I have a map, but it's easy to get lost. Let's team up? I know some clues.",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),

        StorySegment(
            runTime: 0,
            title: "The Beginning",
            text: "He shows you an old, faded map piece.\n\nYour Goal: Work with Riley. Follow the clues to find the hidden Jade Amulet.",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),

        StorySegment(
            runTime: 0,
            title: "The Beginning",
            text: "You start a light jog. Riley keeps pace beside you.",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),

        StorySegment(
            runTime: 0,
            title: "The Beginning",
            text: "\"Great,\" Riley says. \"We found the first hint!\"\n'First clue: Where the sundial's shadow points north, begin under the stone lion's gaze.'",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),
        
        // First 5 minutes
        StorySegment(
            runTime: 1,
            title: "First Clue",
            text: "Riley says, \"I know where the sundial is. This way!\"",
            options: ["Go LEFT toward sundial", "Go RIGHT, shorter path"],
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "scene2"
        ),

        StorySegment(
            runTime: 1,
            title: "Stone Lion",
            text: "You follow the path. A weathered stone lion statue comes into view.",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "scene2"
        ),

        // 5-10 minutes
        StorySegment(
            runTime: 2,
            title: "Stone Lion",
            text: "New Hint: \nA word is carved on its base: \"TRUST\". \nRiley thinks: \n \"'TRUST'... Let's remember that.\"",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "scene2"
        ),
        
        // Heart Rate Warning
        StorySegment(
            runTime: 2,
            title: "Heart Rate High!",
            text: "Riley looks concerned. 'Hey! Your heart rate is too high! Walk fast for 2 minutes, or do 10 push-ups. Then we can run again.'",
            options: nil,
            isHeartRateWarning: true,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "scene3"
        ),

        StorySegment(
            runTime: 2,
            title: "Heart Rate High!",
            text: "System: \nSwitch to brisk walking or do 10 push-ups",
            options: ["Switch to Walking", "Do Push-ups"],
            isHeartRateWarning: true,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "scene3"
        ),
        
        // Continue story...
        StorySegment(
            runTime: 3,
            title: "Greenhouse",
            text: "You reach an old greenhouse. A rusty lock is on the door.",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),

        StorySegment(
            runTime: 3,
            title: "Greenhouse",
            text: "Riley pulls out an old key.\n \"A lucky find at a flea market.\" \nHe unlocks it easily.",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),

        StorySegment(
            runTime: 3,
            title: "Greenhouse",
            text: "New Hint:\nInside, on a mosaic tile, a phrase: \n\"BUT DECEIT IS THE KEY.\"",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),

        StorySegment(
            runTime: 3,
            title: "Greenhouse",
            text: "Riley reads it quietly. \n\"'DECEIT IS THE KEY'... Strange, paired with 'TRUST', right?\"",
            options: nil,
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),

        StorySegment(
            runTime: 4,
            title: "Greenhouse",
            text: "You feel a bit uneasy about the convenient key.",
            options: ["Agree - weird", "Disagree - suspicious"],
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: false,
            backgroundImage: "riley"
        ),
        
        // Chase Scene
        StorySegment(
            runTime: 4,
            title: "THE TRUTH",
            text: "TRUST... BUT DECEIT IS THE KEY... HIS GUIDANCE LEADS TO THE END... It's YOU Riley! He smiles coldly. 'Clever. Too late.' RUN! NOW! MAXIMUM EFFORT! ESCAPE!",
            options: ["SPRINT TO ESCAPE!"],
            isHeartRateWarning: false,
            isChaseScene: true,
            isFinale: false,
            backgroundImage: "riley"
        ),
        
        // Finale
        StorySegment(
            runTime: 5,
            title: "The Joke",
            text: "You burst out of the trees, exhausted. Riley walks out, holding a camera. Others are laughing. 'Sorry! We're a Fitness Story studio! The killer plot was motivation! Congrats Survivor!'",
            options: ["Finish Adventure"],
            isHeartRateWarning: false,
            isChaseScene: false,
            isFinale: true,
            backgroundImage: "riley"
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