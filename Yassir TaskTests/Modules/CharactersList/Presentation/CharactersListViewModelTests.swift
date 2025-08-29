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
    
    // MARK: - Loading State Tests
    
    func testLoadingStateFullScreen() async {
        // Given
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.loadCharacters()
        
        // Then
        XCTAssertEqual(viewModel.loading, .fullScreen)
        
        // Wait for loading to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNil(viewModel.loading)
    }
    
    func testLoadingStateNextPage() async {
        // Given
        let firstResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse(hasNextPage: true)
        let secondResponse = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        
        mockUseCase.setSuccessResponse(firstResponse)
        viewModel.loadCharacters()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When
        mockUseCase.setSuccessResponse(secondResponse)
        viewModel.loadNextPage()
        
        // Then
        XCTAssertEqual(viewModel.loading, .nextPage)
        
        // Wait for loading to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNil(viewModel.loading)
    }
    
    func testLoadingStateRefreshing() async {
        // Given
        let response = CharactersListViewModelTestDataFactory.createCharactersListResponse()
        mockUseCase.setSuccessResponse(response)
        
        // When
        viewModel.refreshData()
        
        // Then
        XCTAssertEqual(viewModel.loading, .refreshing)
        
        // Wait for loading to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertNil(viewModel.loading)
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
}
