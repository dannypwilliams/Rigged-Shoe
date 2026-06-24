import XCTest

final class ReleaseFlowUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [
            "-riggedShoeUITest",
            "-riggedShoeUITestSkipGuided",
            "-riggedShoeUITestReduceMotion",
            "-riggedShoeUITestMuteAudio",
            "-riggedShoeUITestSeedRoute"
        ]
    }

    func testReleaseRouteSurfacesAndScreenshots() throws {
        app.launch()

        assertExists("runStart.screen", name: "Contact selection")
        capture("01-contact-selection")

        app.buttons["runStart.previewStageButton"].tap()
        assertExists("stagePreview.screen", name: "Scout Report")
        XCTAssertTrue(app.staticTexts["Scout Report"].exists)
        capture("02-scout-report")

        app.buttons["stagePreview.enterButton"].tap()
        XCTAssertTrue(app.buttons["battle.gameInfoButton"].waitForExistence(timeout: 5), "Missing battle Game Info button.")
        XCTAssertTrue(app.buttons["battle.dealButton"].exists, "Missing battle Deal button.")
        capture("03-battle")

        app.buttons["battle.gameInfoButton"].tap()
        assertExists("gameInfo.sheet", name: "Game Info")
        XCTAssertTrue(app.staticTexts["Game Info"].exists)
        capture("04-game-info")
        app.buttons["Close"].tap()

        assertExists("battle.dealButton", name: "Deal button")
        tapDealButton()
        tapDealButton()
        waitForEnabledDealOrStageResult(name: "Deal button after rapid taps")
        capture("05-resolved-hand")

        for _ in 0..<5 {
            if app.descendants(matching: .any)["stageResult.screen"].exists {
                break
            }

            tapDealButton()
            waitForEnabledDealOrStageResult()
        }

        assertExists("stageResult.screen", name: "Stage Result")
        capture("06-stage-result")

        app.buttons["stageResult.primaryButton"].tap()
        assertExists("reward.screen", name: "Reward draft")
        capture("07-reward-draft")

        let firstReward = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "reward.option.")).firstMatch
        XCTAssertTrue(firstReward.waitForExistence(timeout: 3), "Expected at least one reward option.")
        firstReward.tap()

        assertExists("shop.screen", name: "Shop")
        capture("08-shop")

        app.buttons["shop.continueButton"].tap()
        assertExists("stagePreview.screen", name: "Stage 2 Scout Report")
        XCTAssertTrue(app.staticTexts["Stage 2: 6 hands"].exists)
        capture("09-stage-2-scout-report")
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
