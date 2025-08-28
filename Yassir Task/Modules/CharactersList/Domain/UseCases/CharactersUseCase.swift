//
//  CharactersUseCase.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

protocol CharactersUseCaseProtocol {
    func fetchCharacters(page: Int, status: String) async throws -> CharactersListResponse
}

class CharactersUseCase: CharactersUseCaseProtocol {
    
    private let charactersRepository: CharactersRepositoryProtocol
    
    init(charactersRepository: CharactersRepositoryProtocol) {
        self.charactersRepository = charactersRepository
    }
    
    func fetchCharacters(page: Int, status: String) async throws -> CharactersListResponse {
        return try await charactersRepository.fetchCharacters(page: page, status: status)
    }
}
