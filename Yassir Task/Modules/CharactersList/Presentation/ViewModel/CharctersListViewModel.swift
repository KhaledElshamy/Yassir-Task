//
//  CharactersListViewModel.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import Combine

// MARK: - Filter Option

struct FilterOption {
    let title: String
    let status: CharacterResponse.Status?
    
    static let all = FilterOption(title: "All", status: nil)
    static let alive = FilterOption(title: "Alive", status: .alive)
    static let dead = FilterOption(title: "Dead", status: .dead)
    static let unknown = FilterOption(title: "Unknown", status: .unknown)
    
    static let allOptions: [FilterOption] = [.all, .alive, .dead, .unknown]
}

// MARK: - View Model Actions

struct CharacterListViewModelActions {
    let showCharacterDetails: (CharacterResponse) -> Void
    let showError: (String) -> Void
}

// MARK: - View Model Protocols

protocol CharactersViewModelInput {
    func loadCharacters()
    func loadNextPage()
    func refreshData()
    func retry()
    func filterByStatus(_ status: CharacterResponse.Status?)
//    func selectFilter(at index: Int)
    func selectCharacter(_ character: CharacterResponse)
}

protocol CharactersViewModelOutput {
    var characters: [CharacterResponse] { get }
    var loading: CharactersListViewModelLoading? { get }
    var error: String? { get }
    var isEmpty: Bool { get }
    var hasMorePages: Bool { get }
    var canLoadMore: Bool { get }
    var currentPage: Int { get }
    var selectedStatus: CharacterResponse.Status? { get }
    var filterOptions: [FilterOption] { get }
    var selectedFilterIndex: Int { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var refreshTitle: String { get }
    var loadMoreTitle: String { get }
}

enum CharactersListViewModelLoading {
    case fullScreen
    case nextPage
    case refreshing
}

typealias CharactersViewModelProtocol = CharactersViewModelInput & CharactersViewModelOutput

// MARK: - View Model Implementation

final class CharactersListViewModel: CharactersViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let charactersUseCase: CharactersUseCaseProtocol
    private let actions: CharacterListViewModelActions
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    private var currentPageNumber = 1
    private var allCharacters: [CharacterResponse] = []
    private var filteredCharacters: [CharacterResponse] = []
    private var currentStatusFilter: CharacterResponse.Status?
    private var currentFilterIndex = 0
    private var _isLoading = false
    private var hasMoreData = true
    private var lastError: String?
    
    // MARK: - Published Properties
    
    @Published private(set) var characters: [CharacterResponse] = []
    @Published private(set) var loading: CharactersListViewModelLoading?
    @Published private(set) var error: String?
    
    // MARK: - Computed Properties
    
    var isEmpty: Bool {
        return characters.isEmpty
    }
    
    var hasMorePages: Bool {
        return hasMoreData && !_isLoading
    }
    
    var canLoadMore: Bool {
        return hasMorePages && loading != .fullScreen
    }
    
    var currentPage: Int {
        return currentPageNumber
    }
    
    var selectedStatus: CharacterResponse.Status? {
        return currentStatusFilter
    }
    
    var filterOptions: [FilterOption] {
        return FilterOption.allOptions
    }
    
    var selectedFilterIndex: Int {
        return currentFilterIndex
    }
    
    var emptyDataTitle: String {
        if let status = currentStatusFilter {
            return "No \(status.rawValue) characters found"
        }
        return "No characters found"
    }
    
    var errorTitle: String {
        return "Error Loading Characters"
    }
    
    var refreshTitle: String {
        return "Pull to refresh"
    }
    
    var loadMoreTitle: String {
        return "Load More Characters"
    }
    
    var isLoading: Bool {
        return _isLoading
    }
    
    // MARK: - Initialization
    
    init(
        charactersUseCase: CharactersUseCaseProtocol,
        actions: CharacterListViewModelActions
    ) {
        self.charactersUseCase = charactersUseCase
        self.actions = actions
    }
    
    // MARK: - CharactersViewModelInput
    
    func loadCharacters() {
        guard !_isLoading else { return }
        
        resetPagination()
        loadCharactersPage(page: currentPageNumber, status: currentStatusFilter?.rawValue)
    }
    
    func loadNextPage() {
        guard canLoadMore else { return }
        
        currentPageNumber += 1
        loadCharactersPage(page: currentPageNumber, status: currentStatusFilter?.rawValue)
    }
    
    func refreshData() {
        guard !_isLoading else { return }
        
        resetPagination()
        loadCharactersPage(page: currentPageNumber, status: currentStatusFilter?.rawValue, isRefresh: true)
    }
    
    func retry() {
        clearError()
        loadCharacters()
    }
    
    func filterByStatus(_ status: CharacterResponse.Status?) {
        currentStatusFilter = status
        applyFilter()
        
        resetPagination()
        loadCharactersPage(page: currentPageNumber, status: status?.rawValue)
    }
    
//    func selectFilter(at index: Int) {
//        guard index >= 0 && index < FilterOption.allOptions.count else { return }
//        
//        currentFilterIndex = index
//        let selectedOption = FilterOption.allOptions[index]
//        filterByStatus(selectedOption.status)
//    }
    
    func selectCharacter(_ character: CharacterResponse) {
        actions.showCharacterDetails(character)
    }
    
    // MARK: - Private Methods
    
    private func loadCharactersPage(page: Int, status: String?, isRefresh: Bool = false) {
        guard !_isLoading else { return }
        
        _isLoading = true
        loading = isRefresh ? .refreshing : (page == 1 ? .fullScreen : .nextPage)
        clearError()
        
        Task { @MainActor in
            do {
                let response = try await charactersUseCase.fetchCharacters(
                    page: page,
                    status: status ?? ""
                )
                
                handleSuccessfulResponse(response, isRefresh: isRefresh)
                
            } catch {
                handleError(error)
            }
        }
    }
    
    @MainActor
    private func handleSuccessfulResponse(_ response: CharactersListResponse, isRefresh: Bool) {
        _isLoading = false
        loading = nil
        
        if isRefresh || currentPageNumber == 1 {
            allCharacters = response.results
        } else {
            allCharacters.append(contentsOf: response.results)
        }
        
        hasMoreData = response.info.hasNextPage
        applyFilter()
    }
    
    @MainActor
    private func handleError(_ error: Error) {
        _isLoading = false
        loading = nil
        
        let errorMessage = error.localizedDescription
        lastError = errorMessage
        self.error = errorMessage
        
        // If this is the first page load, show error
        if currentPageNumber == 1 {
            actions.showError(errorMessage)
        }
    }
    
    private func applyFilter() {
        if let status = currentStatusFilter {
            filteredCharacters = allCharacters.filter { $0.status == status }
        } else {
            filteredCharacters = allCharacters
        }
        
        characters = filteredCharacters
    }
    
    private func resetPagination() {
        currentPageNumber = 1
        allCharacters.removeAll()
        filteredCharacters.removeAll()
        hasMoreData = true
    }
    
    private func clearError() {
        error = nil
        lastError = nil
    }
}

// MARK: - CharacterResponse.Status Extension

extension CharacterResponse.Status {
    var rawValue: String {
        switch self {
        case .alive:
            return "Alive"
        case .dead:
            return "Dead"
        case .unknown:
            return "unknown"
        }
    }
    
    static var allCases: [CharacterResponse.Status] {
        return [.alive, .dead, .unknown]
    }
}
