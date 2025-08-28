//
//  CharactersListTestAssertions.swift
//  Yassir TaskTests
//
//  Created by Khaled Elshamy on 28/08/2025.
//

import Foundation
import XCTest
@testable import Yassir_Task

// MARK: - Test Assertions

struct CharactersListTestAssertions {
    
    static func assertCharactersListResponse(
        _ response: CharactersListResponse,
        expectedCharacterCount: Int,
        expectedInfo: CharactersInfo,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(response.results.count, expectedCharacterCount, "Expected \(expectedCharacterCount) characters, got \(response.results.count)", file: file, line: line)
        XCTAssertEqual(response.info.count, expectedInfo.count, "Expected count \(expectedInfo.count), got \(response.info.count)", file: file, line: line)
        XCTAssertEqual(response.info.pages, expectedInfo.pages, "Expected pages \(expectedInfo.pages), got \(response.info.pages)", file: file, line: line)
        XCTAssertEqual(response.info.next, expectedInfo.next, "Expected next \(expectedInfo.next ?? "nil"), got \(response.info.next ?? "nil")", file: file, line: line)
        XCTAssertEqual(response.info.prev, expectedInfo.prev, "Expected prev \(expectedInfo.prev ?? "nil"), got \(response.info.prev ?? "nil")", file: file, line: line)
    }
    
    static func assertCharacterResponse(
        _ character: CharacterResponse,
        expectedId: Int,
        expectedName: String,
        expectedStatus: CharacterResponse.Status,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(character.id, expectedId, "Expected id \(expectedId), got \(character.id)", file: file, line: line)
        XCTAssertEqual(character.name, expectedName, "Expected name \(expectedName), got \(character.name)", file: file, line: line)
        XCTAssertEqual(character.status, expectedStatus, "Expected status \(expectedStatus), got \(character.status)", file: file, line: line)
    }
}
