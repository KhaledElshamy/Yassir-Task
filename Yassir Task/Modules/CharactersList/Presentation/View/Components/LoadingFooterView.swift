//
//  LoadingFooterView.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import UIKit

// MARK: - Loading Footer View

final class LoadingFooterView: UIView {
    
    // MARK: - Properties
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let loadingLabel = UILabel()
    
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
        loadingLabel.text = "Loading more characters..."
    }
    
    func stopAnimating() {
        loadingIndicator.stopAnimating()
        loadingLabel.text = nil
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        setupLoadingIndicator()
        setupLoadingLabel()
        setupConstraints()
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.color = .systemBlue
        loadingIndicator.hidesWhenStopped = true
        addSubview(loadingIndicator)
    }
    
    private func setupLoadingLabel() {
        loadingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        loadingLabel.textColor = .secondaryLabel
        loadingLabel.textAlignment = .center
        addSubview(loadingLabel)
    }
    
    private func setupConstraints() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            // Loading label
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 8),
            loadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            loadingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            loadingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        // Set intrinsic content size
        frame = CGRect(x: 0, y: 0, width: 0, height: 80)
    }
}
