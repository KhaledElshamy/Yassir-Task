//
//  CharactersListRepository.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

final class CharactersRepository: CharactersRepositoryProtocol {
    
    private let service: DataTransferService

    init(service: DataTransferService) {
        self.service = service
    }
    
    func fetchCharacters(page: Int, status: String) async throws -> CharactersListResponse {
        do {
            let requestDTO = CharactersRequestDTO(page: page, status: status)
            let endpoint = CharactersAPIEndPoints.getCharactersList(with: requestDTO)
            let CharactersResponseDTO: CharactersListResponseDTO = try await service.request(with: endpoint)
            return CharactersResponseDTO.toDomain()
        } catch let error {
            throw error
        }
    }
}
