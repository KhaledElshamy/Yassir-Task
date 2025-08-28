//
//  CharactersRepositoryProtocol.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

protocol CharactersRepositoryProtocol {
    @discardableResult
    func fetchCharacters(page:Int, status:String) async throws -> CharactersListResponse
}
