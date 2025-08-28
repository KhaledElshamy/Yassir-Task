//
//  CharacterListViewController.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import UIKit

final class CharacterListViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var viewModel: CharctersListViewModel?
    private var actions: CharacterListViewModelActions?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: CharctersListViewModel, actions: CharacterListViewModelActions) {
        self.viewModel = viewModel
        self.actions = actions
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        title = "Characters"
        view.backgroundColor = .systemBackground
        
        // Configure table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CharacterCell")
        tableView.separatorStyle = .singleLine
    }
}
