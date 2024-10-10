import SwiftUI

struct TestView: View {
    @State var selectedNumbers: Set<Int> = []
        
        var body: some View {
            VStack {
                Spacer()
                CoordinateGridBox(width: 4, height: 5, selectedNumbers: $selectedNumbers)
//                Text("Selected: \(selectedNumbers.sorted().map { String($0) }.joined(separator: ", "))")
        }
    }
}
