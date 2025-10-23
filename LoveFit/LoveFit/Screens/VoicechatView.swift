import SwiftUI
import AVFoundation
import Firebase
import FirebaseFirestore

struct VoiceChatView: View {
    @State private var messages: [ChatMessage] = [
            ChatMessage(
                userId: "user1",
                text: "Hey there! Ready to start your workout?",
                audioURL: nil,
                isUser: false,
                timestamp: Date()
            )
        ]
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var player: AVAudioPlayer?
    @State private var inputMode: InputMode = .voice
    @State private var inputText: String = ""

    enum InputMode { case voice, text }

    var body: some View {
        VStack(spacing: 16) {
            // 🔹 Title
            Text("Chat")
                .font(LFFont.title(28))
                .frame(maxWidth: .infinity, alignment: .leading)

            // 🔹 Chat bubbles
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 400)

            Spacer()

            // 🔹 Mic button
            HStack(spacing: 12) {
                if inputMode == .text {
                    TextField("Type a message...", text: $inputText)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                    
                    Button {
                        sendTextMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(LFColor.mainGradientEnd)
                            .padding()
                    }
                } else {
                    Button(action: toggleRecording) {
                        Image(systemName: isRecording ? "mic.fill" : "mic")
                            .font(.system(size: 24))
                            .foregroundColor(isRecording ? .red : LFColor.mainGradientEnd)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }

                Button {
                    // toggle input mode
                    inputMode = (inputMode == .voice) ? .text : .voice
                } label: {
                    Image(systemName: inputMode == .voice ? "keyboard" : "waveform")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                }
            }

        }
        .padding()
        .background(LFColor.backgroundGradient.ignoresSafeArea())
    }

    // MARK: - 🎙️ Recording control
    private func toggleRecording() {
        if isRecording {
            stopRecordingAndSend()
        } else {
            startRecording()
        }
        isRecording.toggle()
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
            print("🎙️ Recording started at \(fileURL.path)")
        } catch {
            print("⚠️ Recording failed: \(error.localizedDescription)")
        }
    }

    private func stopRecordingAndSend() {
        audioRecorder?.stop()
        guard let fileURL = audioRecorder?.url else { return }
        print("✅ Recording saved to: \(fileURL.path)")

        // Upload to Firebase Storage
        uploadVoiceFile(fileURL: fileURL) { url in
            guard let url = url else { return }
            print("✅ Uploaded voice URL: \(url.absoluteString)")

            // Save user message to Firestore
            let message = ChatMessage(
                userId: "user1",
                text: "[Voice message]",
                audioURL: url.absoluteString,
                isUser: true,
                timestamp: Date()
            )
            saveMessage(message)

            // Append locally
            messages.append(message)

            // Simulate AI reply
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let reply = ChatMessage(
                    userId: "ai",
                    text: "You sound great! Let’s crush your next set 💪",
                    audioURL: nil,
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(reply)
                playReplyVoice()
            }
        }
    }

    // MARK: - 🔊 Play reply
    private func playReplyVoice() {
        guard let soundURL = Bundle.main.url(forResource: "reply_voice", withExtension: "m4a") else {
            print("⚠️ Missing reply_voice.m4a in bundle")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.play()
        } catch {
            print("⚠️ Failed to play voice: \(error.localizedDescription)")
        }
    }
    
    private func sendTextMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let message = ChatMessage(
            userId: "user1",
            text: inputText,
            audioURL: nil,
            isUser: true,
            timestamp: Date()
        )
        saveMessage(message)
        messages.append(message)
        inputText = ""

        // Simulate reply
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let reply = ChatMessage(
                userId: "ai",
                text: "I love how focused you are 💪",
                audioURL: nil,
                isUser: false,
                timestamp: Date()
            )
            messages.append(reply)
        }
    }

}

