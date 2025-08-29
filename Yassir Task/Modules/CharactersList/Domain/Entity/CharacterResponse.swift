//
//  CharacterResponse.swift
//  Yassir Task
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation

struct CharacterResponse: Hashable {
  enum Status: Hashable {
    case alive
    case dead
    case unknown
  }
  
  let id: Int
  let name: String
  let imageUrl: URL
  let species: String
  let status: Status
  let gender: String
  let location: String
}
