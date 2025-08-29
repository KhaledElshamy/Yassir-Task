//
//  CharacterRow.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import SwiftUI

// MARK: - Character Row

struct CharacterRow: View {
    
    // MARK: - Properties
    
    let name: String
    let species: String
    let status: CharacterResponse.Status
    let image: UIImage?
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16) {
            characterImage
            characterInfo
            Spacer()
            statusBadge
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
                .stroke(.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    // MARK: - Character Image
    
    private var characterImage: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
            }
        }
    }
    
    // MARK: - Character Info
    
    private var characterInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(species)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    // MARK: - Status Badge
    
    private var statusBadge: some View {
        Text(status.rawValue.capitalized)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(statusColor)
            )
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        switch status {
        case .alive:
            return .green
        case .dead:
            return .red
        case .unknown:
            return .gray
        }
    }
}

// MARK: - Preview

struct CharacterRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            CharacterRow(
                name: "Zephyr",
                species: "Elf",
                status: .alive,
                image: nil
            )
            
            CharacterRow(
                name: "Rick Sanchez",
                species: "Human",
                status: .alive,
                image: nil
            )
            
            CharacterRow(
                name: "Morty Smith",
                species: "Human",
                status: .alive,
                image: nil
            )
        }
        .padding()
        .background(.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
