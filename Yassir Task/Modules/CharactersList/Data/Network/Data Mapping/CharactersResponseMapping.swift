//
//  CharactersResponseMapping.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

// MARK: - CharactersListResponseDTO to CharactersListResponse Mapping

extension CharactersListResponseDTO {
    
    /// Maps CharactersListResponseDTO to domain entity CharactersListResponse
    func toDomain() -> CharactersListResponse {
        let characters = results.compactMap { character in
            character.toDomain()
        }
        let info = self.info.toDomain()
        
        return CharactersListResponse(
            info: info, results: characters
        )
    }
}

extension CharactersListResponseDTO.Character {
    
    /// Maps Character DTO to domain entity CharacterResponse
    func toDomain() -> CharacterResponse? {
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
        
                        return CharacterResponse(
                    id: id,
                    name: name,
                    imageUrl: imageURL,
                    species: species,
                    status: mapStatus(status),
                    gender: gender,
                    location: location.name
                )
    }
    
    /// Maps string status to enum status
    private func mapStatus(_ statusString: String) -> CharacterResponse.Status {
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
    /// Maps Info DTO to domain entity CharactersInfo
    func toDomain() -> CharactersInfo {
        return CharactersInfo(
            count: count ?? 0,
            pages: pages ?? 0,
            next: next,
            prev: prev
        )
    }
}

// MARK: - Mapping Errors

enum CharactersMappingError: Error, LocalizedError {
    case invalidImageURL(String)
    case missingRequiredField(String)
    case invalidStatus(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidImageURL(let url):
            return "Invalid image URL: \(url)"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidStatus(let status):
            return "Invalid status: \(status)"
        }
    }
}
