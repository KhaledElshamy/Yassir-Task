//
//  BuildVerificationTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 27/08/2025.
//

import Testing
import Foundation
@testable import Yassir_Task

@Suite("Build Verification Tests")
struct BuildVerificationTests {
    
    @Test("Should verify all infrastructure components can be instantiated")
    func testInfrastructureComponentsInstantiation() async throws {
        // Given - Test that all main infrastructure components can be created
        let config = ApiDataNetworkConfig(baseURL: URL(string: "https://api.test.com")!)
        let sessionManager = DefaultNetworkSessionManager()
        let logger = DefaultNetworkErrorLogger()
        let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager, logger: logger)
        
        let errorResolver = DefaultDataTransferErrorResolver()
        let dataTransferLogger = DefaultDataTransferErrorLogger()
        let dataTransferService = DefaultDataTransferService(
            with: networkService,
            errorResolver: errorResolver,
            errorLogger: dataTransferLogger
        )
        
        // When & Then - Should not crash and all components should be properly initialized
        #expect(config.baseURL.absoluteString == "https://api.test.com")
        #expect(networkService != nil)
        #expect(dataTransferService != nil)
    }
    
    @Test("Should verify all test helpers can be instantiated")
    func testTestHelpersInstantiation() async throws {
        // Given - Test that all test helper components can be created
        let testUser = TestUser.mock()
        let testConfig = TestNetworkConfig()
        let mockNetworkService = MockNetworkService.successWithUser()
        let mockSessionManager = MockNetworkSessionManager()
        let mockLogger = MockNetworkErrorLogger()
        
        // Test endpoint factory methods work correctly
        let userEndpoint = TestEndpoint<TestUser>.getUserEndpoint()
        let searchEndpoint = TestEndpoint<[TestUser]>.searchUsersEndpoint(query: TestQueryParameters.defaultValues())
        
        // When & Then - Should not crash and all helpers should be properly initialized
        #expect(testUser.id == 1)
        #expect(testConfig.baseURL.absoluteString == "https://api.test.com")
        #expect(mockNetworkService != nil)
        #expect(mockSessionManager != nil)
        #expect(mockLogger != nil)
        #expect(userEndpoint.path == "users/1")
        #expect(searchEndpoint.path == "users/search")
    }
    
    @Test("Should verify all decoders work correctly")
    func testDecodersInstantiation() async throws {
        // Given
        let jsonDecoder = JSONResponseDecoder()
        let rawDataDecoder = RawDataResponseDecoder()
        
        let testUser = TestUser.mock()
        let testData = try JSONEncoder().encode(testUser)
        let rawData = "test".data(using: .utf8)!
        
        // When & Then
        let decodedUser: TestUser = try jsonDecoder.decode(testData)
        #expect(decodedUser.id == testUser.id)
        
        let decodedRawData: Data = try rawDataDecoder.decode(rawData)
        #expect(decodedRawData == rawData)
    }
}
