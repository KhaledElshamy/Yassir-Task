//
//  CharacterFilterView.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import SwiftUI

// MARK: - Character Filter View

struct CharacterFilterView: View {
    
    // MARK: - Properties
    
    @State private var selectedStatus: CharacterResponse.Status?
    let onStatusChanged: (CharacterResponse.Status?) -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(CharacterResponse.Status.allCases, id: \.self) { status in
                FilterButton(
                    title: status.rawValue,
                    isSelected: selectedStatus == status,
                    action: {
                        selectedStatus = selectedStatus == status ? nil : status
                        onStatusChanged(selectedStatus)
                    }
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Filter Button

struct FilterButton: View {
    
    // MARK: - Properties
    
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                isSelected ? Color.black : Color.gray.opacity(0.2)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .onTapGesture {
                action()
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        CharacterFilterView(
            onStatusChanged: { status in
                print("Status changed to: \(status?.rawValue ?? "nil")")
            }
        )
    }
    .padding()
}
