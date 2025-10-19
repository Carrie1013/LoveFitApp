
import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(spacing:16) {
            Text("Dashboard").font(LFFont.title(28)).frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing:16) {
                LFCard { Text("Calories\n1000 kcal") }
                LFCard { Text("Favor\n780 pts") }
            }
            HStack(spacing:16) {
                LFCard { Text("Proteins\n300 g") }
                LFCard { Text("Sugar\n30g") }
                LFCard { Text("Fat\n10g") }
            }
            LFCard { Text("User, you worked pretty well today! Burnt 1000 kcal.") }
            Spacer()
        }.padding()
    }
}
