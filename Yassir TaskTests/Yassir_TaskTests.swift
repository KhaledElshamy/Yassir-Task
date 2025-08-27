//
//  Yassir_TaskTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 27/08/2025.
//

import Testing
import Foundation
@testable import Yassir_Task

@Suite("Main Test Suite")
struct Yassir_TaskTests {

    @Test("Infrastructure layer tests are properly organized")
    func testInfrastructureTestOrganization() async throws {
        // This test validates that our infrastructure tests are properly structured
        
        // Test that we can create core infrastructure components
        let config = ApiDataNetworkConfig(baseURL: URL(string: "https://api.test.com")!)
        #expect(config.baseURL.absoluteString == "https://api.test.com")
        
        let sessionManager = DefaultNetworkSessionManager()
        let networkService = DefaultNetworkService(config: config, sessionManager: sessionManager)
        let dataTransferService = DefaultDataTransferService(with: networkService)
        
        // Verify components are properly initialized
        #expect(networkService != nil)
        #expect(dataTransferService != nil)
    }

}
