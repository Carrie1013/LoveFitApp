
import SwiftUI

struct WorkoutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Workout").font(LFFont.title(28)).frame(maxWidth: .infinity, alignment: .leading)
            LFCard { Text("Timer / Sets / Reps") }
            LFPrimaryButton(title: "Start") {}
            Spacer()
        }.padding()
    }
}
