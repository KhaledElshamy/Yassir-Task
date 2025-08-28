//
//  CharacterListFlowCoordinator.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import UIKit

protocol CharacterListFlowCoordinatorDependencies  {
    func makeCharactersListViewController(
        actions: CharacterListViewModelActions
    ) -> CharacterListViewController
}

final class CharacterListFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: CharacterListFlowCoordinatorDependencies
    private weak var moviesListVC: CharacterListViewController?
    
    init(navigationController: UINavigationController? = nil,
         dependencies: CharacterListFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = CharacterListViewModelActions()
        let vc = dependencies.makeCharactersListViewController(actions: actions)
        navigationController?.pushViewController(vc, animated: false)
        moviesListVC = vc
    }
}
