//
//  CompleteToggle.swift
//  ToDoList
//
//  Created by Quang Minh Nguyen on 25/8/2024.
//

import SwiftUI

struct CompleteToggle: View {
    @Binding var isComplete: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                isComplete.toggle()
            }
        } label: {
            Label("Show Completed", systemImage: isComplete ? "checkmark.circle.fill" : "circle")
                .labelStyle(.iconOnly)
                .foregroundStyle(isComplete ? .blue : .gray)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .bottom))
                ))
        }
    }
}

#Preview {
    CompleteToggle(isComplete: .constant(true))
}



