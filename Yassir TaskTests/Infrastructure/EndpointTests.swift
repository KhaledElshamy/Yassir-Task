//
//  EndpointTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 27/08/2025.
//

import Testing
import Foundation
@testable import Yassir_Task

@Suite("Endpoint Tests")
struct EndpointTests {
    
    // MARK: - URL Generation Tests
    
    @Test("Should generate correct URL with relative path")
    func testURLGenerationWithRelativePath() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let endpoint = Endpoint<String>(
            path: "users/123",
            method: .get
        )
        
        // When
        let url = try endpoint.url(with: config)
        
        // Then
        #expect(url.absoluteString == "https://api.example.com/users/123")
    }
    
    @Test("Should generate correct URL with full path")
    func testURLGenerationWithFullPath() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let endpoint = Endpoint<String>(
            path: "https://different-api.com/users/123",
            isFullPath: true,
            method: .get
        )
        
        // When
        let url = try endpoint.url(with: config)
        
        // Then
        #expect(url.absoluteString == "https://different-api.com/users/123")
    }
    
    @Test("Should handle base URL with trailing slash")
    func testURLGenerationWithTrailingSlash() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com/")!)
        let endpoint = Endpoint<String>(
            path: "users/123",
            method: .get
        )
        
        // When
        let url = try endpoint.url(with: config)
        
        // Then
        #expect(url.absoluteString == "https://api.example.com/users/123")
    }
    
    @Test("Should add query parameters from endpoint")
    func testURLGenerationWithEndpointQueryParameters() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let endpoint = Endpoint<String>(
            path: "users",
            method: .get,
            queryParameters: ["page": 1, "limit": 10]
        )
        
        // When
        let url = try endpoint.url(with: config)
        
        // Then
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems!
        #expect(queryItems.contains { $0.name == "page" && $0.value == "1" })
        #expect(queryItems.contains { $0.name == "limit" && $0.value == "10" })
    }
    
    @Test("Should add query parameters from config")
    func testURLGenerationWithConfigQueryParameters() async throws {
        // Given
        let config = TestNetworkConfig(queryParameters: ["api_key": "test123"])
        let endpoint = Endpoint<String>(
            path: "users",
            method: .get
        )
        
        // When
        let url = try endpoint.url(with: config)
        
        // Then
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems!
        #expect(queryItems.contains { $0.name == "api_key" && $0.value == "test123" })
    }
    
    @Test("Should combine endpoint and config query parameters")
    func testURLGenerationWithCombinedQueryParameters() async throws {
        // Given
        let config = TestNetworkConfig(queryParameters: ["api_key": "test123"])
        let endpoint = Endpoint<String>(
            path: "users",
            method: .get,
            queryParameters: ["page": 1]
        )
        
        // When
        let url = try endpoint.url(with: config)
        
        // Then
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems!
        #expect(queryItems.contains { $0.name == "api_key" && $0.value == "test123" })
        #expect(queryItems.contains { $0.name == "page" && $0.value == "1" })
    }
    
    @Test("Should handle encodable query parameters")
    func testURLGenerationWithEncodableQueryParameters() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let queryParams = TestQueryParams(userId: 123, active: true)
        let endpoint = Endpoint<String>(
            path: "users",
            method: .get,
            queryParametersEncodable: queryParams
        )
        
        // When
        let url = try endpoint.url(with: config)
        
        // Then
        #expect(url.absoluteString.contains("userId=123"))
        #expect(url.absoluteString.contains("active=1"))
        #expect(url.absoluteString.contains("users"))
        
        // Also verify using URLComponents for more detailed testing
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems ?? []
        
        let userIdItem = queryItems.first { $0.name == "userId" }
        let activeItem = queryItems.first { $0.name == "active" }
        
        #expect(userIdItem?.value == "123")
        #expect(activeItem?.value == "1")
    }
    
    @Test("Should handle edge cases in URL generation")
    func testURLGenerationEdgeCases() async throws {
        // Given - Test various edge cases that should still work
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        
        // Test 1: Empty path
        let emptyPathEndpoint = Endpoint<String>(path: "", method: .get)
        let url1 = try emptyPathEndpoint.url(with: config)
        #expect(url1.absoluteString == "https://api.example.com/")
        
        // Test 2: Path with special characters that should be encoded
        let specialCharsEndpoint = Endpoint<String>(path: "users/test user", method: .get)
        let url2 = try specialCharsEndpoint.url(with: config)
        #expect(url2.absoluteString.contains("users/test%20user"))
        
        // Test 3: Very long path (but still valid)
        let longPath = String(repeating: "a", count: 100)
        let longPathEndpoint = Endpoint<String>(path: "users/\(longPath)", method: .get)
        let url3 = try longPathEndpoint.url(with: config)
        #expect(url3.absoluteString.contains(longPath))
    }
    
    // MARK: - URLRequest Generation Tests
    
    @Test("Should generate correct URLRequest with GET method")
    func testURLRequestGenerationGET() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let endpoint = Endpoint<String>(
            path: "users",
            method: .get,
            headerParameters: ["Custom-Header": "custom-value"]
        )
        
        // When
        let request = try endpoint.urlRequest(with: config)
        
        // Then
        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "https://api.example.com/users")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Custom-Header") == "custom-value")
        #expect(request.httpBody == nil)
    }
    
    @Test("Should generate correct URLRequest with POST method and body")
    func testURLRequestGenerationPOST() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let bodyParams = ["name": "John", "age": 30] as [String: Any]
        let endpoint = Endpoint<String>(
            path: "users",
            method: .post,
            bodyParameters: bodyParams
        )
        
        // When
        let request = try endpoint.urlRequest(with: config)
        
        // Then
        #expect(request.httpMethod == "POST")
        #expect(request.httpBody != nil)
        
        // Verify body content
        let bodyData = request.httpBody!
        let bodyObject = try JSONSerialization.jsonObject(with: bodyData) as! [String: Any]
        #expect(bodyObject["name"] as? String == "John")
        #expect(bodyObject["age"] as? Int == 30)
    }
    
    @Test("Should generate URLRequest with encodable body parameters")
    func testURLRequestGenerationWithEncodableBody() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let bodyParams = TestBodyParams(name: "John", age: 30)
        let endpoint = Endpoint<String>(
            path: "users",
            method: .post,
            bodyParametersEncodable: bodyParams
        )
        
        // When
        let request = try endpoint.urlRequest(with: config)
        
        // Then
        #expect(request.httpMethod == "POST")
        #expect(request.httpBody != nil)
        
        // Verify body content
        let bodyData = request.httpBody!
        let bodyObject = try JSONSerialization.jsonObject(with: bodyData) as! [String: Any]
        #expect(bodyObject["name"] as? String == "John")
        #expect(bodyObject["age"] as? Int == 30)
    }
    
    @Test("Should merge headers from config and endpoint")
    func testURLRequestHeaderMerging() async throws {
        // Given
        let config = TestNetworkConfig(
            baseURL: URL(string: "https://api.example.com")!,
            headers: ["Authorization": "Bearer token", "Content-Type": "application/json"]
        )
        let endpoint = Endpoint<String>(
            path: "users",
            method: .get,
            headerParameters: ["Custom-Header": "custom-value"]
        )
        
        // When
        let request = try endpoint.urlRequest(with: config)
        
        // Then
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
        #expect(request.value(forHTTPHeaderField: "Custom-Header") == "custom-value")
    }
    
    @Test("Should override config headers with endpoint headers")
    func testURLRequestHeaderOverride() async throws {
        // Given
        let config = TestNetworkConfig(
            baseURL: URL(string: "https://api.example.com")!,
            headers: ["Content-Type": "text/plain"]
        )
        let endpoint = Endpoint<String>(
            path: "users",
            method: .get,
            headerParameters: ["Content-Type": "application/xml"]
        )
        
        // When
        let request = try endpoint.urlRequest(with: config)
        
        // Then
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/xml")
    }
    
    // MARK: - Body Encoder Tests
    
    @Test("Should test JSONBodyEncoder")
    func testJSONBodyEncoder() async throws {
        // Given
        let encoder = JSONBodyEncoder()
        let parameters = ["name": "John", "age": 30] as [String: Any]
        
        // When
        let data = encoder.encode(parameters)
        
        // Then
        #expect(data != nil)
        let decoded = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
        #expect(decoded["name"] as? String == "John")
        #expect(decoded["age"] as? Int == 30)
    }
    
    @Test("Should test AsciiBodyEncoder")
    func testAsciiBodyEncoder() async throws {
        // Given
        let encoder = AsciiBodyEncoder()
        let parameters = ["name": "John", "age": 30] as [String: Any]
        
        // When
        let data = encoder.encode(parameters)
        
        // Then
        #expect(data != nil)
        let string = String(data: data!, encoding: .ascii)!
        #expect(string.contains("name=John"))
        #expect(string.contains("age=30"))
        #expect(string.contains("&"))
    }
    
    @Test("Should handle empty body parameters")
    func testEmptyBodyParameters() async throws {
        // Given
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let endpoint = Endpoint<String>(
            path: "users",
            method: .post,
            bodyParameters: [:]
        )
        
        // When
        let request = try endpoint.urlRequest(with: config)
        
        // Then
        #expect(request.httpBody == nil)
    }
    
    // MARK: - HTTP Method Tests
    
    @Test("Should test all HTTP methods")
    func testAllHTTPMethods() async throws {
        let methods: [(HTTPMethodType, String)] = [
            (.get, "GET"),
            (.head, "HEAD"),
            (.post, "POST"),
            (.put, "PUT"),
            (.patch, "PATCH"),
            (.delete, "DELETE")
        ]
        
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        
        for (method, expectedString) in methods {
            // Given
            let endpoint = Endpoint<String>(path: "test", method: method)
            
            // When
            let request = try endpoint.urlRequest(with: config)
            
            // Then
            #expect(request.httpMethod == expectedString)
        }
    }
    
    // MARK: - Extension Tests
    
    @Test("Should test endpoint extensions work properly")
    func testEndpointExtensionsIntegration() async throws {
        // Given - Test that internal extensions work through the public API
        let config = TestNetworkConfig(baseURL: URL(string: "https://api.example.com")!)
        let bodyParams = TestBodyParams(name: "John", age: 30)
        let queryParams = TestQueryParams(userId: 123, active: true)
        
        let endpoint = Endpoint<String>(
            path: "users",
            method: .post,
            queryParametersEncodable: queryParams,
            bodyParametersEncodable: bodyParams
        )
        
        // When
        let request = try endpoint.urlRequest(with: config)
        
        // Then - Verify that the extensions worked correctly through the public API
        #expect(request.httpMethod == "POST")
        #expect(request.url?.query?.contains("userId=123") == true)
        #expect(request.url?.query?.contains("active=1") == true)
        #expect(request.httpBody != nil)
        
        // Verify body was properly encoded
        if let bodyData = request.httpBody {
            let bodyObject = try JSONSerialization.jsonObject(with: bodyData) as! [String: Any]
            #expect(bodyObject["name"] as? String == "John")
            #expect(bodyObject["age"] as? Int == 30)
        }
    }
}

// MARK: - Test-Specific Models

private struct TestQueryParams: Codable {
    let userId: Int
    let active: Bool
}

private struct TestBodyParams: Codable {
    let name: String
    let age: Int
}
