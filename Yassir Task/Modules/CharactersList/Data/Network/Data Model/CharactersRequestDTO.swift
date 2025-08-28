//
//  CharacterRequestDTO.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

struct CharactersRequestDTO: Codable {
    let page: Int?
    let status: String?
    
    init(page: Int? = nil, status:String? = nil) {
        self.page = page
        self.status = status
    }
}
