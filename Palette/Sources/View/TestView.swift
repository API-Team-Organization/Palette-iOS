import SwiftUI

struct TestView: View {
    @State var selectedNumbers: Set<Int> = []
        
        var body: some View {
            VStack {
                Spacer()
                CoordinateGridBox(width: 3, height: 3, maxCount: 1, selectedNumbers: $selectedNumbers)
        }
    }
}
