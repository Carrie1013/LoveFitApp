
import SwiftUI

struct FoodRecordView: View {
    var body: some View {
        VStack(spacing:12){
            LFCard { Text("Today's Meal Score 85/100 💪 Balanced!") }
            ScrollView {
                VStack(alignment:.leading, spacing:10){
                    bubble("I ate cheese burger this afternoon", me: true)
                    bubble("Your meal contains about 800 kcal, Protein 30g, I'll record it for you!", me: false)
                }
            }
            // HStack {
            //     TextField("Add your meal...", text: .constant("")).textFieldStyle(.roundedBorder)
            //     Button { } label { Image(systemName: "paperplane.fill") }
            //         .padding(12).background(Circle().fill(LFColor.primary)).foregroundColor(.white)
            //}
        }.padding()
    }
    @ViewBuilder func bubble(_ text: String, me: Bool) -> some View {
        Text(text).padding(12)
            .background(RoundedRectangle(cornerRadius: 16).fill(me ? .white : LFColor.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(LFColor.surface.opacity(me ? 1 : 0)))
            .frame(maxWidth: .infinity, alignment: me ? .trailing : .leading)
    }
}
