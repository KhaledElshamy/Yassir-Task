//
//  CharacterDetailsView.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import SwiftUI

// MARK: - Character Details View

struct CharacterDetailsView: View {
    
    // MARK: - Properties
    
    let character: CharacterResponse
    @State private var characterImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Character Image
                    characterImageView
                        .padding(.top, 20)
                    
                    // Character Details
                    characterDetailsView
                        .padding(.top, 30)
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 50)
                }
            }
            
            // Back Button
            VStack {
                HStack {
                    backButton
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadCharacterImage()
        }
    }
    
    // MARK: - Character Image View
    
    private var characterImageView: some View {
        AsyncImage(url: character.imageUrl) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color(.systemGray5))
                .overlay(
                    ProgressView()
                        .scaleEffect(1.2)
                )
        }
        .frame(width: 280, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Character Details View
    
    private var characterDetailsView: some View {
        VStack(spacing: 16) {
            // Character Name
            Text(character.name)
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(Color(.systemIndigo))
                .multilineTextAlignment(.center)
            
            // Species and Gender
            HStack(spacing: 8) {
                Text(character.species)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(.systemGray))
                
                Text("•")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(.systemGray))
                
                Text(character.gender)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(Color(.systemGray))
            }
            
            // Status Badge
            statusBadge
            
            // Location
            locationView
        }
    }
    
    // MARK: - Status Badge
    
    private var statusBadge: some View {
        HStack {
            Spacer()
            
            Text(character.status.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(statusColor)
                )
            
            Spacer()
        }
    }
    
    // MARK: - Location View
    
    private var locationView: some View {
        HStack {
            Text("Location :")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(.systemIndigo))
            
            Text(character.location)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(.systemGray))
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
        }
    }
    
    // MARK: - Status Color
    
    private var statusColor: Color {
        switch character.status {
        case .alive:
            return .green
        case .dead:
            return .red
        case .unknown:
            return .gray
        }
    }
    
    // MARK: - Private Methods
    
    private func loadCharacterImage() {
        Task {
            let image = await ImageCache.shared.loadImage(from: character.imageUrl)
            await MainActor.run {
                characterImage = image
            }
        }
    }
}
// MARK: - Preview

#Preview {
    CharacterDetailsView(
        character: CharacterResponse(
            id: 1,
            name: "Zephyr",
            imageUrl: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")!,
            species: "Elf",
            status: .alive,
            gender: "Male",
            location: "Earth"
        )
    )
}
