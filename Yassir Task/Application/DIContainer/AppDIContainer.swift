//
//  AppDIContainer.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 27/08/2025.
//

import Foundation
import UIKit

final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: "https://rickandmortyapi.com")!
        )
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
}
