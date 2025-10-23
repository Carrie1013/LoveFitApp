//
//  LoveFitApp.swift
//  LoveFit
//
//  Created by 乔初逢 on 10/16/25.
//

import SwiftUI
import Firebase

@main
struct LoveFitApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
