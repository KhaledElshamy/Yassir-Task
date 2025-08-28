//
//  CharactersResponseMapping.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

// MARK: - CharactersResponseDTO to CharactersResponse Mapping

extension CharactersResponseDTO {
    
    /// Maps CharactersResponseDTO to domain entity CharactersResponse
    func toDomain() -> [CharactersResponse] {
        return results.compactMap { character in
            character.toDomain()
        }
    }
    
    /// Maps CharactersResponseDTO to domain entity with info
    func toDomainWithInfo() -> (characters: [CharactersResponse], info: CharactersInfo) {
        let characters = toDomain()
        let info = self.info.toDomain()
        return (characters, info)
    }
}

extension CharactersResponseDTO.Character {
    
    /// Maps Character DTO to domain entity CharactersResponse
    func toDomain() -> CharactersResponse? {
        // Validate required fields
        guard !name.isEmpty, !species.isEmpty else {
            return nil
        }
        
        // Create image URL with fallback
        let imageURL: URL
        if let url = URL(string: image), url.scheme != nil {
            imageURL = url
        } else {
            // Fallback to placeholder image
            imageURL = URL(string: "https://via.placeholder.com/150")!
        }
        
        return .init(id: id,
                     name: name,
                     imageUrl: imageURL,
                     species: species,
                     status: mapStatus(status), gender: gender)
    }
    
    
    /// Maps string status to enum status
    private func mapStatus(_ statusString: String) -> CharactersResponse.Status {
        switch statusString.lowercased() {
        case "alive":
            return .alive
        case "dead":
            return .dead
        default:
            return .unknown
        }
    }
}

// MARK: - Info DTO to Domain Mapping
extension Info {
    /// Maps Info DTO to domain entity (if needed)
    func toDomain() -> CharactersInfo {
        return .init(count: count ?? 0,
                     pages: pages ?? 0,
                     next: next, prev: prev)
    }
}
