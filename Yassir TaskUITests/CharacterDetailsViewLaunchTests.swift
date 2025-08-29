//
//  CharacterDetailsViewLaunchTests.swift
//  Yassir TaskUITests
//
//  Created by Khaled Elshamy on 29/08/2025.
//

import XCTest

final class CharacterDetailsViewLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after the app launches
        // For example, navigate to character details view and verify it loads
        // This is a basic launch test to ensure the app starts without crashing
    }
}
