
import SwiftUI

struct FoodRecordView: View {
    var body: some View {
        VStack(spacing:12){
            LFCard { Text("Today's Meal Score 85/100 💪 Balanced!") }
            ScrollView {
                VStack(alignment:.leading, spacing:10){
                    bubble("我午餐吃了雞胸肉飯", me: true)
                    bubble("你的餐點約 500 卡、蛋白質 30g，很不錯喔 ❤️", me: false)
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
