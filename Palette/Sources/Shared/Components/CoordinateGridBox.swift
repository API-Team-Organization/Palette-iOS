import SwiftUI

struct CoordinateGridBox: View {
    let width: Int
    let height: Int
    @Binding var selectedNumbers: Set<Int>
    @GestureState private var dragState = DragState.inactive
    @State private var isDragging = false
    @State private var lastDraggedNumber: Int?
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(0..<height, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<width, id: \.self) { column in
                        let number = row * width + column
                        cellView(for: number)
                    }
                }
            }
        }
        .padding(6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .frame(width: 230, height: 230)
        .gesture(dragGesture)
    }
    
    private func cellView(for number: Int) -> some View {
        let isSelected = selectedNumbers.contains(number)
        return ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
            
            Circle()
                .fill(Color.white)
                .frame(width: isSelected ? 16 : 12,
                       height: isSelected ? 17 : 14)
        }
        .contentShape(Rectangle())
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragState) { (value, state, _) in
                state = .dragging(translation: value.translation)
                updateSelectionForDrag(at: value.location)
            }
            .onChanged { _ in
                isDragging = true
            }
            .onEnded { _ in
                isDragging = false
                lastDraggedNumber = nil
            }
    }
    
    private func updateSelectionForDrag(at location: CGPoint) {
        guard let number = getNumberForLocation(location) else { return }
        if number != lastDraggedNumber {
            toggleSelection(number)
            lastDraggedNumber = number
        }
    }
    
    private func toggleSelection(_ number: Int) {
        if selectedNumbers.contains(number) {
            selectedNumbers.remove(number)
        } else {
            selectedNumbers.insert(number)
        }
    }
    
    private func getNumberForLocation(_ location: CGPoint) -> Int? {
        let cellWidth = 230 / CGFloat(width)
        let cellHeight = 230 / CGFloat(height)
        let column = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)
        if column >= 0 && column < width && row >= 0 && row < height {
            return row * width + column
        }
        return nil
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
}

struct CoordinateGridBox_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selectedNumbers: Set<Int> = []
        
        var body: some View {
            VStack {
                Spacer()
                CoordinateGridBox(width: 4, height: 5, selectedNumbers: $selectedNumbers)
                Text("Selected: \(selectedNumbers.sorted().map { String($0) }.joined(separator: ", "))")
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
