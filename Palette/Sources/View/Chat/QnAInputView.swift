import SwiftUI

struct QnAInputView: View {
    let qna: QnAData
    let onSubmit: (AnswerDto) -> Void
    
    @State private var selectedChoice: String?
    @State private var userInput: String = ""
    @State private var selectedNumbers: Set<Int> = []
    @State private var textEditorHeight: CGFloat = 40
    @State private var isMessageValid = false
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        Group {
            switch qna.type {
            case .USER_INPUT:
                userInputView
            case .SELECTABLE:
                selectableView
            case .GRID:
                gridView
            }
        }
    }
    
    private var instructionText: String {
        switch qna.type {
        case .SELECTABLE:
            return "아래의 값중에 하나를 선택해주세요"
        case .USER_INPUT:
            return "답변을 입력해주세요."
        case .GRID:
            return "원하는 위치를 선택해주세요"
        }
    }
    
    private var selectableView: some View {
        VStack(spacing: 20) {
            HStack {
                Text(instructionText)
                    .font(.custom("SUIT-Bold", size: 18))
                    .foregroundStyle(Color.black)
                Spacer()
            }
            .padding(.leading, 27)
            .padding(.top, 20)
            
            Picker("선택", selection: $selectedChoice) {
                ForEach(qna.question.choices ?? []) { choice in
                    Text(choice.displayName).tag(choice.id as String?)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .colorScheme(.light)
            .frame(height: 150)
            .clipped()
            
            submitButton
        }
        .padding(.bottom, 20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        .frame(width: 340)
    }
    
    private var gridView: some View {
        VStack {
            Text(instructionText)
                .font(.custom("SUIT-Bold", size: 18))
                .foregroundStyle(Color.black)
                .padding(.bottom, 20)
            
            if let xSize = qna.question.xSize, let ySize = qna.question.ySize {
                CoordinateGridBox(width: xSize, height: ySize, selectedNumbers: $selectedNumbers)
                    .frame(maxWidth: 300, maxHeight: 300)
            } else {
                Text("Grid size not specified").foregroundColor(.red)
            }
            
            submitButton
        }
        .padding(.vertical, 20)
        .frame(width: 340)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
    
    private var userInputView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 10) {
                ZStack(alignment: .leading) {
                    TextEditor(text: $userInput)
                        .font(.custom("SUIT-Medium", size: 15))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .frame(height: max(40, textEditorHeight))
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .onChange(of: userInput) {
                            withAnimation {
                                updateTextEditorHeight()
                            }
                        }
                        .focused($isInputFocused)
                    
                    if userInput.isEmpty {
                        Text("당신의 Palette를 그려보세요")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .font(.custom("SUIT-Medium", size: 15))
                    }
                }
                .background(Color("ChatTextFieldBack"))
                .cornerRadius(20)
                
                Button(action: {
                    if isMessageValid {
                        submitAnswer()
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(isMessageValid ? Color("AccentColor") : Color.gray)
                        .padding(10)
                        .background(Color("ChatTextFieldBack"))
                        .clipShape(Circle())
                }
                .disabled(!isMessageValid)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color.white)
            .cornerRadius(20, corners: [.topLeft, .topRight])
        }
    }
    
    private var submitButton: some View {
        Button(action: submitAnswer) {
            Text("답변하기")
                .padding()
                .font(.custom("SUIT-Bold", size: 15))
                .frame(width: 150, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func submitAnswer() {
        let answer: AnswerDto
        switch qna.type {
        case .SELECTABLE:
            answer = AnswerDto(type: "SELECTABLE", choiceId: selectedChoice, input: nil, choice: nil)
        case .USER_INPUT:
            answer = AnswerDto(type: "USER_INPUT", choiceId: nil, input: userInput, choice: nil)
        case .GRID:
            answer = AnswerDto(type: "GRID", choiceId: nil, input: nil, choice: Array(selectedNumbers))
        }
        onSubmit(answer)
    }
    
    private func updateTextEditorHeight() {
        let newSize = CGSize(width: UIScreen.main.bounds.width - 100, height: .infinity)
        let newHeight = userInput.heightWithConstrainedWidth(width: newSize.width, font: UIFont(name: "SUIT-Medium", size: 15) ?? .systemFont(ofSize: 15))
        textEditorHeight = min(max(40, newHeight + 20), 120) // 최소 40, 최대 120
        
        // 메시지 유효성 검사
        isMessageValid = !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
