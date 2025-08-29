//
//  AppFlowCoordinator.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import UIKit

protocol AppFlowCoordinatorDelegate: AnyObject {
    func appFlowCoordinatorDidFinish(_ coordinator: AppFlowCoordinator)
}

final class AppFlowCoordinator: CharacterListFlowCoordinatorDependencies {
    
    // MARK: - Properties
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let dependencies: Dependencies
    private var characterListFlowCoordinator: CharacterListFlowCoordinator?
    weak var delegate: AppFlowCoordinatorDelegate?
    
    // MARK: - Dependencies
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
    }
    
    // MARK: - Initialization
    
    init(
        window: UIWindow,
        navigationController: UINavigationController = UINavigationController(),
        dependencies: Dependencies
    ) {
        self.window = window
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    // MARK: - Coordinator
    
    func start() {
        setupWindow()
        showCharacterListFlow()
    }
    
    func finish() {
        characterListFlowCoordinator = nil
        delegate?.appFlowCoordinatorDidFinish(self)
    }
    
    // MARK: - Private Methods
    
    private func setupWindow() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func showCharacterListFlow() {
        let characterListFlowCoordinator = CharacterListFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
        self.characterListFlowCoordinator = characterListFlowCoordinator
        characterListFlowCoordinator.start()
    }
    
    // MARK: - CharacterListFlowCoordinatorDependencies
    
    func makeCharactersListViewController(actions: CharacterListViewModelActions) -> CharactersListViewController {
        let viewController = CharactersListViewController()
        
        // Create dependency chain
        let charactersRepository = CharactersRepository(service: dependencies.apiDataTransferService)
        let charactersUseCase = CharactersUseCase(charactersRepository: charactersRepository)
        let viewModel = CharactersListViewModel(
            charactersUseCase: charactersUseCase,
            actions: actions
        )
        
        // Configure the view controller with the view model and actions
        viewController.configure(with: viewModel, actions: actions)
        
        return viewController
    }
}
