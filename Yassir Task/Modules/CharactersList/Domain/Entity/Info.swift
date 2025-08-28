//
//  Info.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

// MARK: - Domain Entity for Info

struct CharactersInfo {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
    
    /// Indicates if there are more pages available
    var hasNextPage: Bool {
        return next != nil
    }
    
    /// Indicates if there are previous pages available
    var hasPreviousPage: Bool {
        return prev != nil
    }
}
