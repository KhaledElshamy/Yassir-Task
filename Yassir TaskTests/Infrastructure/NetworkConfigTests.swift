//
//  NetworkConfigTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 27/08/2025.
//

import Testing
import Foundation
@testable import Yassir_Task

@Suite("NetworkConfig Tests")
struct NetworkConfigTests {
    
    // MARK: - ApiDataNetworkConfig Tests
    
    @Test("Should initialize ApiDataNetworkConfig with all parameters")
    func testApiDataNetworkConfigFullInitialization() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        let headers = ["Authorization": "Bearer token", "Content-Type": "application/json"]
        let queryParameters = ["api_key": "12345", "version": "v1"]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers,
            queryParameters: queryParameters
        )
        
        // Then
        #expect(config.baseURL == baseURL)
        #expect(config.headers == headers)
        #expect(config.queryParameters == queryParameters)
    }
    
    @Test("Should initialize ApiDataNetworkConfig with default empty headers and query parameters")
    func testApiDataNetworkConfigDefaultInitialization() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        
        // When
        let config = ApiDataNetworkConfig(baseURL: baseURL)
        
        // Then
        #expect(config.baseURL == baseURL)
        #expect(config.headers.isEmpty)
        #expect(config.queryParameters.isEmpty)
    }
    
    @Test("Should initialize ApiDataNetworkConfig with only headers")
    func testApiDataNetworkConfigWithOnlyHeaders() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        let headers = ["Authorization": "Bearer token"]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers
        )
        
        // Then
        #expect(config.baseURL == baseURL)
        #expect(config.headers == headers)
        #expect(config.queryParameters.isEmpty)
    }
    
    @Test("Should initialize ApiDataNetworkConfig with only query parameters")
    func testApiDataNetworkConfigWithOnlyQueryParameters() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        let queryParameters = ["api_key": "12345"]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            queryParameters: queryParameters
        )
        
        // Then
        #expect(config.baseURL == baseURL)
        #expect(config.headers.isEmpty)
        #expect(config.queryParameters == queryParameters)
    }
    
    @Test("Should conform to NetworkConfigurable protocol")
    func testApiDataNetworkConfigProtocolConformance() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        let config: NetworkConfigurable = ApiDataNetworkConfig(baseURL: baseURL)
        
        // When & Then
        #expect(config.baseURL == baseURL)
        #expect(config.headers.isEmpty)
        #expect(config.queryParameters.isEmpty)
    }
    
    @Test("Should handle different URL schemes")
    func testApiDataNetworkConfigWithDifferentURLSchemes() async throws {
        let urlSchemes = [
            "https://api.example.com",
            "http://localhost:8080",
            "https://staging.api.example.com/v2",
            "http://192.168.1.100:3000/api"
        ]
        
        for urlString in urlSchemes {
            // Given
            let baseURL = URL(string: urlString)!
            
            // When
            let config = ApiDataNetworkConfig(baseURL: baseURL)
            
            // Then
            #expect(config.baseURL == baseURL)
            #expect(config.baseURL.absoluteString == urlString)
        }
    }
    
    @Test("Should handle complex headers")
    func testApiDataNetworkConfigWithComplexHeaders() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        let headers = [
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "iOS App/1.0",
            "X-API-Version": "2023-01-01",
            "X-Request-ID": "12345-67890-abcdef"
        ]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers
        )
        
        // Then
        #expect(config.headers == headers)
        #expect(config.headers.count == 6)
        #expect(config.headers["Authorization"] == "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9")
        #expect(config.headers["Content-Type"] == "application/json")
        #expect(config.headers["X-API-Version"] == "2023-01-01")
    }
    
    @Test("Should handle complex query parameters")
    func testApiDataNetworkConfigWithComplexQueryParameters() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        let queryParameters = [
            "api_key": "sk_test_1234567890",
            "version": "v2",
            "format": "json",
            "limit": "100",
            "offset": "0",
            "sort": "created_at",
            "order": "desc",
            "include": "metadata,relations"
        ]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            queryParameters: queryParameters
        )
        
        // Then
        #expect(config.queryParameters == queryParameters)
        #expect(config.queryParameters.count == 8)
        #expect(config.queryParameters["api_key"] == "sk_test_1234567890")
        #expect(config.queryParameters["limit"] == "100")
        #expect(config.queryParameters["include"] == "metadata,relations")
    }
    
    @Test("Should be immutable after initialization")
    func testApiDataNetworkConfigImmutability() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        var headers = ["Authorization": "Bearer token"]
        var queryParameters = ["api_key": "12345"]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers,
            queryParameters: queryParameters
        )
        
        // Modify original dictionaries
        headers["New-Header"] = "new-value"
        queryParameters["new_param"] = "new_value"
        
        // Then - Config should not be affected
        #expect(config.headers.count == 1)
        #expect(config.queryParameters.count == 1)
        #expect(config.headers["New-Header"] == nil)
        #expect(config.queryParameters["new_param"] == nil)
    }
    
    // MARK: - Real-world Usage Tests
    
    @Test("Should create production config")
    func testProductionConfig() async throws {
        // Given
        let baseURL = URL(string: "https://api.production.com")!
        let headers = [
            "Authorization": "Bearer prod-token",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "Yassir-App/1.0"
        ]
        let queryParameters = [
            "api_version": "2023-01-01"
        ]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers,
            queryParameters: queryParameters
        )
        
        // Then
        #expect(config.baseURL.absoluteString == "https://api.production.com")
        #expect(config.headers["Authorization"] == "Bearer prod-token")
        #expect(config.queryParameters["api_version"] == "2023-01-01")
    }
    
    @Test("Should create staging config")
    func testStagingConfig() async throws {
        // Given
        let baseURL = URL(string: "https://staging-api.example.com")!
        let headers = [
            "Authorization": "Bearer staging-token",
            "Content-Type": "application/json",
            "X-Environment": "staging"
        ]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers
        )
        
        // Then
        #expect(config.baseURL.absoluteString == "https://staging-api.example.com")
        #expect(config.headers["X-Environment"] == "staging")
    }
    
    @Test("Should create development config")
    func testDevelopmentConfig() async throws {
        // Given
        let baseURL = URL(string: "http://localhost:8080")!
        let headers = [
            "Content-Type": "application/json",
            "X-Debug": "true"
        ]
        let queryParameters = [
            "debug": "1",
            "verbose": "true"
        ]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers,
            queryParameters: queryParameters
        )
        
        // Then
        #expect(config.baseURL.absoluteString == "http://localhost:8080")
        #expect(config.headers["X-Debug"] == "true")
        #expect(config.queryParameters["debug"] == "1")
        #expect(config.queryParameters["verbose"] == "true")
    }
    
    // MARK: - Edge Cases
    
    @Test("Should handle empty strings in headers and query parameters")
    func testConfigWithEmptyStrings() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        let headers = ["Empty-Header": ""]
        let queryParameters = ["empty_param": ""]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers,
            queryParameters: queryParameters
        )
        
        // Then
        #expect(config.headers["Empty-Header"] == "")
        #expect(config.queryParameters["empty_param"] == "")
    }
    
    @Test("Should handle special characters in headers and query parameters")
    func testConfigWithSpecialCharacters() async throws {
        // Given
        let baseURL = URL(string: "https://api.example.com")!
        let headers = ["X-Special": "value with spaces & symbols!@#$%"]
        let queryParameters = ["special_param": "value+with+plus&ampersand=equals"]
        
        // When
        let config = ApiDataNetworkConfig(
            baseURL: baseURL,
            headers: headers,
            queryParameters: queryParameters
        )
        
        // Then
        #expect(config.headers["X-Special"] == "value with spaces & symbols!@#$%")
        #expect(config.queryParameters["special_param"] == "value+with+plus&ampersand=equals")
    }
}
