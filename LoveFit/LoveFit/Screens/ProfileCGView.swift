
import SwiftUI

struct ProfileCGView: View {
    let cols = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ScrollView {
            LFCard {
                HStack {
                    Circle().fill(LFColor.surface).frame(width:64, height:64)
                    VStack(alignment:.leading) {
                        Text("Anna").font(LFFont.title(22))
                        Text("12 lbs away!").foregroundColor(LFColor.primary)
                    }
                    Spacer()
                }
            }
            LazyVGrid(columns: cols, spacing: 12) {
                ForEach(0..<9) { _ in
                    RoundedRectangle(cornerRadius: 12).fill(LFColor.surface).frame(height:110)
                }
            }.padding(.top, 8)
        }.padding()
    }
}
