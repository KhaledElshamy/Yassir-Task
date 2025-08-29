//
//  MockCharacterListViewModelActions.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import Foundation
@testable import Yassir_Task

// MARK: - Mock Character List View Model Actions

final class MockCharacterListViewModelActions {
    
    // MARK: - Properties
    
    var showCharacterDetailsCallCount = 0
    var lastShowCharacterDetailsCharacter: CharacterResponse?
    
    var showErrorCallCount = 0
    var lastShowErrorMessage: String?
    
    // MARK: - CharacterListViewModelActions
    
    var actions: CharacterListViewModelActions {
        return CharacterListViewModelActions(
            showCharacterDetails: { [weak self] character in
                self?.showCharacterDetailsCallCount += 1
                self?.lastShowCharacterDetailsCharacter = character
            },
            showError: { [weak self] message in
                self?.showErrorCallCount += 1
                self?.lastShowErrorMessage = message
            }
        )
    }
    
    // MARK: - Test Helpers
    
    func reset() {
        showCharacterDetailsCallCount = 0
        lastShowCharacterDetailsCharacter = nil
        showErrorCallCount = 0
        lastShowErrorMessage = nil
    }
}
