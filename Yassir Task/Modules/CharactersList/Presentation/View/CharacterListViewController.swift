//
//  CharactersListViewController.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import UIKit
import SwiftUI
import Combine

// MARK: - CharactersListViewController

final class CharactersListViewController: UITableViewController {
    
    // MARK: - Properties
    
    private enum Section { case main }
    private var dataSource: UITableViewDiffableDataSource<Section, CharacterResponse>!
    private var viewModel: CharactersListViewModel?
    private var actions: CharacterListViewModelActions?
    private var cancellables = Set<AnyCancellable>()
    private let imageCache = ImageCache.shared
    
    private let filterSegmentedControl: UISegmentedControl = {
        let items = ["All", "Alive", "Dead", "Unknown"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .systemBackground
        segmentedControl.selectedSegmentTintColor = .darkGray
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
        return segmentedControl
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadInitialData()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Configuration
    
    func configure(with viewModel: CharactersListViewModel, actions: CharacterListViewModelActions) {
        self.viewModel = viewModel
        self.actions = actions
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        setupNavigationBar()
        setupFilterButtons()
        setupTableView()
        setupRefreshControl()
        configureDataSource()
    }
    
    private func setupNavigationBar() {
        title = "Characters"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.darkGray
        ]
    }
    
    private func setupFilterButtons() {
        setupFilterSegmentedControl()
    }
    
    private func setupFilterSegmentedControl() {
        filterSegmentedControl.addTarget(self, action: #selector(filterSegmentedControlChanged), for: .valueChanged)
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(filterSegmentedControl)
        
        NSLayoutConstraint.activate([
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Set content inset to account for the segmented control
        let segmentedControlHeight: CGFloat = 40
        let spacing: CGFloat = 20
        let topInset = segmentedControlHeight + spacing + 20 // 20 for safe area
        
        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .systemBlue
        tableView.refreshControl = refreshControl
    }
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, character in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            // Configure cell with SwiftUI content
            cell.contentConfiguration = UIHostingConfiguration {
                CharacterRow(
                    name: character.name,
                    species: character.species,
                    status: character.status,
                    image: nil
                )
            }
            
            // Async image loading
            Task { [weak self, weak cell] in
                guard let self = self, let cell = cell else { return }
                
                let image = await self.imageCache.loadImage(from: character.imageUrl)
                
                await MainActor.run {
                    // Check if cell is still valid (not reused)
                    guard let currentIndexPath = self.tableView.indexPath(for: cell),
                          currentIndexPath == indexPath else { return }
                    
                    cell.contentConfiguration = UIHostingConfiguration {
                        CharacterRow(
                            name: character.name,
                            species: character.species,
                            status: character.status,
                            image: image
                        )
                    }
                }
            }
            
            cell.selectionStyle = .default
            return cell
        }
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        guard let viewModel = viewModel else { return }
        
        // Characters binding
        viewModel.$characters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &cancellables)
        
        // Loading state binding
        viewModel.$loading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.updateLoadingState(loading)
            }
            .store(in: &cancellables)
        
        // Error state binding
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.updateErrorState(error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        viewModel?.refreshData()
    }
    
    @objc private func filterSegmentedControlChanged() {
        let selectedStatus: CharacterResponse.Status?
        
        switch filterSegmentedControl.selectedSegmentIndex {
        case 1:
            selectedStatus = .alive
        case 2:
            selectedStatus = .dead
        case 3:
            selectedStatus = .unknown
        default:
            selectedStatus = nil
        }
        
        viewModel?.filterByStatus(selectedStatus)
    }
    
    // MARK: - Data Loading
    
    private func loadInitialData() {
        viewModel?.loadCharacters()
    }
    
    // MARK: - UI Updates
    
    private func applySnapshot(_ animated: Bool = true) {
        guard let viewModel = viewModel else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, CharacterResponse>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.characters)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func updateLoadingState(_ loading: CharactersListViewModelLoading?) {
        DispatchQueue.main.async { [weak self] in
            switch loading {
            case .fullScreen:
                self?.showFullScreenLoading()
            case .nextPage:
                self?.showNextPageLoading()
            case .refreshing:
                self?.showRefreshing()
            case .none:
                self?.hideLoading()
            }
        }
    }
    
    private func updateErrorState(_ error: String?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.presentError(error)
            }
        }
    }
    
    // MARK: - Loading States
    
    private func showFullScreenLoading() {
        // Show loading indicator in center of screen
        let loadingView = createLoadingView()
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func showNextPageLoading() {
        // Add loading footer for pagination
        let loadingFooterView = LoadingFooterView()
        loadingFooterView.startAnimating()
        tableView.tableFooterView = loadingFooterView
    }
    
    private func showRefreshing() {
        // Refresh control handles this automatically
    }
    
    private func hideLoading() {
        tableView.refreshControl?.endRefreshing()
        tableView.tableFooterView = nil
        view.subviews.forEach { subview in
            if subview is LoadingView {
                subview.removeFromSuperview()
            }
        }
    }
    
    private func presentError(_ error: String) {
        let alert = UIAlertController(
            title: "Error",
            message: error,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func createLoadingView() -> LoadingView {
        return LoadingView()
    }
}

// MARK: - UITableViewDelegate

extension CharactersListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let character = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel?.selectCharacter(character)
    }
    
    // MARK: - Pagination trigger
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel else { return }
        
        let y = scrollView.contentOffset.y
        let threshold = scrollView.contentSize.height - scrollView.bounds.height * 1.5
        
        if y > threshold && viewModel.canLoadMore {
            viewModel.loadNextPage()
        }
    }
}
