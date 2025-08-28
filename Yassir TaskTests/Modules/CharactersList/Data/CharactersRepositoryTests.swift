//
//  CharactersRepositoryTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import XCTest
import Foundation
@testable import Yassir_Task

class CharactersRepositoryTests: XCTestCase {
    
    // MARK: - Test Properties
    
    private var mockDataTransferService: MockDataTransferService!
    private var charactersRepository: CharactersRepository!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        setupMocks()
    }
    
    override func tearDown() {
        mockDataTransferService = nil
        charactersRepository = nil
        super.tearDown()
    }
    
    private func setupMocks() {
        mockDataTransferService = MockDataTransferService()
        charactersRepository = CharactersRepository(service: mockDataTransferService)
    }
    
    // MARK: - Success Tests
    
    func testFetchCharactersSuccessfully() async throws {
        // Given
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO()
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        let page = 1
        let status = "Alive"
        
        // When
        let result = try await charactersRepository.fetchCharacters(page: page, status: status)
        
        // Then
        XCTAssertEqual(mockDataTransferService.requestCallCount, 1, "Expected 1 request call, got \(mockDataTransferService.requestCallCount)")
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters, got \(result.results.count)")
        XCTAssertEqual(result.info.count, 100, "Expected count 100, got \(result.info.count)")
        XCTAssertEqual(result.info.pages, 5, "Expected pages 5, got \(result.info.pages)")
        
        // Verify the endpoint was called correctly
        if let endpoint = mockDataTransferService.lastRequestedEndpoint as? Endpoint<CharactersListResponseDTO> {
            XCTAssertEqual(endpoint.path, "api/character", "Expected path 'api/character', got '\(endpoint.path)'")
            XCTAssertEqual(endpoint.method, .get, "Expected GET method, got \(endpoint.method)")
        } else {
            XCTFail("Expected Endpoint<CharactersListResponseDTO>, got \(type(of: mockDataTransferService.lastRequestedEndpoint))")
        }
    }
    
    func testFetchCharactersWithDifferentParameters() async throws {
        // Given
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO()
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        let page = 2
        let status = "Dead"
        
        // When
        let result = try await charactersRepository.fetchCharacters(page: page, status: status)
        
        // Then
        XCTAssertEqual(mockDataTransferService.requestCallCount, 1, "Expected 1 request call, got \(mockDataTransferService.requestCallCount)")
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters, got \(result.results.count)")
        
        // Verify the request DTO was created with correct parameters
        if let endpoint = mockDataTransferService.lastRequestedEndpoint as? Endpoint<CharactersListResponseDTO> {
            XCTAssertNotNil(endpoint.queryParametersEncodable, "Expected query parameters to be set")
        }
    }
    
    func testFetchCharactersWithEmptyResults() async throws {
        // Given
        let emptyResponseDTO = CharactersListResponseDTO(
            info: CharactersListTestDataFactory.createMockInfoDTO(count: 0, pages: 0),
            results: []
        )
        mockDataTransferService.mockCharactersResponseDTO = emptyResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        // When
        let result = try await charactersRepository.fetchCharacters(page: 1, status: "Unknown")
        
        // Then
        XCTAssertTrue(result.results.isEmpty, "Expected empty results")
        XCTAssertEqual(result.info.count, 0, "Expected count 0, got \(result.info.count)")
        XCTAssertEqual(result.info.pages, 0, "Expected pages 0, got \(result.info.pages)")
    }
    
    func testFetchCharactersWithPaginationInfo() async throws {
        // Given
        let mockInfo = CharactersListTestDataFactory.createMockInfoDTO(
            count: 50,
            pages: 3,
            next: "https://api.example.com/characters?page=2",
            prev: "https://api.example.com/characters?page=1"
        )
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO(info: mockInfo)
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        // When
        let result = try await charactersRepository.fetchCharacters(page: 1, status: "Alive")
        
        // Then
        XCTAssertTrue(result.info.hasNextPage, "Expected hasNextPage to be true")
        XCTAssertTrue(result.info.hasPreviousPage, "Expected hasPreviousPage to be true")
        XCTAssertEqual(result.info.next, "https://api.example.com/characters?page=2", "Expected correct next URL")
        XCTAssertEqual(result.info.prev, "https://api.example.com/characters?page=1", "Expected correct prev URL")
    }
    
    // MARK: - Error Tests
    
    func testFetchCharactersThrowsNetworkError() async throws {
        // Given
        mockDataTransferService.shouldThrowError = true
        mockDataTransferService.mockError = NetworkError.notConnected
        
        // When & Then
        do {
            _ = try await charactersRepository.fetchCharacters(page: 1, status: "Alive")
            XCTFail("Expected NetworkError to be thrown")
        } catch let error as NetworkError {
            if case .notConnected = error {
                // Expected case
            } else {
                XCTFail("Expected NetworkError.notConnected, got \(error)")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(type(of: error))")
        }
        
        XCTAssertEqual(mockDataTransferService.requestCallCount, 1, "Expected 1 request call, got \(mockDataTransferService.requestCallCount)")
    }
    
    func testFetchCharactersThrowsParsingError() async throws {
        // Given
        mockDataTransferService.shouldThrowError = true
        mockDataTransferService.mockError = DataTransferError.parsing(NSError(domain: "Test", code: 1))
        
        // When & Then
        do {
            _ = try await charactersRepository.fetchCharacters(page: 1, status: "Alive")
            XCTFail("Expected DataTransferError to be thrown")
        } catch let error as DataTransferError {
            if case .parsing = error {
                // Expected case
            } else {
                XCTFail("Expected DataTransferError.parsing")
            }
        } catch {
            XCTFail("Expected DataTransferError, got \(type(of: error))")
        }
    }
    
    func testFetchCharactersThrowsServerError() async throws {
        // Given
        mockDataTransferService.shouldThrowError = true
        mockDataTransferService.mockError = NetworkError.error(statusCode: 500, data: Data())
        
        // When & Then
        do {
            _ = try await charactersRepository.fetchCharacters(page: 1, status: "Alive")
            XCTFail("Expected NetworkError to be thrown")
        } catch let error as NetworkError {
            if case .error(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 500, "Expected status code 500")
            } else {
                XCTFail("Expected NetworkError.error")
            }
        } catch {
            XCTFail("Expected NetworkError, got \(type(of: error))")
        }
    }
    
    // MARK: - Edge Cases
    
    func testFetchCharactersWithInvalidStatus() async throws {
        // Given
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO()
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        // When
        let result = try await charactersRepository.fetchCharacters(page: 1, status: "")
        
        // Then
        XCTAssertEqual(mockDataTransferService.requestCallCount, 1, "Expected 1 request call, got \(mockDataTransferService.requestCallCount)")
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters, got \(result.results.count)")
    }
    
    func testFetchCharactersWithZeroPage() async throws {
        // Given
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO()
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        // When
        let result = try await charactersRepository.fetchCharacters(page: 0, status: "Alive")
        
        // Then
        XCTAssertEqual(mockDataTransferService.requestCallCount, 1, "Expected 1 request call, got \(mockDataTransferService.requestCallCount)")
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters, got \(result.results.count)")
    }
    
    func testMultipleFetchCharactersCalls() async throws {
        // Given
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO()
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        // When
        _ = try await charactersRepository.fetchCharacters(page: 1, status: "Alive")
        _ = try await charactersRepository.fetchCharacters(page: 2, status: "Dead")
        _ = try await charactersRepository.fetchCharacters(page: 3, status: "Unknown")
        
        // Then
        XCTAssertEqual(mockDataTransferService.requestCallCount, 3, "Expected 3 request calls, got \(mockDataTransferService.requestCallCount)")
    }
}
