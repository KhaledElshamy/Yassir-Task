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
    
    static func createTimeoutError() -> NSError {
        return NSError(domain: "TimeoutError", code: -1001, userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
    }
    
    static func createServerError() -> NSError {
        return NSError(domain: "ServerError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Internal server error"])
    }
    
    // MARK: - Specialized Character Lists
    
    static func createAliveCharactersList(count: Int = 5) -> [CharacterResponse] {
        return (1...count).map { index in
            createCharacter(
                id: index,
                name: "Alive Character \(index)",
                status: .alive
            )
        }
    }
    
    static func createDeadCharactersList(count: Int = 5) -> [CharacterResponse] {
        return (1...count).map { index in
            createCharacter(
                id: index + 100,
                name: "Dead Character \(index)",
                status: .dead
            )
        }
    }
    
    static func createUnknownCharactersList(count: Int = 5) -> [CharacterResponse] {
        return (1...count).map { index in
            createCharacter(
                id: index + 200,
                name: "Unknown Character \(index)",
                status: .unknown
            )
        }
    }
    
    static func createMixedStatusCharactersList() -> [CharacterResponse] {
        return [
            createCharacter(id: 1, name: "Alive 1", status: .alive),
            createCharacter(id: 2, name: "Dead 1", status: .dead),
            createCharacter(id: 3, name: "Unknown 1", status: .unknown),
            createCharacter(id: 4, name: "Alive 2", status: .alive),
            createCharacter(id: 5, name: "Dead 2", status: .dead),
            createCharacter(id: 6, name: "Unknown 2", status: .unknown)
        ]
    }
    
    // MARK: - Large Dataset Creation
    
    static func createLargeCharactersList(count: Int = 1000) -> [CharacterResponse] {
        return (1...count).map { index in
            createCharacter(
                id: index,
                name: "Character \(index)",
                species: index % 5 == 0 ? "Alien" : "Human",
                status: index % 3 == 0 ? .alive : (index % 3 == 1 ? .dead : .unknown),
                gender: index % 2 == 0 ? "Male" : "Female",
                location: "Location \(index % 10)"
            )
        }
    }
    
    // MARK: - Edge Case Characters
    
    static func createCharacterWithLongName() -> CharacterResponse {
        return createCharacter(
            id: 999,
            name: "Very Long Character Name That Should Test Text Wrapping And Display Limits In The UI",
            species: "Alien",
            status: .alive,
            location: "Very Long Location Name That Should Also Test Text Wrapping"
        )
    }
    
    static func createCharacterWithSpecialCharacters() -> CharacterResponse {
        return createCharacter(
            id: 998,
            name: "Character with Special Chars: !@#$%^&*()",
            species: "Human-Alien Hybrid",
            status: .unknown,
            location: "Location with Special Chars: !@#$%^&*()"
        )
    }
    
    static func createCharacterWithEmptyFields() -> CharacterResponse {
        return createCharacter(
            id: 997,
            name: "",
            species: "",
            status: .unknown,
            gender: "",
            location: ""
        )
    }
    
    // MARK: - Response Variations
    
    static func createSinglePageResponse() -> CharactersListResponse {
        return createCharactersListResponse(
            characters: createCharactersList(count: 20),
            hasNextPage: false,
            count: 20,
            pages: 1
        )
    }
    
    static func createMultiPageResponse(page: Int = 1, totalPages: Int = 5) -> CharactersListResponse {
        let hasNextPage = page < totalPages
        let nextUrl = hasNextPage ? "https://example.com/page/\(page + 1)" : nil
        
        let info = CharactersInfo(
            count: totalPages * 20,
            pages: totalPages,
            next: nextUrl,
            prev: page > 1 ? "https://example.com/page/\(page - 1)" : nil
        )
        
        return CharactersListResponse(info: info, results: createCharactersList(count: 20))
    }
    
    // MARK: - Performance Test Data
    
    static func createPerformanceTestCharacters(count: Int = 10000) -> [CharacterResponse] {
        return (1...count).map { index in
            createCharacter(
                id: index,
                name: "Performance Test Character \(index)",
                species: "Test Species \(index % 100)",
                status: index % 3 == 0 ? .alive : (index % 3 == 1 ? .dead : .unknown),
                gender: index % 2 == 0 ? "Male" : "Female",
                location: "Test Location \(index % 1000)"
            )
        }
    }
}
