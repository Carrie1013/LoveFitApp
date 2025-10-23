//
//  AppRootView.swift
//  LoveFit
//
//  Created by Anna Huang on 10/23/25.
//

import SwiftUI

struct AppRootView: View {
    @State private var isLoggedIn = false   // control state

    var body: some View {
        if isLoggedIn {
            LoveFitAppView()                 // show main app
        } else {
            LoginView(onLoginSuccess: {
                withAnimation(.easeInOut) {
                    isLoggedIn = true
                }
            })
        }
    }
}
