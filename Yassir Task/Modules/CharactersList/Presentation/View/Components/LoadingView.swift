//
//  LoadingView.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import UIKit

// MARK: - Loading View

final class LoadingView: UIView {
    
    // MARK: - Properties
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private let stackView = UIStackView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public Methods
    
    func startAnimating() {
        loadingIndicator.startAnimating()
    }
    
    func stopAnimating() {
        loadingIndicator.stopAnimating()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground.withAlphaComponent(0.9)
        layer.cornerRadius = 12
        
        setupLoadingIndicator()
        setupLoadingLabel()
        setupStackView()
        setupConstraints()
        
        startAnimating()
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.color = .systemBlue
        loadingIndicator.hidesWhenStopped = true
    }
    
    private func setupLoadingLabel() {
        loadingLabel.text = "Loading characters..."
        loadingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        loadingLabel.textColor = .label
        loadingLabel.textAlignment = .center
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(loadingIndicator)
        stackView.addArrangedSubview(loadingLabel)
        
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Stack view
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            
            // View size
            widthAnchor.constraint(equalToConstant: 200),
            heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}
