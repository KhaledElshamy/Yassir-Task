//
//  CharacterListFlowCoordinator.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import UIKit
import SwiftUI

protocol CharacterListFlowCoordinatorDependencies  {
    func makeCharactersListViewController(
        actions: CharacterListViewModelActions
    ) -> CharactersListViewController
}

final class CharacterListFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: CharacterListFlowCoordinatorDependencies
    private weak var moviesListVC: CharactersListViewController?
    
    init(navigationController: UINavigationController? = nil,
         dependencies: CharacterListFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = CharacterListViewModelActions(
            showCharacterDetails: { [weak self] character in
                self?.showCharacterDetails(character)
            },
            showError: { [weak self] error in
                self?.showError(error)
            }
        )
        let vc = dependencies.makeCharactersListViewController(actions: actions)
        navigationController?.pushViewController(vc, animated: false)
        moviesListVC = vc
    }
    
    private func showCharacterDetails(_ character: CharacterResponse) {
        let characterDetailsView = CharacterDetailsView(character: character)
        let hostingController = UIHostingController(rootView: characterDetailsView)
        hostingController.title = character.name
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    private func showError(_ error: String) {
        // TODO: Implement error presentation
        print("Show error: \(error)")
    }
}
