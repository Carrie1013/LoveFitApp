//
//  APIManager.swift
//  LoveFit
//
//  Created by 乔初逢 on 10/16/25.
//


import Foundation

class APIManager: ObservableObject {
    private let baseURL = "http://10.228.17.21:5001/api" // important: 确保手机和电脑在同一WiFi
    
    func submitWorkoutData(type: String, distance: Double, duration: Int, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user-progress") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "type": type,
            "distance": distance,
            "duration": duration
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                completion(.success(json))
            }
        }.resume()
    }
}
