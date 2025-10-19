
import SwiftUI

struct LoginView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex:"#FFF5F7"), LFColor.surface],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 24) {
                Text("LoveFit").font(LFFont.title(36)).foregroundColor(LFColor.primary)
                Text("Start Your Heartbeat Journey")
                    .font(LFFont.body(16)).foregroundColor(LFColor.textAccent)
                VStack(spacing: 12) {
                    TextField("Email", text: .constant("")).textFieldStyle(.roundedBorder)
                    SecureField("Password", text: .constant("")).textFieldStyle(.roundedBorder)
                }.padding(.horizontal, 24)
                LFPrimaryButton(title: "Login") {}
                Button("Create account"){}.foregroundColor(LFColor.primary)
            }.padding()
        }
    }
}
