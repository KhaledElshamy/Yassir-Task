# Infrastructure Layer Tests

This directory contains comprehensive tests for the infrastructure layer of the Yassir Task application. The tests are designed to be maintainable, scalable, and follow clean code principles.

## Test Structure

### Core Test Files

- **NetworkServiceTests.swift** - Tests for the NetworkService layer including error handling, logging, and HTTP response scenarios
- **DataTransferServiceTests.swift** - Tests for the DataTransferService including JSON/raw data decoding, error resolution, and response handling
- **EndpointTests.swift** - Tests for URL generation, request building, query parameters, and body encoding
- **NetworkConfigTests.swift** - Tests for network configuration objects and their various initialization scenarios
- **InfrastructureTestHelpers.swift** - Reusable mocks, test models, and utility functions for all infrastructure tests
- **InfrastructureIntegrationTests.swift** - End-to-end integration tests that verify the complete request flow

## Test Coverage

### NetworkService Tests ✅
- Successful HTTP requests with various response codes
- Error handling for 4xx/5xx status codes
- Network connectivity errors (no connection, cancelled, timeout)
- URL generation errors
- Request/response/error logging verification
- NetworkError extension methods

### DataTransferService Tests ✅
- JSON response decoding with success and failure scenarios
- Void response handling for actions that don't return data
- Raw data response handling
- Error propagation and resolution
- Custom error resolver testing
- Parsing error handling for invalid JSON
- Logger integration testing

### Endpoint Tests ✅
- URL generation with relative and absolute paths
- Query parameter handling (both dictionary and encodable)
- HTTP method configuration (GET, POST, PUT, DELETE, etc.)
- Header merging between config and endpoint
- Body parameter encoding (JSON and ASCII)
- Request generation with various configurations

### NetworkConfig Tests ✅
- ApiDataNetworkConfig initialization with various parameter combinations
- Protocol conformance verification
- Immutability after initialization
- Different environment configurations (production, staging, development)
- Edge cases with empty strings and special characters

### Integration Tests ✅
- Complete request flow from DataTransferService to NetworkService
- Error propagation through the entire stack
- Complex endpoint scenarios with multiple parameters
- Different configuration testing
- Concurrent request handling
- Memory management verification (no retain cycles)

## Test Helpers and Mocks

### Mock Objects
- **MockNetworkService** - Simulates NetworkService with configurable responses and errors
- **MockNetworkSessionManager** - Simulates URLSession behavior
- **MockNetworkErrorLogger** - Captures logged requests, responses, and errors
- **MockDataTransferErrorResolver** - Simulates error resolution with custom logic
- **MockDataTransferErrorLogger** - Captures logged data transfer errors

### Test Models
- **TestUser** - Sample model for JSON testing
- **TestResponse<T>** - Generic response wrapper for API responses
- **TestQueryParameters** - Model for query parameter testing
- **TestBodyParameters** - Model for request body testing

### Test Endpoints
- **TestEndpoint<T>** - Generic endpoint for various response types
- **TestVoidEndpoint** - Endpoint for actions that don't return data
- **TestInvalidEndpoint** - Endpoint that generates URL errors

### Utilities
- **TestNetworkConfig** - Pre-configured network configs for different environments
- **HTTPURLResponse** extensions - Factory methods for different response types
- **JSONTestData** - Helper for generating test JSON data
- **TestAssertions** - Custom assertion helpers for network and data transfer errors

## Test Principles

### Clean Code
- Each test has a clear Given-When-Then structure
- Descriptive test names that explain the scenario being tested
- Well-organized with proper commenting and documentation
- Separation of concerns between unit and integration tests

### Maintainability
- Reusable mock objects and test helpers
- Factory methods for common test scenarios
- Consistent naming conventions
- Modular test organization

### Scalability
- Generic test helpers that can be extended
- Parameterized tests where appropriate
- Clear separation between test concerns
- Easy to add new test scenarios

## Running Tests

To run all infrastructure tests:
1. Open the project in Xcode
2. Navigate to the Test Navigator (Cmd+6)
3. Expand "Yassir TaskTests" → "Infrastructure"
4. Click the play button next to any test file or individual test

To run tests from command line:
```bash
xcodebuild test -scheme "Yassir Task" -destination "platform=iOS Simulator,name=iPhone 15"
```

## Test Scenarios Covered

### Happy Path Scenarios
- Successful API requests with JSON responses
- Successful API requests with raw data responses
- Successful API requests with void responses
- Complex requests with query and body parameters
- Concurrent requests

### Error Scenarios
- Network connectivity errors
- HTTP error responses (4xx, 5xx)
- JSON parsing errors
- URL generation errors
- Timeout errors
- Cancelled requests

### Edge Cases
- Empty responses
- Invalid JSON data
- Special characters in parameters
- Different URL schemes
- Large payloads (covered in integration tests)

## Best Practices Demonstrated

1. **Dependency Injection** - All components use dependency injection for testability
2. **Protocol-Based Design** - Tests verify protocol conformance and behavior
3. **Error Handling** - Comprehensive error testing at all layers
4. **Mocking Strategy** - Proper mocking without over-mocking
5. **Test Organization** - Clear separation of concerns and test categories
6. **Documentation** - Well-documented test cases and helpers
7. **Maintainability** - Easy to extend and modify tests

## Future Enhancements

Areas where tests can be extended:
- Performance testing for large payloads
- Security testing for sensitive data handling
- Accessibility testing for network error messages
- Localization testing for error messages
- Background task testing for network requests
- Network condition simulation (slow, unreliable connections)

This test suite provides a solid foundation for ensuring the reliability and maintainability of the infrastructure layer while following industry best practices for iOS testing.
