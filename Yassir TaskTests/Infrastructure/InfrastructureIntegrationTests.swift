//
//  InfrastructureIntegrationTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 27/08/2025.
//

import Testing
import Foundation
@testable import Yassir_Task

@Suite("Infrastructure Integration Tests")
struct InfrastructureIntegrationTests {
    
    // MARK: - Full Stack Integration Tests
    
    @Test("Should complete full request flow from DataTransferService to NetworkService")
    func testFullRequestFlow() async throws {
        // Given - Complete infrastructure setup
        let expectedUser = TestUser.mock()
        let mockData = JSONTestData.user(expectedUser)
        let sessionManager = MockNetworkSessionManager(
            mockData: mockData,
            mockResponse: HTTPURLResponse.success()
        )
        let config = TestNetworkConfig.development()
        let networkLogger = MockNetworkErrorLogger()
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: sessionManager,
            logger: networkLogger
        )
        
        let dataTransferLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorLogger: dataTransferLogger
        )
        
        let endpoint = TestEndpoint<TestUser>.getUserEndpoint()
        
        // When
        let result: TestUser = try await dataTransferService.request(with: endpoint)
        
        // Then
        #expect(result == expectedUser)
        #expect(sessionManager.requestCallCount == 1)
        #expect(networkLogger.loggedRequests.count == 1)
        #expect(networkLogger.loggedResponses.count == 1)
        #expect(networkLogger.loggedErrors.isEmpty)
        #expect(dataTransferLogger.loggedErrors.isEmpty)
    }
    
    @Test("Should handle error propagation through full stack")
    func testErrorPropagationThroughFullStack() async throws {
        // Given - Setup with network error
        let networkError = URLError(.notConnectedToInternet)
        let sessionManager = MockNetworkSessionManager(shouldThrow: networkError)
        let config = TestNetworkConfig.development()
        let networkLogger = MockNetworkErrorLogger()
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: sessionManager,
            logger: networkLogger
        )
        
        let dataTransferLogger = MockDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorLogger: dataTransferLogger
        )
        
        let endpoint = TestEndpoint<TestUser>.getUserEndpoint()
        
        // When & Then
        await #expect(throws: DataTransferError.self) {
            let _: TestUser = try await dataTransferService.request(with: endpoint)
        }
        
        // Verify error was logged at all levels
        #expect(networkLogger.loggedErrors.count == 1)
        #expect(dataTransferLogger.loggedErrors.count == 1)
    }
    
    @Test("Should handle complex endpoint with query and body parameters")
    func testComplexEndpointIntegration() async throws {
        // Given
        let queryParams = TestQueryParameters.defaultValues()
        let bodyParams = TestBodyParameters.mock()
        let expectedUsers = [TestUser.mock()]
        let mockData = JSONTestData.users(expectedUsers)
        
        let sessionManager = MockNetworkSessionManager(
            mockData: mockData,
            mockResponse: HTTPURLResponse.success()
        )
        let config = TestNetworkConfig.production()
        let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager)
        let dataTransferService = DefaultDataTransferService(with: networkService)
        
        let endpoint = TestEndpoint<[TestUser]>(
            path: "users/search",
            method: .post,
            queryParametersEncodable: queryParams,
            bodyParametersEncodable: bodyParams
        )
        
        // When
        let result: [TestUser] = try await dataTransferService.request(with: endpoint)
        
        // Then
        #expect(result == expectedUsers)
        
        // Verify request details
        let request = sessionManager.lastRequest!
        #expect(request.httpMethod == "POST")
        #expect(request.httpBody != nil)
        #expect(request.url?.query?.contains("page=1") == true)
        #expect(request.url?.query?.contains("limit=20") == true)
    }
    
    // MARK: - Configuration Integration Tests
    
    @Test("Should use different configurations correctly")
    func testDifferentConfigurationsIntegration() async throws {
        let configurations = [
            ("Production", TestNetworkConfig.production()),
            ("Staging", TestNetworkConfig.staging()),
            ("Development", TestNetworkConfig.development())
        ]
        
        for (name, config) in configurations {
            // Given
            let mockData = JSONTestData.user()
            let sessionManager = MockNetworkSessionManager(
                mockData: mockData,
                mockResponse: HTTPURLResponse.success()
            )
            let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager)
            let dataTransferService = DefaultDataTransferService(with: networkService)
            let endpoint = TestEndpoint<TestUser>.getUserEndpoint()
            
            // When
            let _: TestUser = try await dataTransferService.request(with: endpoint)
            
            // Then
            let request = sessionManager.lastRequest!
            #expect(request.url?.host == config.baseURL.host, "Failed for \(name) config")
            #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json", "Failed for \(name) config")
        }
    }
    
    // MARK: - Decoder Integration Tests
    
    @Test("Should work with different response decoders")
    func testDifferentResponseDecodersIntegration() async throws {
        // Test JSON Decoder
        await testWithDecoder(
            decoder: JSONResponseDecoder(),
            data: JSONTestData.user(),
            expectedType: TestUser.self
        )
        
        // Test Raw Data Decoder
        await testWithDecoder(
            decoder: RawDataResponseDecoder(),
            data: JSONTestData.string("raw data"),
            expectedType: Data.self
        )
    }
    
    private func testWithDecoder<T: Decodable & Equatable>(
        decoder: ResponseDecoder,
        data: Data,
        expectedType: T.Type
    ) async {
        // Given
        let sessionManager = MockNetworkSessionManager(
            mockData: data,
            mockResponse: HTTPURLResponse.success()
        )
        let config = TestNetworkConfig()
        let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager)
        let dataTransferService = DefaultDataTransferService(with: networkService)
        
        let endpoint = TestEndpoint<T>(responseDecoder: decoder)
        
        // When & Then
        do {
            let _: T = try await dataTransferService.request(with: endpoint)
            // Success - decoder worked correctly
        } catch {
            Issue.record("Decoder integration failed: \(error)")
        }
    }
    
    // MARK: - Body Encoder Integration Tests
    
    @Test("Should work with different body encoders")
    func testDifferentBodyEncodersIntegration() async throws {
        let bodyParams = ["name": "John", "age": 30] as [String: Any]
        
        // Test JSON Body Encoder
        await testWithBodyEncoder(
            encoder: JSONBodyEncoder(),
            bodyParams: bodyParams,
            expectedContentType: "application/json"
        )
        
        // Test ASCII Body Encoder
        await testWithBodyEncoder(
            encoder: AsciiBodyEncoder(),
            bodyParams: bodyParams,
            expectedContentType: "application/x-www-form-urlencoded"
        )
    }
    
    private func testWithBodyEncoder(
        encoder: BodyEncoder,
        bodyParams: [String: Any],
        expectedContentType: String
    ) async {
        // Given
        let sessionManager = MockNetworkSessionManager(
            mockData: JSONTestData.user(),
            mockResponse: HTTPURLResponse.success()
        )
        let config = TestNetworkConfig(headers: ["Content-Type": expectedContentType])
        let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager)
        let dataTransferService = DefaultDataTransferService(with: networkService)
        
        let endpoint = TestEndpoint<TestUser>(
            method: .post,
            bodyParameters: bodyParams,
            bodyEncoder: encoder
        )
        
        // When
        do {
            let _: TestUser = try await dataTransferService.request(with: endpoint)
            
            // Then
            let request = sessionManager.lastRequest!
            #expect(request.httpBody != nil)
            #expect(request.value(forHTTPHeaderField: "Content-Type") == expectedContentType)
        } catch {
            Issue.record("Body encoder integration failed: \(error)")
        }
    }
    
    // MARK: - Concurrent Requests Integration Tests
    
    @Test("Should handle concurrent requests correctly")
    func testConcurrentRequestsIntegration() async throws {
        // Given
        let sessionManager = MockNetworkSessionManager(
            mockData: JSONTestData.user(),
            mockResponse: HTTPURLResponse.success(),
            delay: 0.1 // Small delay to test concurrency
        )
        let config = TestNetworkConfig()
        let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager)
        let dataTransferService = DefaultDataTransferService(with: networkService)
        
        let endpoint = TestEndpoint<TestUser>.getUserEndpoint()
        
        // When - Make multiple concurrent requests
        async let request1: TestUser = dataTransferService.request(with: endpoint)
        async let request2: TestUser = dataTransferService.request(with: endpoint)
        async let request3: TestUser = dataTransferService.request(with: endpoint)
        
        let results = try await [request1, request2, request3]
        
        // Then
        #expect(results.count == 3)
        #expect(sessionManager.requestCallCount == 3)
        
        // All requests should succeed
        for result in results {
            #expect(result.id == TestUser.mock().id)
        }
    }
    
    // MARK: - Error Recovery Integration Tests
    
    @Test("Should handle error recovery scenarios")
    func testErrorRecoveryIntegration() async throws {
        // Given - Custom error resolver that converts network errors
        let customResolver = CustomDataTransferErrorResolver()
        let sessionManager = MockNetworkSessionManager(
            shouldThrow: URLError(.notConnectedToInternet)
        )
        let config = TestNetworkConfig()
        let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager)
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: customResolver
        )
        
        let endpoint = TestEndpoint<TestUser>.getUserEndpoint()
        
        // When & Then
        await #expect(throws: DataTransferError.self) {
            let _: TestUser = try await dataTransferService.request(with: endpoint)
        }
        
        // Verify custom resolver was called
        #expect(customResolver.resolveCallCount == 1)
    }
    
    // MARK: - Memory Management Integration Tests
    
    @Test("Should not create retain cycles")
    func testMemoryManagementIntegration() async throws {
        // Given
        weak var weakDataTransferService: DefaultDataTransferService?
        weak var weakNetworkService: DefaultNetworkService?
        
        do {
            let sessionManager = MockNetworkSessionManager(
                mockData: JSONTestData.user(),
                mockResponse: HTTPURLResponse.success()
            )
            let config = TestNetworkConfig()
            let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager)
            let dataTransferService = DefaultDataTransferService(with: networkService)
            
            weakNetworkService = networkService
            weakDataTransferService = dataTransferService
            
            let endpoint = TestEndpoint<TestUser>.getUserEndpoint()
            let _: TestUser = try await dataTransferService.request(with: endpoint)
        }
        
        // Then - Objects should be deallocated after scope ends
        #expect(weakDataTransferService == nil)
        #expect(weakNetworkService == nil)
    }
}

// MARK: - Custom Test Components

private class CustomDataTransferErrorResolver: DataTransferErrorResolver {
    var resolveCallCount = 0
    
    func resolve(error: NetworkError) -> Error {
        resolveCallCount += 1
        
        switch error {
        case .notConnected:
            return TestError.networkTimeout
        case .cancelled:
            return TestError.authenticationFailed
        default:
            return error
        }
    }
}
