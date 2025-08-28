//
//  CharacterEndPoints.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//


import Foundation

struct CharactersAPIEndPoints {
    
    static func getHomeList(with charactersRequestDTO: CharactersRequestDTO = CharactersRequestDTO()) -> Endpoint<CharactersResponseDTO> {

        return Endpoint(
            path: "api/character",
            method: .get,
            queryParametersEncodable: charactersRequestDTO
        )
    }
    
    
}
