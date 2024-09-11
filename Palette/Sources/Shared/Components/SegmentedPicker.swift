import SwiftUI

struct SegmentedPicker: View {
    @Binding var preselectedIndex: Int
    var options: [String]
    let selectedColor = Color("SelectedTabColor")
    let descTextColor = Color("DescText")
    let selectedTextColor = Color("ButtonBG")

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                ZStack {
                    Rectangle()
                        .fill(preselectedIndex == index ? selectedColor : Color.white)
                        .cornerRadius(12)
                        .padding(3)
                    Text(options[index])
                        .font(.custom("SUIT-Bold", size: 15))
                        .foregroundColor(preselectedIndex == index ? selectedTextColor : descTextColor)
                        .zIndex(1) // Ensure text is on top
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        preselectedIndex = index
                    }
                }
            }
        }
        .frame(width: 350, height: 52)
        .background(Color.white)
        .cornerRadius(12)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: preselectedIndex)
    }
}
