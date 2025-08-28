//
//  CharactersListIntegrationTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import XCTest
import Foundation
@testable import Yassir_Task

class CharactersListIntegrationTests: XCTestCase {
    
    // MARK: - Test Properties
    
    private var mockDataTransferService: MockDataTransferService!
    private var repository: CharactersRepository!
    private var useCase: CharactersUseCase!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        setupMocks()
    }
    
    override func tearDown() {
        mockDataTransferService = nil
        repository = nil
        useCase = nil
        super.tearDown()
    }
    
    private func setupMocks() {
        mockDataTransferService = MockDataTransferService()
        repository = CharactersRepository(service: mockDataTransferService)
        useCase = CharactersUseCase(charactersRepository: repository)
    }
    
    // MARK: - Integration Tests
    
    func testCompleteFlowFromUseCaseToRepository() async throws {
        // Given
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO()
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        let page = 1
        let status = "Alive"
        
        // When
        let result = try await useCase.fetchCharacters(page: page, status: status)
        
        // Then
        // Verify the complete flow worked
        XCTAssertEqual(mockDataTransferService.requestCallCount, 1, "Expected 1 network request")
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters")
        XCTAssertEqual(result.info.count, 100, "Expected count 100")
        
        // Verify the endpoint was called correctly
        if let endpoint = mockDataTransferService.lastRequestedEndpoint as? Endpoint<CharactersListResponseDTO> {
            XCTAssertEqual(endpoint.path, "api/character", "Expected correct API path")
            XCTAssertEqual(endpoint.method, .get, "Expected GET method")
        } else {
            XCTFail("Expected Endpoint<CharactersListResponseDTO>")
        }
    }
    
    func testErrorPropagationThroughCompleteFlow() async throws {
        // Given
        mockDataTransferService.shouldThrowError = true
        mockDataTransferService.mockError = NetworkError.notConnected
        
        // When & Then
        do {
            _ = try await useCase.fetchCharacters(page: 1, status: "Alive")
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
        
        XCTAssertEqual(mockDataTransferService.requestCallCount, 1, "Expected 1 network request attempt")
    }
    
    func testDTOToDomainMappingIntegration() async throws {
        // Given
        // Create a DTO with specific data to test mapping
        let characterDTO = CharactersListTestDataFactory.createMockCharacterResponseDTO(
            id: 123,
            name: "Test Character",
            status: "Dead",
            species: "Alien",
            gender: "Female",
            image: "https://example.com/test-image.jpg"
        )
        
        let infoDTO = CharactersListTestDataFactory.createMockInfoDTO(
            count: 50,
            pages: 2,
            next: "https://api.example.com/next",
            prev: "https://api.example.com/prev"
        )
        
        let mockResponseDTO = CharactersListResponseDTO(
            info: infoDTO,
            results: [characterDTO]
        )
        
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        // When
        let result = try await useCase.fetchCharacters(page: 1, status: "Dead")
        
        // Then
        XCTAssertEqual(result.results.count, 1, "Expected 1 character")
        
        let character = result.results.first!
        XCTAssertEqual(character.id, 123, "Expected id 123, got \(character.id)")
        XCTAssertEqual(character.name, "Test Character", "Expected name 'Test Character', got '\(character.name)'")
        XCTAssertEqual(character.status, .dead, "Expected status .dead, got \(character.status)")
        XCTAssertEqual(character.species, "Alien", "Expected species 'Alien', got '\(character.species)'")
        XCTAssertEqual(character.gender, "Female", "Expected gender 'Female', got '\(character.gender)'")
        XCTAssertEqual(character.imageUrl.absoluteString, "https://example.com/test-image.jpg", "Expected correct image URL")
        
        XCTAssertEqual(result.info.count, 50, "Expected count 50, got \(result.info.count)")
        XCTAssertEqual(result.info.pages, 2, "Expected pages 2, got \(result.info.pages)")
        XCTAssertTrue(result.info.hasNextPage, "Expected hasNextPage to be true")
        XCTAssertTrue(result.info.hasPreviousPage, "Expected hasPreviousPage to be true")
    }
    
    func testMultipleRequestsWithDifferentParameters() async throws {
        // Given
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO()
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        // When
        _ = try await useCase.fetchCharacters(page: 1, status: "Alive")
        _ = try await useCase.fetchCharacters(page: 2, status: "Dead")
        _ = try await useCase.fetchCharacters(page: 3, status: "Unknown")
        
        // Then
        XCTAssertEqual(mockDataTransferService.requestCallCount, 3, "Expected 3 network requests, got \(mockDataTransferService.requestCallCount)")
    }
    
    func testRequestDTOCreationWithParameters() async throws {
        // Given
        let mockResponseDTO = CharactersListTestDataFactory.createMockCharactersListResponseDTO()
        mockDataTransferService.mockCharactersResponseDTO = mockResponseDTO
        mockDataTransferService.shouldThrowError = false
        
        let page = 5
        let status = "Alive"
        
        // When
        _ = try await useCase.fetchCharacters(page: page, status: status)
        
        // Then
        XCTAssertEqual(mockDataTransferService.requestCallCount, 1, "Expected 1 network request")
        
        // Verify the endpoint was created with the correct parameters
        if let endpoint = mockDataTransferService.lastRequestedEndpoint as? Endpoint<CharactersListResponseDTO> {
            XCTAssertNotNil(endpoint.queryParametersEncodable, "Expected query parameters to be set")
            
            // The endpoint should have been created with CharactersRequestDTO containing our parameters
            if let requestDTO = endpoint.queryParametersEncodable as? CharactersRequestDTO {
                XCTAssertEqual(requestDTO.page, page, "Expected page \(page), got \(requestDTO.page ?? -1)")
                XCTAssertEqual(requestDTO.status, status, "Expected status '\(status)', got '\(requestDTO.status ?? "")'")
            } else {
                XCTFail("Expected CharactersRequestDTO as query parameters")
            }
        } else {
            XCTFail("Expected Endpoint<CharactersListResponseDTO>")
        }
    }
}
