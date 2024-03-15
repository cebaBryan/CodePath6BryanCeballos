//
//  BeRealCloneUITestsLaunchTests.swift
//  BeRealCloneUITests
//
<<<<<<< HEAD
//  Created by Alejandro Diaz on 2/27/24.
=======
//  Created by Bryan Ceballos on 2/26/24.
>>>>>>> b6863650d4e1d504df93be0cf8e7a21bfc66ebf6
//

import XCTest

final class BeRealCloneUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
