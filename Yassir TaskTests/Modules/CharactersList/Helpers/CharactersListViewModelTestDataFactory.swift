//
//  CharactersListViewModelTestDataFactory.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import Foundation
@testable import Yassir_Task

// MARK: - Characters List View Model Test Data Factory

struct CharactersListViewModelTestDataFactory {
    
    // MARK: - Character Creation
    
    static func createCharacter(
        id: Int = 1,
        name: String = "Test Character",
        imageUrl: URL = URL(string: "https://example.com/image.jpg")!,
        species: String = "Human",
        status: CharacterResponse.Status = .alive,
        gender: String = "Male",
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
    
    static func createCharactersList(count: Int = 3) -> [CharacterResponse] {
        return (1...count).map { index in
            createCharacter(
                id: index,
                name: "Character \(index)",
                species: index % 2 == 0 ? "Human" : "Alien",
                status: index % 3 == 0 ? .alive : (index % 3 == 1 ? .dead : .unknown)
            )
        }
    }
    
    // MARK: - Response Creation
    
    static func createCharactersListResponse(
        characters: [CharacterResponse] = createCharactersList(),
        hasNextPage: Bool = true,
        count: Int? = nil,
        pages: Int? = nil
    ) -> CharactersListResponse {
        let info = CharactersInfo(
            count: count ?? characters.count,
            pages: pages ?? 1,
            next: hasNextPage ? "https://example.com/next" : nil,
            prev: nil
        )
        
        return CharactersListResponse(info: info, results: characters)
    }
    
    static func createEmptyCharactersListResponse() -> CharactersListResponse {
        return createCharactersListResponse(
            characters: [],
            hasNextPage: false,
            count: 0,
            pages: 0
        )
    }
    
    // MARK: - Error Creation
    
    static func createNetworkError() -> NetworkError {
        return NetworkError.notConnected
    }
    
    static func createGenericError() -> NSError {
        return NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test error message"])
    }
}
