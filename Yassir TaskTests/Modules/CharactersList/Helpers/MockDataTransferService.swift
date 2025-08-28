//
//  MockDataTransferService.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import XCTest
@testable import Yassir_Task

// MARK: - Mock DataTransferService

final class MockDataTransferService: DataTransferService {
    
    var requestCallCount = 0
    var lastRequestedEndpoint: Any?
    var shouldThrowError = false
    var mockError: Error = NetworkError.notConnected
    var mockCharactersResponseDTO: CharactersListResponseDTO?
    
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E
    ) async throws -> T where E.Response == T {
        requestCallCount += 1
        lastRequestedEndpoint = endpoint
        
        if shouldThrowError {
            throw mockError
        }
        
        if let mockResponse = mockCharactersResponseDTO as? T {
            return mockResponse
        }
        
        throw NetworkError.notConnected
    }
    
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) async throws where E.Response == Void {
        requestCallCount += 1
        lastRequestedEndpoint = endpoint
        
        if shouldThrowError {
            throw mockError
        }
    }
}
