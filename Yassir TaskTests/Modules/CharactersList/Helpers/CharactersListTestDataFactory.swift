//
//  CharactersListTestDataFactory.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import XCTest
@testable import Yassir_Task

// MARK: - Test Data Factory

struct CharactersListTestDataFactory {
    
    static func createMockCharacterResponseDTO(
        id: Int = 1,
        name: String = "Test Character",
        status: String = "Alive",
        species: String = "Human",
        gender: String = "Male",
        image: String = "https://example.com/image.jpg",
        location: CharactersListResponseDTO.Location = CharactersListResponseDTO.Location(name: "Earth")
    ) -> CharactersListResponseDTO.Character {
        return CharactersListResponseDTO.Character(
            id: id,
            name: name,
            status: status,
            species: species,
            gender: gender,
            image: image,
            location: location
        )
    }
    
    static func createMockInfoDTO(
        count: Int = 100,
        pages: Int = 5,
        next: String? = "https://api.example.com/characters?page=2",
        prev: String? = nil
    ) -> Info {
        return Info(
            count: count,
            pages: pages,
            next: next,
            prev: prev
        )
    }
    
    static func createMockCharactersListResponseDTO(
        characters: [CharactersListResponseDTO.Character]? = nil,
        info: Info? = nil
    ) -> CharactersListResponseDTO {
        let defaultCharacters = [
            createMockCharacterResponseDTO(id: 1, name: "Rick Sanchez"),
            createMockCharacterResponseDTO(id: 2, name: "Morty Smith", status: "Alive", species: "Human"),
            createMockCharacterResponseDTO(id: 3, name: "Summer Smith", status: "Alive", species: "Human", gender: "Female")
        ]
        
        return CharactersListResponseDTO(
            info: info ?? createMockInfoDTO(),
            results: characters ?? defaultCharacters
        )
    }
    
    static func createMockCharacterResponse(
        id: Int = 1,
        name: String = "Test Character",
        status: CharacterResponse.Status = .alive,
        species: String = "Human",
        gender: String = "Male",
        imageUrl: URL = URL(string: "https://example.com/image.jpg")!,
        location: String = "Earth"
    ) -> CharacterResponse {
        return CharacterResponse(
            id: id,
            name: name,
            imageUrl: imageUrl,
            species: species,
            status: status,
            gender: gender,
            location: location
        )
    }
    
    static func createMockCharactersInfo(
        count: Int = 100,
        pages: Int = 5,
        next: String? = "https://api.example.com/characters?page=2",
        prev: String? = nil
    ) -> CharactersInfo {
        return CharactersInfo(
            count: count,
            pages: pages,
            next: next,
            prev: prev
        )
    }
    
    static func createMockCharactersListResponse(
        characters: [CharacterResponse]? = nil,
        info: CharactersInfo? = nil
    ) -> CharactersListResponse {
        let defaultCharacters = [
            createMockCharacterResponse(id: 1, name: "Rick Sanchez"),
            createMockCharacterResponse(id: 2, name: "Morty Smith"),
            createMockCharacterResponse(id: 3, name: "Summer Smith", gender: "Female")
        ]
        
        return CharactersListResponse(
            info: info ?? createMockCharactersInfo(),
            results: characters ?? defaultCharacters
        )
    }
}
