//
//  SignUpView.swift
//  LoveFit
//
//  Created by Anna Huang on 10/23/25.
//
import SwiftUI

struct SignUpView: View {
    var body: some View {
        ZStack {
            LFColor.mainGradient.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("LoveFit").font(LFFont.title(36)).foregroundColor(LFColor.primary)
                Text("Start Your Heartbeat Journey")
                    .font(LFFont.body(16)).foregroundColor(LFColor.textAccent)
                VStack(spacing: 12) {
                    TextField("Avatar", text: .constant("")).textFieldStyle(.roundedBorder)
                    TextField("Email", text: .constant("")).textFieldStyle(.roundedBorder)
                    TextField("Confirm Email", text: .constant("")).textFieldStyle(.roundedBorder)
                    TextField("Username", text: .constant("")).textFieldStyle(.roundedBorder)
                    SecureField("Password", text: .constant("")).textFieldStyle(.roundedBorder)
                }.padding(.horizontal, 24)
                LFPrimaryButton(title: "Login") {}
                Button("Create account"){}.foregroundColor(LFColor.primary)
            }.padding()
        }
    }
}
