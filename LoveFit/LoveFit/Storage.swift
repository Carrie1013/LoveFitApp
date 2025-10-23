//
//  Storage.swift
//  LoveFit
//
//  Created by Anna Huang on 10/23/25.
//

import FirebaseStorage
import AVFoundation
import FirebaseFirestore

func uploadVoiceFile(fileURL: URL, completion: @escaping (URL?) -> Void) {
    let storageRef = Storage.storage().reference()
    let fileName = "voices/\(UUID().uuidString).m4a"
    let audioRef = storageRef.child(fileName)

    audioRef.putFile(from: fileURL, metadata: nil) { metadata, error in
        guard error == nil else {
            print("Upload error:", error!)
            completion(nil)
            return
        }
        // 取得下载连结
        audioRef.downloadURL { url, _ in
            completion(url)
        }
    }
}

func playVoice(from url: URL) {
    let playerItem = AVPlayerItem(url: url)
    let player = AVPlayer(playerItem: playerItem)
    player.play()
}



struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let text: String
    let audioURL: String?
    let isUser: Bool
    let timestamp: Date
}

func saveMessage(_ message: ChatMessage) {
    let db = Firestore.firestore()
    do {
        let ref = try db.collection("messages").addDocument(from: message)
        print("✅ Message saved with ID: \(ref.documentID)")
    } catch {
        print("⚠️ Failed to save message: \(error.localizedDescription)")
    }
}

func listenMessages(completion: @escaping ([ChatMessage]) -> Void) {
    let db = Firestore.firestore()
    db.collection("messages")
        .order(by: "timestamp")
        .addSnapshotListener { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let newMessages = documents.compactMap {
                try? $0.data(as: ChatMessage.self)
            }
            completion(newMessages)
        }
}


