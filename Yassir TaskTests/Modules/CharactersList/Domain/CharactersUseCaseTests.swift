//
//  CharactersUseCaseTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import XCTest
import Foundation
@testable import Yassir_Task

class CharactersUseCaseTests: XCTestCase {
    
    // MARK: - Test Properties
    
    private var mockRepository: MockCharactersRepository!
    private var charactersUseCase: CharactersUseCase!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        setupMocks()
    }
    
    override func tearDown() {
        mockRepository = nil
        charactersUseCase = nil
        super.tearDown()
    }
    
    private func setupMocks() {
        mockRepository = MockCharactersRepository()
        charactersUseCase = CharactersUseCase(charactersRepository: mockRepository)
    }
    
    // MARK: - Success Tests
    
    func testFetchCharactersSuccessfully() async throws {
        // Given
        let mockResponse = CharactersListTestDataFactory.createMockCharactersListResponse()
        mockRepository.mockCharactersListResponse = mockResponse
        mockRepository.shouldThrowError = false
        
        let page = 1
        let status = "Alive"
        
        // When
        let result = try await charactersUseCase.fetchCharacters(page: page, status: status)
        
        // Then
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Expected 1 repository call, got \(mockRepository.fetchCharactersCallCount)")
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, page, "Expected page \(page), got \(mockRepository.lastFetchCharactersPage ?? -1)")
        XCTAssertEqual(mockRepository.lastFetchCharactersStatus, status, "Expected status '\(status)', got '\(mockRepository.lastFetchCharactersStatus ?? "")'")
        
        CharactersListTestAssertions.assertCharactersListResponse(
            result,
            expectedCharacterCount: 3,
            expectedInfo: mockResponse.info
        )
    }
    
    func testFetchCharactersWithDifferentParameters() async throws {
        // Given
        let mockResponse = CharactersListTestDataFactory.createMockCharactersListResponse()
        mockRepository.mockCharactersListResponse = mockResponse
        mockRepository.shouldThrowError = false
        
        let page = 5
        let status = "Dead"
        
        // When
        let result = try await charactersUseCase.fetchCharacters(page: page, status: status)
        
        // Then
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Expected 1 repository call, got \(mockRepository.fetchCharactersCallCount)")
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, page, "Expected page \(page), got \(mockRepository.lastFetchCharactersPage ?? -1)")
        XCTAssertEqual(mockRepository.lastFetchCharactersStatus, status, "Expected status '\(status)', got '\(mockRepository.lastFetchCharactersStatus ?? "")'")
        
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters, got \(result.results.count)")
    }
    
    func testFetchCharactersWithEmptyResults() async throws {
        // Given
        let emptyResponse = CharactersListTestDataFactory.createMockCharactersListResponse(
            characters: [],
            info: CharactersListTestDataFactory.createMockCharactersInfo(count: 0, pages: 0)
        )
        mockRepository.mockCharactersListResponse = emptyResponse
        mockRepository.shouldThrowError = false
        
        // When
        let result = try await charactersUseCase.fetchCharacters(page: 1, status: "Unknown")
        
        // Then
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Expected 1 repository call, got \(mockRepository.fetchCharactersCallCount)")
        XCTAssertTrue(result.results.isEmpty, "Expected empty results")
        XCTAssertEqual(result.info.count, 0, "Expected count 0, got \(result.info.count)")
    }
    
    func testFetchCharactersWithPaginationInfo() async throws {
        // Given
        let mockInfo = CharactersListTestDataFactory.createMockCharactersInfo(
            count: 100,
            pages: 10,
            next: "https://api.example.com/characters?page=2",
            prev: nil
        )
        let mockResponse = CharactersListTestDataFactory.createMockCharactersListResponse(info: mockInfo)
        mockRepository.mockCharactersListResponse = mockResponse
        mockRepository.shouldThrowError = false
        
        // When
        let result = try await charactersUseCase.fetchCharacters(page: 1, status: "Alive")
        
        // Then
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Expected 1 repository call, got \(mockRepository.fetchCharactersCallCount)")
        XCTAssertTrue(result.info.hasNextPage, "Expected hasNextPage to be true")
        XCTAssertFalse(result.info.hasPreviousPage, "Expected hasPreviousPage to be false")
        XCTAssertEqual(result.info.next, "https://api.example.com/characters?page=2", "Expected correct next URL")
    }
    
    // MARK: - Error Tests
    
    func testFetchCharactersPropagatesRepositoryError() async throws {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.mockError = NetworkError.notConnected
        
        // When & Then
        do {
            _ = try await charactersUseCase.fetchCharacters(page: 1, status: "Alive")
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
        
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Expected 1 repository call, got \(mockRepository.fetchCharactersCallCount)")
    }
    
    func testFetchCharactersPropagatesParsingError() async throws {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.mockError = DataTransferError.parsing(NSError(domain: "Test", code: 1))
        
        // When & Then
        do {
            _ = try await charactersUseCase.fetchCharacters(page: 1, status: "Alive")
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
    
    func testFetchCharactersPropagatesServerError() async throws {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.mockError = NetworkError.error(statusCode: 500, data: Data())
        
        // When & Then
        do {
            _ = try await charactersUseCase.fetchCharacters(page: 1, status: "Alive")
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
    
    func testFetchCharactersWithEmptyStatus() async throws {
        // Given
        let mockResponse = CharactersListTestDataFactory.createMockCharactersListResponse()
        mockRepository.mockCharactersListResponse = mockResponse
        mockRepository.shouldThrowError = false
        
        // When
        let result = try await charactersUseCase.fetchCharacters(page: 1, status: "")
        
        // Then
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Expected 1 repository call, got \(mockRepository.fetchCharactersCallCount)")
        XCTAssertEqual(mockRepository.lastFetchCharactersStatus, "", "Expected empty status")
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters, got \(result.results.count)")
    }
    
    func testFetchCharactersWithZeroPage() async throws {
        // Given
        let mockResponse = CharactersListTestDataFactory.createMockCharactersListResponse()
        mockRepository.mockCharactersListResponse = mockResponse
        mockRepository.shouldThrowError = false
        
        // When
        let result = try await charactersUseCase.fetchCharacters(page: 0, status: "Alive")
        
        // Then
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Expected 1 repository call, got \(mockRepository.fetchCharactersCallCount)")
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, 0, "Expected page 0, got \(mockRepository.lastFetchCharactersPage ?? -1)")
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters, got \(result.results.count)")
    }
    
    func testMultipleFetchCharactersCalls() async throws {
        // Given
        let mockResponse = CharactersListTestDataFactory.createMockCharactersListResponse()
        mockRepository.mockCharactersListResponse = mockResponse
        mockRepository.shouldThrowError = false
        
        // When
        _ = try await charactersUseCase.fetchCharacters(page: 1, status: "Alive")
        _ = try await charactersUseCase.fetchCharacters(page: 2, status: "Dead")
        _ = try await charactersUseCase.fetchCharacters(page: 3, status: "Unknown")
        
        // Then
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 3, "Expected 3 repository calls, got \(mockRepository.fetchCharactersCallCount)")
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, 3, "Expected last page 3, got \(mockRepository.lastFetchCharactersPage ?? -1)")
        XCTAssertEqual(mockRepository.lastFetchCharactersStatus, "Unknown", "Expected last status 'Unknown', got '\(mockRepository.lastFetchCharactersStatus ?? "")'")
    }
    
    func testFetchCharactersWithSpecialCharactersInStatus() async throws {
        // Given
        let mockResponse = CharactersListTestDataFactory.createMockCharactersListResponse()
        mockRepository.mockCharactersListResponse = mockResponse
        mockRepository.shouldThrowError = false
        
        let specialStatus = "Alive & Well"
        
        // When
        let result = try await charactersUseCase.fetchCharacters(page: 1, status: specialStatus)
        
        // Then
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1, "Expected 1 repository call, got \(mockRepository.fetchCharactersCallCount)")
        XCTAssertEqual(mockRepository.lastFetchCharactersStatus, specialStatus, "Expected status '\(specialStatus)', got '\(mockRepository.lastFetchCharactersStatus ?? "")'")
        XCTAssertEqual(result.results.count, 3, "Expected 3 characters, got \(result.results.count)")
    }
    
    // MARK: - Integration Tests
    
    func testUseCaseCorrectlyDelegatesToRepository() async throws {
        // Given
        let mockResponse = CharactersListTestDataFactory.createMockCharactersListResponse()
        mockRepository.mockCharactersListResponse = mockResponse
        mockRepository.shouldThrowError = false
        
        let page = 42
        let status = "Test Status"
        
        // When
        let result = try await charactersUseCase.fetchCharacters(page: page, status: status)
        
        // Then
        // Verify the use case correctly passed parameters to repository
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, page, "UseCase should pass page to repository")
        XCTAssertEqual(mockRepository.lastFetchCharactersStatus, status, "UseCase should pass status to repository")
        
        // Verify the use case returns the repository result unchanged
        XCTAssertEqual(result.results.count, mockResponse.results.count, "UseCase should return repository result unchanged")
        XCTAssertEqual(result.info.count, mockResponse.info.count, "UseCase should return repository info unchanged")
    }
}
