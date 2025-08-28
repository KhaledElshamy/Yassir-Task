//
//  Characters.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

struct CharactersListResponseDTO: Codable {
    let info: Info
    let results: [Character]
}

extension CharactersListResponseDTO {
    // MARK: - Result
    struct Character: Codable {
        let id: Int
        let name: String
        let status: String
        let species: String
        let gender: String
        let image: String
    }
}

// MARK: - Info
struct Info: Codable {
    let count, pages: Int?
    let next: String?
    let prev: String?
}
