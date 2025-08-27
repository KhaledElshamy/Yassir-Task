//
//  InfrastructureTestHelpers.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 27/08/2025.
//

import Foundation
@testable import Yassir_Task

// MARK: - Test Models

/// Generic test model for JSON testing
struct TestUser: Codable, Equatable {
    let id: Int
    let name: String
    let email: String
    let isActive: Bool
    
    static func mock() -> TestUser {
        return TestUser(
            id: 1,
            name: "John Doe",
            email: "john@example.com",
            isActive: true
        )
    }
}

/// Test model for complex nested JSON
struct TestResponse<T: Codable>: Codable, Equatable where T: Equatable {
    let data: T
    let status: String
    let message: String
    
    static func success(with data: T) -> TestResponse<T> {
        return TestResponse(
            data: data,
            status: "success",
            message: "Request completed successfully"
        )
    }
    
    static func error(message: String = "An error occurred") -> TestResponse<T> where T == String {
        return TestResponse(
            data: "",
            status: "error",
            message: message
        ) as! TestResponse<T>
    }
}

/// Test query parameters model
struct TestQueryParameters: Codable {
    let page: Int
    let limit: Int
    let search: String?
    let sortBy: String?
    
    static func defaultValues() -> TestQueryParameters {
        return TestQueryParameters(
            page: 1,
            limit: 20,
            search: nil,
            sortBy: "created_at"
        )
    }
}

/// Test body parameters model
struct TestBodyParameters: Codable {
    let name: String
    let email: String
    let metadata: [String: String]?
    
    static func mock() -> TestBodyParameters {
        return TestBodyParameters(
            name: "Test User",
            email: "test@example.com",
            metadata: ["source": "test", "version": "1.0"]
        )
    }
}

// MARK: - Test Endpoints

/// Generic test endpoint for various response types
struct TestEndpoint<Response: Decodable>: ResponseRequestable {
    typealias Response = Response
    
    let path: String
    let isFullPath: Bool
    let method: HTTPMethodType
    let headerParameters: [String: String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String: Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String: Any]
    let bodyEncoder: BodyEncoder
    let responseDecoder: ResponseDecoder
    
    init(
        path: String = "test",
        isFullPath: Bool = false,
        method: HTTPMethodType = .get,
        headerParameters: [String: String] = [:],
        queryParametersEncodable: Encodable? = nil,
        queryParameters: [String: Any] = [:],
        bodyParametersEncodable: Encodable? = nil,
        bodyParameters: [String: Any] = [:],
        bodyEncoder: BodyEncoder = JSONBodyEncoder(),
        responseDecoder: ResponseDecoder = JSONResponseDecoder()
    ) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
    }
    
    // Factory methods for common scenarios
    static func getUserEndpoint() -> TestEndpoint<Response> {
        return TestEndpoint<Response>(
            path: "users/1",
            method: .get
        )
    }
    
    static func createUserEndpoint(user: TestBodyParameters) -> TestEndpoint<Response> {
        return TestEndpoint<Response>(
            path: "users",
            method: .post,
            bodyParametersEncodable: user
        )
    }
    
    static func searchUsersEndpoint(query: TestQueryParameters) -> TestEndpoint<Response> {
        return TestEndpoint<Response>(
            path: "users/search",
            method: .get,
            queryParametersEncodable: query
        )
    }
}

/// Void endpoint for testing operations that don't return data
struct TestVoidEndpoint: ResponseRequestable {
    typealias Response = Void
    
    let path: String
    let isFullPath: Bool
    let method: HTTPMethodType
    let headerParameters: [String: String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String: Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String: Any]
    let bodyEncoder: BodyEncoder
    let responseDecoder: ResponseDecoder
    
    init(
        path: String = "test/action",
        method: HTTPMethodType = .post,
        bodyParametersEncodable: Encodable? = nil
    ) {
        self.path = path
        self.isFullPath = false
        self.method = method
        self.headerParameters = [:]
        self.queryParametersEncodable = nil
        self.queryParameters = [:]
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = [:]
        self.bodyEncoder = JSONBodyEncoder()
        self.responseDecoder = JSONResponseDecoder()
    }
}

/// Invalid endpoint for testing error scenarios
struct TestInvalidEndpoint: Requestable {
    let path = "invalid://url with spaces"
    let isFullPath = true
    let method = HTTPMethodType.get
    let headerParameters: [String: String] = [:]
    let queryParametersEncodable: Encodable? = nil
    let queryParameters: [String: Any] = [:]
    let bodyParametersEncodable: Encodable? = nil
    let bodyParameters: [String: Any] = [:]
    let bodyEncoder: BodyEncoder = JSONBodyEncoder()
}

// MARK: - Mock Network Components

/// Mock NetworkService for testing
class MockNetworkService: NetworkService {
    var requestCallCount = 0
    var lastRequestedEndpoint: Requestable?
    
    private let mockData: Data?
    private let shouldThrow: Error?
    private let delay: TimeInterval
    
    init(
        mockData: Data? = nil,
        shouldThrow: Error? = nil,
        delay: TimeInterval = 0
    ) {
        self.mockData = mockData
        self.shouldThrow = shouldThrow
        self.delay = delay
    }
    
    func request(endpoint: Requestable) async throws -> Data? {
        requestCallCount += 1
        lastRequestedEndpoint = endpoint
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if let error = shouldThrow {
            throw error
        }
        
        return mockData
    }
    
    // Helper methods for common scenarios
    static func successWithUser(_ user: TestUser = TestUser.mock()) -> MockNetworkService {
        let data = try! JSONEncoder().encode(user)
        return MockNetworkService(mockData: data)
    }
    
    static func successWithUsers(_ users: [TestUser] = [TestUser.mock()]) -> MockNetworkService {
        let data = try! JSONEncoder().encode(users)
        return MockNetworkService(mockData: data)
    }
    
    static func networkError(_ error: NetworkError = .notConnected) -> MockNetworkService {
        return MockNetworkService(shouldThrow: error)
    }
    
    static func emptyResponse() -> MockNetworkService {
        return MockNetworkService(mockData: Data())
    }
}

/// Mock NetworkSessionManager for testing
class MockNetworkSessionManager: NetworkSessionManager {
    var requestCallCount = 0
    var lastRequest: URLRequest?
    
    private let mockData: Data
    private let mockResponse: URLResponse
    private let shouldThrow: Error?
    private let delay: TimeInterval
    
    init(
        mockData: Data = Data(),
        mockResponse: URLResponse? = nil,
        shouldThrow: Error? = nil,
        delay: TimeInterval = 0
    ) {
        self.mockData = mockData
        self.mockResponse = mockResponse ?? HTTPURLResponse.mock()
        self.shouldThrow = shouldThrow
        self.delay = delay
    }
    
    func request(_ request: URLRequest) async throws -> (Data, URLResponse) {
        requestCallCount += 1
        lastRequest = request
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if let error = shouldThrow {
            throw error
        }
        
        return (mockData, mockResponse)
    }
}

/// Mock NetworkErrorLogger for testing
class MockNetworkErrorLogger: NetworkErrorLogger {
    var loggedRequests: [URLRequest] = []
    var loggedResponses: [(Data?, URLResponse?)] = []
    var loggedErrors: [Error] = []
    
    func log(request: URLRequest) {
        loggedRequests.append(request)
    }
    
    func log(responseData data: Data?, response: URLResponse?) {
        loggedResponses.append((data, response))
    }
    
    func log(error: Error) {
        loggedErrors.append(error)
    }
    
    func reset() {
        loggedRequests.removeAll()
        loggedResponses.removeAll()
        loggedErrors.removeAll()
    }
}

/// Mock DataTransferErrorResolver for testing
class MockDataTransferErrorResolver: DataTransferErrorResolver {
    var resolvedErrors: [NetworkError] = []
    private let mockResolvedError: Error?
    
    init(mockResolvedError: Error? = nil) {
        self.mockResolvedError = mockResolvedError
    }
    
    func resolve(error: NetworkError) -> Error {
        resolvedErrors.append(error)
        return mockResolvedError ?? error
    }
}

/// Mock DataTransferErrorLogger for testing
class MockDataTransferErrorLogger: DataTransferErrorLogger {
    var loggedErrors: [Error] = []
    
    func log(error: Error) {
        loggedErrors.append(error)
    }
    
    func reset() {
        loggedErrors.removeAll()
    }
}

// MARK: - Test Network Configuration

/// Test network configuration for consistent testing
struct TestNetworkConfig: NetworkConfigurable {
    let baseURL: URL
    let headers: [String: String]
    let queryParameters: [String: String]
    
    init(
        baseURL: URL = URL(string: "https://api.test.com")!,
        headers: [String: String] = ["Content-Type": "application/json"],
        queryParameters: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
    
    // Factory methods for common configurations
    static func production() -> TestNetworkConfig {
        return TestNetworkConfig(
            baseURL: URL(string: "https://api.production.com")!,
            headers: [
                "Content-Type": "application/json",
                "Authorization": "Bearer prod-token"
            ]
        )
    }
    
    static func staging() -> TestNetworkConfig {
        return TestNetworkConfig(
            baseURL: URL(string: "https://staging-api.test.com")!,
            headers: [
                "Content-Type": "application/json",
                "X-Environment": "staging"
            ]
        )
    }
    
    static func development() -> TestNetworkConfig {
        return TestNetworkConfig(
            baseURL: URL(string: "http://localhost:8080")!,
            headers: [
                "Content-Type": "application/json",
                "X-Debug": "true"
            ],
            queryParameters: ["debug": "1"]
        )
    }
}

// MARK: - HTTPURLResponse Extensions

extension HTTPURLResponse {
    static func mock(
        url: URL = URL(string: "https://api.test.com")!,
        statusCode: Int = 200
    ) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    static func success(url: URL = URL(string: "https://api.test.com")!) -> HTTPURLResponse {
        return mock(url: url, statusCode: 200)
    }
    
    static func created(url: URL = URL(string: "https://api.test.com")!) -> HTTPURLResponse {
        return mock(url: url, statusCode: 201)
    }
    
    static func badRequest(url: URL = URL(string: "https://api.test.com")!) -> HTTPURLResponse {
        return mock(url: url, statusCode: 400)
    }
    
    static func unauthorized(url: URL = URL(string: "https://api.test.com")!) -> HTTPURLResponse {
        return mock(url: url, statusCode: 401)
    }
    
    static func notFound(url: URL = URL(string: "https://api.test.com")!) -> HTTPURLResponse {
        return mock(url: url, statusCode: 404)
    }
    
    static func internalServerError(url: URL = URL(string: "https://api.test.com")!) -> HTTPURLResponse {
        return mock(url: url, statusCode: 500)
    }
}

// MARK: - JSON Test Data Helpers

struct JSONTestData {
    static func user(_ user: TestUser = TestUser.mock()) -> Data {
        return try! JSONEncoder().encode(user)
    }
    
    static func users(_ users: [TestUser] = [TestUser.mock()]) -> Data {
        return try! JSONEncoder().encode(users)
    }
    
    static func response<T: Codable>(_ response: TestResponse<T>) -> Data {
        return try! JSONEncoder().encode(response)
    }
    
    static func invalidJSON() -> Data {
        return "{ invalid json }".data(using: .utf8)!
    }
    
    static func empty() -> Data {
        return Data()
    }
    
    static func string(_ string: String) -> Data {
        return string.data(using: .utf8)!
    }
}

// MARK: - Custom Test Errors

enum TestError: Error, Equatable {
    case networkTimeout
    case authenticationFailed
    case invalidData
    case customError(String)
}

// MARK: - Assertion Helpers

struct TestAssertions {
    static func assertNetworkError(
        _ error: Error,
        expectedType: NetworkError,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let networkError = error as? NetworkError else {
            preconditionFailure("Expected NetworkError but got \(type(of: error))", file: file, line: line)
        }
        
        switch (networkError, expectedType) {
        case (.notConnected, .notConnected),
             (.cancelled, .cancelled):
            break
        case let (.error(code1, _), .error(code2, _)):
            assert(code1 == code2, "Expected status code \(code2) but got \(code1)", file: file, line: line)
        case let (.generic(error1), .generic(error2)):
            assert(
                (error1 as NSError).code == (error2 as NSError).code,
                "Expected error code \((error2 as NSError).code) but got \((error1 as NSError).code)",
                file: file,
                line: line
            )
        default:
            preconditionFailure("NetworkError types don't match", file: file, line: line)
        }
    }
    
    static func assertDataTransferError(
        _ error: Error,
        expectedType: DataTransferError,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let dataTransferError = error as? DataTransferError else {
            preconditionFailure("Expected DataTransferError but got \(type(of: error))", file: file, line: line)
        }
        
        switch (dataTransferError, expectedType) {
        case (.noResponse, .noResponse):
            break
        case (.parsing, .parsing):
            break
        case (.networkFailure, .networkFailure):
            break
        case (.resolvedNetworkFailure, .resolvedNetworkFailure):
            break
        default:
            preconditionFailure("DataTransferError types don't match", file: file, line: line)
        }
    }
}
