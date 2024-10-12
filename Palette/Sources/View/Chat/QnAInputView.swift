//
//  QnAInputView.swift
//  Palette
//
//  Created by 4rNe5 on 10/12/24.
//


import SwiftUI

struct QnAInputView: View {
    let qna: QnAData
    let onSubmit: (AnswerDto) -> Void
    
    @State private var selectedChoice: String?
    @State private var userInput: String = ""
    @State private var selectedNumbers: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text(qna.promptName)
                .font(.headline)
                .padding()
            
            switch qna.type {
            case .SELECTABLE:
                selectableView
            case .USER_INPUT:
                userInputView
            case .GRID:
                gridView
            }
            
            submitButton
        }
    }
    
    private var selectableView: some View {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(qna.question.choices ?? []) { choice in
                        Button(action: {
                            selectedChoice = choice.id
                        }) {
                            Text(choice.displayName)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedChoice == choice.id ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedChoice == choice.id ? .white : .black)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    
    private var userInputView: some View {
        TextField("Your answer", text: $userInput)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }
    
    private var gridView: some View {
        if let xSize = qna.question.xSize, let ySize = qna.question.ySize {
            return AnyView(
                CoordinateGridBox(width: xSize, height: ySize, selectedNumbers: $selectedNumbers)
            )
        } else {
            return AnyView(Text("Grid size not specified").foregroundColor(.red))
        }
    }
    
    private var submitButton: some View {
        Button(action: submitAnswer) {
            Text("Submit")
                .padding()
                .frame(maxWidth: .infinity)
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
}
