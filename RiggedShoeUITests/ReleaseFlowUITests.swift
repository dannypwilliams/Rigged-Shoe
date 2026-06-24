import XCTest

final class ReleaseFlowUITests: XCTestCase {
    private var app: XCUIApplication!
    private let contactIDs = [
        "contact.banker-bias",
        "contact.player-surge",
        "contact.opening-tell",
        "contact.tie-insurance",
        "contact.lucky-chip",
        "contact.clean-hands"
    ]

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = makeApp()
    }

    func testReleaseRouteSurfacesAndScreenshots() throws {
        launchFreshApp()
        runReleaseRoute(
            capturePrefix: "primary",
            detailScreenshots: true,
            resumeCheckpoints: [.battle, .reward, .shop]
        )
    }

    func testAllStartingContactsReachStageTwo() throws {
        for contactID in contactIDs {
            launchFreshApp()
            runReleaseRoute(
                contactID: contactID,
                capturePrefix: "matrix-\(contactID.replacingOccurrences(of: ".", with: "-"))",
                detailScreenshots: false,
                resumeCheckpoints: []
            )
            app.terminate()
        }
    }

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-riggedShoeUITest",
            "-riggedShoeUITestSkipGuided",
            "-riggedShoeUITestReduceMotion",
            "-riggedShoeUITestMuteAudio",
            "-riggedShoeUITestSeedRoute"
        ]
        return app
    }

    private func launchFreshApp() {
        app = makeApp()
        app.launch()
    }

    private func runReleaseRoute(
        contactID: String? = nil,
        capturePrefix: String,
        detailScreenshots: Bool,
        resumeCheckpoints: Set<RouteResumeCheckpoint>
    ) {
        assertExists("runStart.screen", name: "Contact selection")
        if let contactID {
            let contactButton = app.buttons["runStart.contact.\(contactID)"]
            XCTAssertTrue(contactButton.waitForExistence(timeout: 3), "Missing contact \(contactID).")
            contactButton.tap()
        }
        capture("\(capturePrefix)-01-contact-selection")

        app.buttons["runStart.previewStageButton"].tap()
        assertExists("stagePreview.screen", name: "Scout Report")
        XCTAssertTrue(app.staticTexts["Scout Report"].exists)
        if detailScreenshots {
            capture("\(capturePrefix)-02-scout-report")
        }

        app.buttons["stagePreview.enterButton"].tap()
        XCTAssertTrue(app.buttons["battle.gameInfoButton"].waitForExistence(timeout: 5), "Missing battle Game Info button.")
        XCTAssertTrue(app.buttons["battle.dealButton"].exists, "Missing battle Deal button.")
        if detailScreenshots {
            capture("\(capturePrefix)-03-battle")
        }
        resumeIfRequested(.battle, resumeCheckpoints: resumeCheckpoints)

        if detailScreenshots {
            app.buttons["battle.gameInfoButton"].tap()
            assertExists("gameInfo.sheet", name: "Game Info")
            XCTAssertTrue(app.staticTexts["Game Info"].exists)
            capture("\(capturePrefix)-04-game-info")
            app.buttons["gameInfo.closeButton"].tap()
        }

        assertExists("battle.dealButton", name: "Deal button")
        tapDealButton()
        tapDealButton()
        waitForEnabledDealOrStageResult(name: "Deal button after rapid taps")
        if detailScreenshots {
            capture("\(capturePrefix)-05-resolved-hand")
        }

        for _ in 0..<5 {
            if app.descendants(matching: .any)["stageResult.screen"].exists {
                break
            }

            tapDealButton()
            waitForEnabledDealOrStageResult()
        }

        assertExists("stageResult.screen", name: "Stage Result")
        if detailScreenshots {
            capture("\(capturePrefix)-06-stage-result")
        }

        app.buttons["stageResult.primaryButton"].tap()
        assertExists("reward.screen", name: "Reward draft")
        if detailScreenshots {
            capture("\(capturePrefix)-07-reward-draft")
        }
        resumeIfRequested(.reward, resumeCheckpoints: resumeCheckpoints)

        let firstReward = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "reward.option.")).firstMatch
        XCTAssertTrue(firstReward.waitForExistence(timeout: 3), "Expected at least one reward option.")
        firstReward.tap()

        assertExists("shop.screen", name: "Shop")
        if detailScreenshots {
            capture("\(capturePrefix)-08-shop")
        }
        resumeIfRequested(.shop, resumeCheckpoints: resumeCheckpoints)

        app.buttons["shop.continueButton"].tap()
        assertExists("stagePreview.screen", name: "Stage 2 Scout Report")
        XCTAssertTrue(app.staticTexts["Stage 2: 6 hands"].exists)
        capture("\(capturePrefix)-09-stage-2-scout-report")
    }

    private enum RouteResumeCheckpoint {
        case battle
        case reward
        case shop
    }

    private func resumeIfRequested(
        _ checkpoint: RouteResumeCheckpoint,
        resumeCheckpoints: Set<RouteResumeCheckpoint>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard resumeCheckpoints.contains(checkpoint) else { return }

        let expectedIdentifier: String
        switch checkpoint {
        case .battle:
            expectedIdentifier = "battle.dealButton"
        case .reward:
            expectedIdentifier = "reward.screen"
        case .shop:
            expectedIdentifier = "shop.screen"
        }

        XCUIDevice.shared.press(.home)
        app.activate()
        let element = app.descendants(matching: .any)[expectedIdentifier]
        XCTAssertTrue(
            element.waitForExistence(timeout: 5),
            "Missing \(expectedIdentifier) after background/resume.",
            file: file,
            line: line
        )
    }

    private func assertExists(
        _ identifier: String,
        name: String,
        timeout: TimeInterval = 5,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let element = app.descendants(matching: .any)[identifier]
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Missing \(name) (\(identifier)).", file: file, line: line)
    }

    private func tapDealButton(
        timeout: TimeInterval = 3,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let dealButton = app.buttons["battle.dealButton"]
        XCTAssertTrue(dealButton.waitForExistence(timeout: timeout), "Missing Deal button during route.", file: file, line: line)
        XCTAssertTrue(dealButton.isEnabled, "Deal button was not enabled before route tap.", file: file, line: line)
        dealButton.tap()
    }

    private func waitForEnabledDealOrStageResult(
        name: String = "Deal or Stage Result",
        timeout: TimeInterval = 6,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if app.descendants(matching: .any)["stageResult.screen"].exists {
                return
            }

            let dealButton = app.buttons["battle.dealButton"]
            if dealButton.exists && dealButton.isEnabled {
                return
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }

        XCTFail("\(name) did not become available.\n\(app.debugDescription)", file: file, line: line)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
