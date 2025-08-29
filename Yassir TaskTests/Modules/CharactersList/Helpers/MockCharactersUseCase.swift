//
//  MockCharactersUseCase.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import Foundation
@testable import Yassir_Task

// MARK: - Mock Characters Use Case

final class MockCharactersUseCase: CharactersUseCaseProtocol {
    
    // MARK: - Properties
    
    var fetchCharactersResult: Result<CharactersListResponse, Error> = .success(CharactersListResponse(info: CharactersInfo(count: 0, pages: 0, next: nil, prev: nil), results: []))
    var fetchCharactersCallCount = 0
    var lastFetchCharactersPage: Int?
    var lastFetchCharactersStatus: String?
    
    // MARK: - CharactersUseCaseProtocol
    
    func fetchCharacters(page: Int, status: String) async throws -> CharactersListResponse {
        fetchCharactersCallCount += 1
        lastFetchCharactersPage = page
        lastFetchCharactersStatus = status
        
        // Add a small delay to simulate real async behavior
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        
        switch fetchCharactersResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        fetchCharactersCallCount = 0
        lastFetchCharactersPage = nil
        lastFetchCharactersStatus = nil
        fetchCharactersResult = .success(CharactersListResponse(info: CharactersInfo(count: 0, pages: 0, next: nil, prev: nil), results: []))
    }
    
    func setSuccessResponse(_ response: CharactersListResponse) {
        fetchCharactersResult = .success(response)
    }
    
    func setFailureResponse(_ error: Error) {
        fetchCharactersResult = .failure(error)
    }
}
