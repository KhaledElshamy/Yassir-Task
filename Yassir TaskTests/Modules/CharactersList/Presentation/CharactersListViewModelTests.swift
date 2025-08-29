//
//  CharactersListViewModelTests.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import XCTest
import Combine
@testable import Yassir_Task

// MARK: - Characters List View Model Tests

final class CharactersListViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    private var viewModel: CharactersListViewModel!
    private var mockUseCase: MockCharactersUseCase!
    private var mockActions: MockCharacterListViewModelActions!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockCharactersUseCase()
        mockActions = MockCharacterListViewModelActions()
        cancellables = Set<AnyCancellable>()
        
        viewModel = CharactersListViewModel(
            charactersUseCase: mockUseCase,
            actions: mockActions.actions
        )
    }
    
    override func tearDown() {
        cancellables.removeAll()
        viewModel = nil
        mockUseCase = nil
        mockActions = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given & When
        let viewModel = CharactersListViewModel(
            charactersUseCase: mockUseCase,
            actions: mockActions.actions
        )
        
        // Then
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertNil(viewModel.loading)
        XCTAssertNil(viewModel.error)
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertTrue(viewModel.canLoadMore)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertNil(viewModel.selectedStatus)
        XCTAssertEqual(viewModel.emptyDataTitle, "No characters found")
        XCTAssertEqual(viewModel.errorTitle, "Error Loading Characters")
        XCTAssertEqual(viewModel.refreshTitle, "Pull to refresh")
        XCTAssertEqual(viewModel.loadMoreTitle, "Load More Characters")
    }
    
    // MARK: - Load Characters Tests
    
    func testLoadCharactersSuccess() async {
        // Given
        let characters = CharactersListViewModelTestDataFactory.createCharactersList(count: 2)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: characters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        
        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1)
        XCTAssertEqual(mockUseCase.lastFetchCharactersPage, 1)
        XCTAssertEqual(mockUseCase.lastFetchCharactersStatus, "")
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertNil(viewModel.loading)
        XCTAssertNil(viewModel.error)
    }
    
    func testLoadCharactersFailure() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        mockUseCase.setFailureResponse(error)
        
        // When
        viewModel.loadCharacters()
        
        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1)
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(mockActions.showErrorCallCount, 1)
        XCTAssertEqual(mockActions.lastShowErrorMessage, error.localizedDescription)
    }
    
    func testLoadCharactersWhenAlreadyLoading() async {
        // Given
        mockUseCase.setSuccessResponse(CharactersListViewModelTestDataFactory.createCharactersListResponse())
        
        // When
        viewModel.loadCharacters()
        viewModel.loadCharacters() // Second call while loading
        
        // Wait for first call to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1) // Only first call should execute
    }
    
    // MARK: - Load Next Page Tests
    
    func testLoadNextPageSuccess() async {
        // Given
        let firstPageCharacters = CharactersListViewModelTestDataFactory.createCharactersList(count: 2)
        let secondPageCharacters = CharactersListViewModelTestDataFactory.createCharactersList(count: 2)
        
        let firstResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: firstPageCharacters,
            hasNextPage: true
        )
        let secondResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: secondPageCharacters,
            hasNextPage: false
        )
        
        mockUseCase.setSuccessResponse(firstResponse)
        viewModel.loadCharacters()
        
        // Wait for first page to load
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // When
        mockUseCase.setSuccessResponse(secondResponse)
        viewModel.loadNextPage()
        
        // Wait for second page to load
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 2)
        XCTAssertEqual(mockUseCase.lastFetchCharactersPage, 2)
        XCTAssertEqual(viewModel.characters.count, 4)
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.hasMorePages)
    }
    
    func testLoadNextPageWhenCannotLoadMore() async {
        // Given
        mockUseCase.setSuccessResponse(CharactersListViewModelTestDataFactory.createEmptyCharactersListResponse())
        viewModel.loadCharacters()
        
        // Wait for initial load to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // When
        viewModel.loadNextPage()
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1) // Should not load next page
    }
    
    // MARK: - Refresh Data Tests
    
    func testRefreshDataSuccess() async {
        // Given
        let characters = CharactersListViewModelTestDataFactory.createCharactersList(count: 3)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: characters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.refreshData()
        
        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1)
        XCTAssertEqual(mockUseCase.lastFetchCharactersPage, 1)
        XCTAssertEqual(viewModel.characters.count, 3)
        XCTAssertNil(viewModel.loading)
    }
    
    func testRefreshDataWhenAlreadyLoading() async {
        // Given
        mockUseCase.setSuccessResponse(CharactersListViewModelTestDataFactory.createCharactersListResponse())
        
        // When
        viewModel.refreshData()
        viewModel.refreshData() // Second call while loading
        
        // Wait for first call to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1) // Only first call should execute
    }
    
    // MARK: - Retry Tests
    
    func testRetry() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        mockUseCase.setFailureResponse(error)
        viewModel.loadCharacters()
        
        // Wait for error to be set
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        mockUseCase.setSuccessResponse(CharactersListViewModelTestDataFactory.createCharactersListResponse())
        viewModel.retry()
        
        // Wait for retry to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 2)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Filter Tests
    
    func testFilterByStatusAlive() async {
        // Given
        let characters = [
            CharactersListViewModelTestDataFactory.createCharacter(name: "Alive Character", status: .alive),
            CharactersListViewModelTestDataFactory.createCharacter(name: "Dead Character", status: .dead),
            CharactersListViewModelTestDataFactory.createCharacter(name: "Unknown Character", status: .unknown)
        ]
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: characters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.filterByStatus(.alive)
        
        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1)
        XCTAssertEqual(mockUseCase.lastFetchCharactersStatus, "Alive")
        XCTAssertEqual(viewModel.selectedStatus, .alive)
    }
    
    func testFilterByStatusDead() async {
        // Given
        let characters = CharactersListViewModelTestDataFactory.createCharactersList()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: characters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.filterByStatus(.dead)
        
        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.lastFetchCharactersStatus, "Dead")
        XCTAssertEqual(viewModel.selectedStatus, .dead)
    }
    
    func testFilterByStatusUnknown() async {
        // Given
        let characters = CharactersListViewModelTestDataFactory.createCharactersList()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: characters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.filterByStatus(.unknown)
        
        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.lastFetchCharactersStatus, "unknown")
        XCTAssertEqual(viewModel.selectedStatus, .unknown)
    }
    
    func testFilterByStatusAll() async {
        // Given
        let characters = CharactersListViewModelTestDataFactory.createCharactersList()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: characters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.filterByStatus(nil)
        
        // Wait for async operation to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(mockUseCase.lastFetchCharactersStatus, "")
        XCTAssertNil(viewModel.selectedStatus)
    }
    
    func testFilterAppliesToExistingCharacters() async {
        // Given
        let characters = [
            CharactersListViewModelTestDataFactory.createCharacter(name: "Alive Character", status: .alive),
            CharactersListViewModelTestDataFactory.createCharacter(name: "Dead Character", status: .dead),
            CharactersListViewModelTestDataFactory.createCharacter(name: "Another Alive", status: .alive)
        ]
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: characters)
        mockUseCase.setSuccessResponse(response)
        
        // Load characters first
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        viewModel.filterByStatus(.alive)
        
        // Wait for filter to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertTrue(viewModel.characters.allSatisfy { $0.status == .alive })
    }
    
    // MARK: - Select Character Tests
    
    func testSelectCharacter() {
        // Given
        let character = CharactersListViewModelTestDataFactory.createCharacter()
        
        // When
        viewModel.selectCharacter(character)
        
        // Then
        XCTAssertEqual(mockActions.showCharacterDetailsCallCount, 1)
        XCTAssertEqual(mockActions.lastShowCharacterDetailsCharacter?.id, character.id)
    }
    
    
    // MARK: - Computed Properties Tests
    
    func testIsEmpty() async {
        // Given
        XCTAssertTrue(viewModel.isEmpty)
        
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isEmpty)
    }
    
    func testHasMorePages() async {
        // Given
        XCTAssertTrue(viewModel.hasMorePages)
        
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(hasNextPage: false)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertFalse(viewModel.hasMorePages)
    }
    
    func testCanLoadMore() async {
        // Given
        XCTAssertTrue(viewModel.canLoadMore)
        
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(hasNextPage: false)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertFalse(viewModel.canLoadMore)
    }
    
    func testEmptyDataTitle() {
        // Given & When
        let defaultTitle = viewModel.emptyDataTitle
        viewModel.filterByStatus(.alive)
        let aliveTitle = viewModel.emptyDataTitle
        viewModel.filterByStatus(.dead)
        let deadTitle = viewModel.emptyDataTitle
        viewModel.filterByStatus(.unknown)
        let unknownTitle = viewModel.emptyDataTitle
        
        // Then
        XCTAssertEqual(defaultTitle, "No characters found")
        XCTAssertEqual(aliveTitle, "No Alive characters found")
        XCTAssertEqual(deadTitle, "No Dead characters found")
        XCTAssertEqual(unknownTitle, "No unknown characters found")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandlingFirstPage() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        mockUseCase.setFailureResponse(error)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(mockActions.showErrorCallCount, 1)
    }
    
    func testErrorHandlingSubsequentPage() async {
        // Given
        let firstResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse(hasNextPage: true)
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        
        mockUseCase.setSuccessResponse(firstResponse)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        mockUseCase.setFailureResponse(error)
        viewModel.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(mockActions.showErrorCallCount, 0) // Should not show error for subsequent pages
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() {
        // Given
        weak var weakViewModel = viewModel
        
        // When
        viewModel = nil
        
        // Then
        XCTAssertNil(weakViewModel)
    }
    
    // MARK: - Filter Options Tests
    
    func testFilterOptions() {
        // Given & When
        let filterOptions = viewModel.filterOptions
        
        // Then
        XCTAssertEqual(filterOptions.count, 4)
        XCTAssertEqual(filterOptions[0].title, "All")
        XCTAssertNil(filterOptions[0].status)
        XCTAssertEqual(filterOptions[1].title, "Alive")
        XCTAssertEqual(filterOptions[1].status, .alive)
        XCTAssertEqual(filterOptions[2].title, "Dead")
        XCTAssertEqual(filterOptions[2].status, .dead)
        XCTAssertEqual(filterOptions[3].title, "Unknown")
        XCTAssertEqual(filterOptions[3].status, .unknown)
    }
    
    func testSelectedFilterIndex() {
        // Given & When
        let initialIndex = viewModel.selectedFilterIndex
        
        // Then
        XCTAssertEqual(initialIndex, 0) // Should default to "All"
    }
    
    // MARK: - Edge Cases Tests
    
    func testLoadCharactersWithEmptyResponse() async {
        // Given
        let emptyResponse = CharactersListViewModelTestDataFactory.createEmptyCharactersListResponse()
        mockUseCase.setSuccessResponse(emptyResponse)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertFalse(viewModel.canLoadMore)
    }
    
    func testLoadCharactersWithLargeDataset() async {
        // Given
        let largeCharacterList = CharactersListViewModelTestDataFactory.createCharactersList(count: 100)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: largeCharacterList,
            hasNextPage: true
        )
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 100)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertTrue(viewModel.canLoadMore)
    }
    
    func testConcurrentLoadOperations() async {
        // Given
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        
        // When - Multiple concurrent operations
        viewModel.loadCharacters()
        viewModel.refreshData()
        viewModel.loadNextPage()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - Should only execute the first operation
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1)
    }
    
    func testFilterWithEmptyResults() async {
        // Given
        let emptyResponse = CharactersListViewModelTestDataFactory.createEmptyCharactersListResponse()
        mockUseCase.setSuccessResponse(emptyResponse)
        
        // When
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertEqual(viewModel.emptyDataTitle, "No Alive characters found")
    }
    
    func testMultipleFilterChanges() async {
        // Given
        let characters = [
            CharactersListViewModelTestDataFactory.createCharacter(name: "Alive 1", status: .alive),
            CharactersListViewModelTestDataFactory.createCharacter(name: "Dead 1", status: .dead),
            CharactersListViewModelTestDataFactory.createCharacter(name: "Alive 2", status: .alive),
            CharactersListViewModelTestDataFactory.createCharacter(name: "Unknown 1", status: .unknown)
        ]
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: characters)
        mockUseCase.setSuccessResponse(response)
        
        // Load initial data
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Apply multiple filters
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.characters.count, 2)
        
        viewModel.filterByStatus(.dead)
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.characters.count, 1)
        
        viewModel.filterByStatus(nil) // All
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(viewModel.characters.count, 4)
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 4) // Initial + 3 filters
    }
    
    // MARK: - State Transition Tests
    
    func testStateTransitionFromLoadingToSuccess() async {
        // Given
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        
        // Then - Check loading state
        XCTAssertEqual(viewModel.loading, .fullScreen)
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - Check success state
        XCTAssertNil(viewModel.loading)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func testStateTransitionFromLoadingToError() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        mockUseCase.setFailureResponse(error)
        
        // When
        viewModel.loadCharacters()
        
        // Then - Check loading state
        XCTAssertEqual(viewModel.loading, .fullScreen)
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - Check error state
        XCTAssertNil(viewModel.loading)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
    }
    
    func testStateTransitionFromErrorToSuccess() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        mockUseCase.setFailureResponse(error)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Retry with success
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        viewModel.retry()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.isEmpty)
    }
    
    // MARK: - Pagination Edge Cases
    
    func testPaginationWithSinglePage() async {
        // Given
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(hasNextPage: false)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertFalse(viewModel.canLoadMore)
        
        // Try to load next page
        viewModel.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Should not make additional calls
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 1)
    }
    
    func testPaginationResetOnFilter() async {
        // Given
        let firstResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse(hasNextPage: true)
        let secondResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse(hasNextPage: true)
        
        mockUseCase.setSuccessResponse(firstResponse)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        mockUseCase.setSuccessResponse(secondResponse)
        viewModel.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Apply filter
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - Pagination should be reset
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
    }
    
    // MARK: - Error Recovery Tests
    
    func testErrorRecoveryAfterNetworkFailure() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        mockUseCase.setFailureResponse(error)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Network recovers
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        viewModel.retry()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 2)
    }
    
    func testErrorClearingOnNewRequest() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        mockUseCase.setFailureResponse(error)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Start new request
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        viewModel.loadCharacters()
        
        // Then - Error should be cleared immediately
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWithLargeDataset() async {
        // Given
        let largeCharacterList = CharactersListViewModelTestDataFactory.createCharactersList(count: 1000)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: largeCharacterList,
            hasNextPage: false
        )
        mockUseCase.setSuccessResponse(response)
        
        // When & Then
        measure {
            viewModel.loadCharacters()
        }
    }
    
    func testFilterPerformanceWithLargeDataset() async {
        // Given
        let largeCharacterList = CharactersListViewModelTestDataFactory.createCharactersList(count: 1000)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: largeCharacterList,
            hasNextPage: false
        )
        mockUseCase.setSuccessResponse(response)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When & Then
        measure {
            viewModel.filterByStatus(.alive)
        }
    }
    
    // MARK: - Integration Scenarios
    
    func testCompleteUserFlow() async {
        // Given
        let firstPageCharacters = CharactersListViewModelTestDataFactory.createCharactersList(count: 20)
        let secondPageCharacters = CharactersListViewModelTestDataFactory.createCharactersList(count: 20)
        
        let firstResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: firstPageCharacters,
            hasNextPage: true
        )
        let secondResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: secondPageCharacters,
            hasNextPage: false
        )
        
        // When - Complete user flow
        mockUseCase.setSuccessResponse(firstResponse)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Load next page
        mockUseCase.setSuccessResponse(secondResponse)
        viewModel.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Apply filter
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Refresh data
        mockUseCase.setSuccessResponse(firstResponse)
        viewModel.refreshData()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Select character
        let character = firstPageCharacters.first!
        viewModel.selectCharacter(character)
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 4)
        XCTAssertEqual(mockActions.showCharacterDetailsCallCount, 1)
        XCTAssertEqual(mockActions.lastShowCharacterDetailsCharacter?.id, character.id)
    }
    
    func testErrorHandlingInUserFlow() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        
        // When - Start with error
        mockUseCase.setFailureResponse(error)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Retry with success
        mockUseCase.setSuccessResponse(response)
        viewModel.retry()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Apply filter
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 3)
        XCTAssertEqual(mockActions.showErrorCallCount, 1)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Boundary Tests
    
    func testBoundaryConditions() async {
        // Given
        let singleCharacter = [CharactersListViewModelTestDataFactory.createCharacter()]
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: singleCharacter,
            hasNextPage: false
        )
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertFalse(viewModel.canLoadMore)
    }
    
    func testStatusRawValues() {
        // Given & When & Then
        XCTAssertEqual(CharacterResponse.Status.alive.rawValue, "Alive")
        XCTAssertEqual(CharacterResponse.Status.dead.rawValue, "Dead")
        XCTAssertEqual(CharacterResponse.Status.unknown.rawValue, "unknown")
    }
    
    func testStatusAllCases() {
        // Given & When
        let allCases = CharacterResponse.Status.allCases
        
        // Then
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.alive))
        XCTAssertTrue(allCases.contains(.dead))
        XCTAssertTrue(allCases.contains(.unknown))
    }
    
    // MARK: - Enhanced Edge Cases Tests
    
    func testLoadCharactersWithSpecialCharacters() async {
        // Given
        let specialCharacter = CharactersListViewModelTestDataFactory.createCharacterWithSpecialCharacters()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: [specialCharacter])
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertEqual(viewModel.characters.first?.name, "Character with Special Chars: !@#$%^&*()")
    }
    
    func testLoadCharactersWithEmptyFields() async {
        // Given
        let emptyFieldCharacter = CharactersListViewModelTestDataFactory.createCharacterWithEmptyFields()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: [emptyFieldCharacter])
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertEqual(viewModel.characters.first?.name, "")
        XCTAssertEqual(viewModel.characters.first?.species, "")
    }
    
    func testLoadCharactersWithLongName() async {
        // Given
        let longNameCharacter = CharactersListViewModelTestDataFactory.createCharacterWithLongName()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: [longNameCharacter])
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 1)
        XCTAssertTrue(viewModel.characters.first?.name.count ?? 0 > 50)
    }
    
    // MARK: - Specialized Filter Tests
    
    func testFilterWithAliveCharactersOnly() async {
        // Given
        let aliveCharacters = CharactersListViewModelTestDataFactory.createAliveCharactersList(count: 10)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: aliveCharacters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 10)
        XCTAssertTrue(viewModel.characters.allSatisfy { $0.status == .alive })
    }
    
    func testFilterWithDeadCharactersOnly() async {
        // Given
        let deadCharacters = CharactersListViewModelTestDataFactory.createDeadCharactersList(count: 8)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: deadCharacters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.filterByStatus(.dead)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 8)
        XCTAssertTrue(viewModel.characters.allSatisfy { $0.status == .dead })
    }
    
    func testFilterWithUnknownCharactersOnly() async {
        // Given
        let unknownCharacters = CharactersListViewModelTestDataFactory.createUnknownCharactersList(count: 6)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: unknownCharacters)
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.filterByStatus(.unknown)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 6)
        XCTAssertTrue(viewModel.characters.allSatisfy { $0.status == .unknown })
    }
    
    func testFilterWithMixedStatusCharacters() async {
        // Given
        let mixedCharacters = CharactersListViewModelTestDataFactory.createMixedStatusCharactersList()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: mixedCharacters)
        mockUseCase.setSuccessResponse(response)
        
        // Load all characters first
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Filter by alive
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertTrue(viewModel.characters.allSatisfy { $0.status == .alive })
    }
    
    // MARK: - Error Type Tests
    
    func testTimeoutErrorHandling() async {
        // Given
        let timeoutError = CharactersListViewModelTestDataFactory.createTimeoutError()
        mockUseCase.setFailureResponse(timeoutError)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.error, "Request timed out")
        XCTAssertEqual(mockActions.showErrorCallCount, 1)
    }
    
    func testServerErrorHandling() async {
        // Given
        let serverError = CharactersListViewModelTestDataFactory.createServerError()
        mockUseCase.setFailureResponse(serverError)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.error, "Internal server error")
        XCTAssertEqual(mockActions.showErrorCallCount, 1)
    }
    
    func testGenericErrorHandling() async {
        // Given
        let genericError = CharactersListViewModelTestDataFactory.createGenericError()
        mockUseCase.setFailureResponse(genericError)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(viewModel.error, "Test error message")
        XCTAssertEqual(mockActions.showErrorCallCount, 1)
    }
    
    // MARK: - Pagination Advanced Tests
    
    func testMultiPagePagination() async {
        // Given
        let firstPageResponse = CharactersListViewModelTestDataFactory.createMultiPageResponse(page: 1, totalPages: 3)
        let secondPageResponse = CharactersListViewModelTestDataFactory.createMultiPageResponse(page: 2, totalPages: 3)
        let thirdPageResponse = CharactersListViewModelTestDataFactory.createMultiPageResponse(page: 3, totalPages: 3)
        
        // Load first page
        mockUseCase.setSuccessResponse(firstPageResponse)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Load second page
        mockUseCase.setSuccessResponse(secondPageResponse)
        viewModel.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Load third page
        mockUseCase.setSuccessResponse(thirdPageResponse)
        viewModel.loadNextPage()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 3)
        XCTAssertEqual(viewModel.currentPage, 3)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.characters.count, 60) // 20 per page * 3 pages
    }
    
    func testSinglePageResponse() async {
        // Given
        let singlePageResponse = CharactersListViewModelTestDataFactory.createSinglePageResponse()
        mockUseCase.setSuccessResponse(singlePageResponse)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 20)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertFalse(viewModel.canLoadMore)
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    // MARK: - Performance Tests with Large Datasets
    
    func testPerformanceWithVeryLargeDataset() async {
        // Given
        let veryLargeCharacterList = CharactersListViewModelTestDataFactory.createPerformanceTestCharacters(count: 10000)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: veryLargeCharacterList,
            hasNextPage: false
        )
        mockUseCase.setSuccessResponse(response)
        
        // When & Then
        measure {
            viewModel.loadCharacters()
        }
    }
    
    func testFilterPerformanceWithVeryLargeDataset() async {
        // Given
        let veryLargeCharacterList = CharactersListViewModelTestDataFactory.createPerformanceTestCharacters(count: 10000)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: veryLargeCharacterList,
            hasNextPage: false
        )
        mockUseCase.setSuccessResponse(response)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When & Then
        measure {
            viewModel.filterByStatus(.alive)
        }
    }
    
    // MARK: - Complex Integration Scenarios
    
    func testComplexUserFlowWithErrorsAndRecovery() async {
        // Given
        let error = CharactersListViewModelTestDataFactory.createNetworkError()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        
        // When - Start with error
        mockUseCase.setFailureResponse(error)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Retry with success
        mockUseCase.setSuccessResponse(response)
        viewModel.retry()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Apply multiple filters
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        viewModel.filterByStatus(.dead)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        viewModel.filterByStatus(nil) // All
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Refresh data
        mockUseCase.setSuccessResponse(response)
        viewModel.refreshData()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Select character
        let character = response.results.first!
        viewModel.selectCharacter(character)
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 6) // Initial error + retry + 3 filters + refresh
        XCTAssertEqual(mockActions.showErrorCallCount, 1)
        XCTAssertEqual(mockActions.showCharacterDetailsCallCount, 1)
        XCTAssertNil(viewModel.error)
    }
    
    func testRapidFilterChanges() async {
        // Given
        let mixedCharacters = CharactersListViewModelTestDataFactory.createMixedStatusCharactersList()
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(characters: mixedCharacters)
        mockUseCase.setSuccessResponse(response)
        
        // When - Rapid filter changes
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 50_000_000) // Shorter wait
        
        viewModel.filterByStatus(.dead)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        viewModel.filterByStatus(.unknown)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        viewModel.filterByStatus(nil)
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Then
        XCTAssertEqual(mockUseCase.fetchCharactersCallCount, 4)
        XCTAssertNil(viewModel.selectedStatus)
    }
    
    // MARK: - Memory and Resource Tests
    
    func testMemoryUsageWithLargeDataset() async {
        // Given
        let largeCharacterList = CharactersListViewModelTestDataFactory.createLargeCharactersList(count: 5000)
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse(
            characters: largeCharacterList,
            hasNextPage: false
        )
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 5000)
        XCTAssertFalse(viewModel.isEmpty)
        
        // Test memory cleanup
        viewModel = nil
        XCTAssertNil(viewModel)
    }
    
    // MARK: - State Consistency Tests
    
    func testStateConsistencyAfterMultipleOperations() async {
        // Given
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        
        // When - Multiple operations
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        viewModel.filterByStatus(.alive)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        viewModel.refreshData()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - State should be consistent
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.loading)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
    }
}
