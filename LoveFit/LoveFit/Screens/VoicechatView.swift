import SwiftUI
import AVFoundation

struct VoiceChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hey there! Ready to start your workout?", isUser: false)
    ]
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?

    var body: some View {
        VStack(spacing: 16) {
            // 🔹 Title
            Text("Workout")
                .font(LFFont.title(28))
                .frame(maxWidth: .infinity, alignment: .leading)

            // 🔹 Chat bubbles
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
            }
            .frame(maxHeight: 400)

            Spacer()

            // 🔹 Text field + mic button
            HStack(spacing: 12) {
                TextField("Say something...", text: .constant(""))
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 1)

                Button(action: toggleRecording) {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 24))
                        .foregroundColor(isRecording ? .red : LFColor.mainGradientEnd)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(50)
                        .shadow(radius: 2)
                }
            }
        }
        .padding()
        .background(LFColor.backgroundGradient.ignoresSafeArea())
    }

    // 🔸 Toggle microphone
    private func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            startRecording()
        } else {
            stopRecordingAndSend()
        }
    }

    private func startRecording() {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("voice.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Recording failed: \(error)")
        }
    }

    private func stopRecordingAndSend() {
        audioRecorder?.stop()
        guard let fileURL = audioRecorder?.url else { return }
        sendAudioToBackend(fileURL: fileURL)
    }

    // 🧠 Send audio to backend for processing
    private func sendAudioToBackend(fileURL: URL) {
        // TODO: upload to backend (e.g., Flask/FastAPI)
        // Example:
        // 1. POST /api/voice-chat with multipart/form-data
        // 2. Server transcribes speech → LLM generates reply text → text-to-speech
        // 3. Returns JSON: { "reply": "Nice job!", "audio_url": "https://..." }

        // Mock result for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let reply = ChatMessage(text: "You sound great! Let’s crush your next set 💪", isUser: false)
            messages.append(reply)
            playReplyVoice()
        }
    }

    private func playReplyVoice() {
        guard let soundURL = Bundle.main.url(forResource: "reply_voice", withExtension: "m4a") else { return }
        var player: AVAudioPlayer?
        player = try? AVAudioPlayer(contentsOf: soundURL)
        player?.play()
    }
}

