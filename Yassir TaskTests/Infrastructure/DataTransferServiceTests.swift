//
//  DataTransferServiceTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 27/08/2025.
//

import Testing
import Foundation
@testable import Yassir_Task

@Suite("DataTransferService Tests")
struct DataTransferServiceTests {
    
    // MARK: - Success Tests
    
    @Test("Should successfully decode JSON response")
    func testSuccessfulJSONDecoding() async throws {
        // Given
        let expectedModel = TestUser.mock()
        let jsonData = try JSONEncoder().encode(expectedModel)
        let networkService = MockNetworkService(mockData: jsonData)
        let errorResolver = MockDataTransferErrorResolver()
        let errorLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: errorLogger
        )
        let endpoint = TestEndpoint<TestUser>()
        
        // When
        let result: TestUser = try await dataTransferService.request(with: endpoint)
        
        // Then
        #expect(result.id == expectedModel.id)
        #expect(result.name == expectedModel.name)
        #expect(errorLogger.loggedErrors.isEmpty)
    }
    
    @Test("Should successfully handle void response")
    func testSuccessfulVoidResponse() async throws {
        // Given
        let networkService = MockNetworkService(mockData: Data())
        let errorResolver = MockDataTransferErrorResolver()
        let errorLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: errorLogger
        )
        let endpoint = TestVoidEndpoint()
        
        // When & Then - Should not throw
        try await dataTransferService.request(with: endpoint)
        #expect(errorLogger.loggedErrors.isEmpty)
    }
    
    @Test("Should handle raw data response")
    func testRawDataDecoding() async throws {
        // Given
        let expectedData = "Test raw data".data(using: .utf8)!
        let networkService = MockNetworkService(mockData: expectedData)
        let errorResolver = MockDataTransferErrorResolver()
        let errorLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: errorLogger
        )
        let endpoint = TestRawDataEndpoint()
        
        // When
        let result: Data = try await dataTransferService.request(with: endpoint)
        
        // Then
        #expect(result == expectedData)
        #expect(errorLogger.loggedErrors.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Should throw noResponse error when data is nil")
    func testNoResponseError() async throws {
        // Given
        let networkService = MockNetworkService(mockData: nil)
        let errorResolver = MockDataTransferErrorResolver()
        let errorLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: errorLogger
        )
        let endpoint = TestEndpoint<TestUser>()
        
        // When & Then
        await #expect(throws: DataTransferError.self) {
            let _: TestUser = try await dataTransferService.request(with: endpoint)
        }
    }
    
    @Test("Should throw parsing error for invalid JSON")
    func testParsingError() async throws {
        // Given
        let invalidJSON = "Invalid JSON".data(using: .utf8)!
        let networkService = MockNetworkService(mockData: invalidJSON)
        let errorResolver = MockDataTransferErrorResolver()
        let errorLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: errorLogger
        )
        let endpoint = TestEndpoint<TestUser>()
        
        // When & Then - DataTransferService passes through decoding errors as-is
        await #expect(throws: DecodingError.self) {
            let _: TestUser = try await dataTransferService.request(with: endpoint)
        }
        
        // Verify error was logged
        #expect(errorLogger.loggedErrors.count == 1)
        #expect(errorLogger.loggedErrors.first is DecodingError)
    }
    
    @Test("Should handle network error and resolve it")
    func testNetworkErrorResolution() async throws {
        // Given
        let networkError = NetworkError.notConnected
        let networkService = MockNetworkService(shouldThrow: networkError)
        let errorResolver = MockDataTransferErrorResolver()
        let errorLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: errorLogger
        )
        let endpoint = TestEndpoint<TestUser>()
        
        // When & Then
        await #expect(throws: DataTransferError.self) {
            let _: TestUser = try await dataTransferService.request(with: endpoint)
        }
        
        // Verify error was logged and resolved
        #expect(errorLogger.loggedErrors.count == 1)
        #expect(errorResolver.resolvedErrors.count == 1)
    }
    
    @Test("Should handle resolved network error")
    func testResolvedNetworkError() async throws {
        // Given
        let networkError = NetworkError.notConnected
        let customError = CustomError.customNetworkError
        let networkService = MockNetworkService(shouldThrow: networkError)
        let errorResolver = MockDataTransferErrorResolver(mockResolvedError: customError)
        let errorLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: errorLogger
        )
        let endpoint = TestEndpoint<TestUser>()
        
        // When & Then
        await #expect(throws: DataTransferError.self) {
            let _: TestUser = try await dataTransferService.request(with: endpoint)
        }
        
        // Verify it's resolved network failure
        #expect(errorLogger.loggedErrors.count == 1)
        #expect(errorResolver.resolvedErrors.count == 1)
    }
    
    @Test("Should handle generic error")
    func testGenericError() async throws {
        // Given
        let genericError = CustomError.genericError
        let networkService = MockNetworkService(shouldThrow: genericError)
        let errorResolver = MockDataTransferErrorResolver()
        let errorLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: errorLogger
        )
        let endpoint = TestEndpoint<TestUser>()
        
        // When & Then
        await #expect(throws: CustomError.self) {
            let _: TestUser = try await dataTransferService.request(with: endpoint)
        }
        
        // Verify error was logged but not resolved (since it's not NetworkError)
        #expect(errorLogger.loggedErrors.count == 1)
        #expect(errorResolver.resolvedErrors.isEmpty)
    }
    
    // MARK: - Decoder Tests
    
    @Test("Should test JSONResponseDecoder")
    func testJSONResponseDecoder() async throws {
        // Given
        let model = TestUser(id: 42, name: "JSON Test", email: "test@example.com", isActive: true)
        let jsonData = try JSONEncoder().encode(model)
        let decoder = JSONResponseDecoder()
        
        // When
        let result: TestUser = try decoder.decode(jsonData)
        
        // Then
        #expect(result.id == model.id)
        #expect(result.name == model.name)
    }
    
    @Test("Should test RawDataResponseDecoder success")
    func testRawDataResponseDecoderSuccess() async throws {
        // Given
        let testData = "Test data".data(using: .utf8)!
        let decoder = RawDataResponseDecoder()
        
        // When
        let result: Data = try decoder.decode(testData)
        
        // Then
        #expect(result == testData)
    }
    
    @Test("Should test RawDataResponseDecoder failure")
    func testRawDataResponseDecoderFailure() async throws {
        // Given
        let testData = "Test data".data(using: .utf8)!
        let decoder = RawDataResponseDecoder()
        
        // When & Then
        #expect(throws: DecodingError.self) {
            let _: TestUser = try decoder.decode(testData)
        }
    }
    
    // MARK: - Logger Tests
    
    @Test("Should test DefaultDataTransferErrorLogger")
    func testDefaultDataTransferErrorLogger() async throws {
        // Given
        let logger = DefaultDataTransferErrorLogger()
        let testError = CustomError.genericError
        
        // When - Should not crash
        logger.log(error: testError)
        
        // Then - No assertion needed, just ensure it doesn't crash
        #expect(true)
    }
    
    // MARK: - Error Resolver Tests
    
//    @Test("Should test DefaultDataTransferErrorResolver")
//    func testDefaultDataTransferErrorResolver() async throws {
//        // Given
//        let resolver = DefaultDataTransferErrorResolver()
//        let networkError = NetworkError.notConnected
//        
//        // When
//        let resolvedError = resolver.resolve(error: networkError)
//        
//        // Then
//        #expect(resolvedError as? NetworkError == networkError)
//    }
}

// MARK: - Test Models

private struct TestModel: Codable, Equatable {
    let id: Int
    let name: String
}

private enum CustomError: Error {
    case genericError
    case customNetworkError
}

// MARK: - Test-Specific Endpoints

private struct TestRawDataEndpoint: ResponseRequestable {
    typealias Response = Data
    
    let path = "test"
    let isFullPath = false
    let method = HTTPMethodType.get
    let headerParameters: [String: String] = [:]
    let queryParametersEncodable: Encodable? = nil
    let queryParameters: [String: Any] = [:]
    let bodyParametersEncodable: Encodable? = nil
    let bodyParameters: [String: Any] = [:]
    let bodyEncoder: BodyEncoder = JSONBodyEncoder()
    let responseDecoder: ResponseDecoder = RawDataResponseDecoder()
}
