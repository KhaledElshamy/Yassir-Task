//
//  MockCharactersRepository.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import XCTest
@testable import Yassir_Task

// MARK: - Mock CharactersRepository

final class MockCharactersRepository: CharactersRepositoryProtocol {
    
    var fetchCharactersCallCount = 0
    var lastFetchCharactersPage: Int?
    var lastFetchCharactersStatus: String?
    var shouldThrowError = false
    var mockError: Error = NetworkError.notConnected
    var mockCharactersListResponse: CharactersListResponse?
    
    func fetchCharacters(page: Int, status: String) async throws -> CharactersListResponse {
        fetchCharactersCallCount += 1
        lastFetchCharactersPage = page
        lastFetchCharactersStatus = status
        
        if shouldThrowError {
            throw mockError
        }
        
        if let mockResponse = mockCharactersListResponse {
            return mockResponse
        }
        
        throw NetworkError.notConnected
    }
}
