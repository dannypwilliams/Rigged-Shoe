import XCTest

final class RiggedShoeUIHardeningTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testAllSixContactsAreImmediatelyReachable() {
        launch()
        XCTAssertTrue(app.staticTexts["contact-count"].waitForExistence(timeout: 12))

        for index in 1...6 {
            let contact = contactButton(index)
            XCTAssertTrue(contact.waitForExistence(timeout: 2), "Missing contact \(index)")
            XCTAssertTrue(contact.isHittable, "Contact \(index) should be hittable without coordinate taps")
            XCTAssertTrue(contact.label.contains("position \(index) of 6"), contact.label)
        }

        let sixthContact = contactButton(6)
        sixthContact.tap()
        XCTAssertTrue(sixthContact.label.contains("selected"), sixthContact.label)
        XCTAssertTrue(app.descendants(matching: .any)["selected-contact-details"].exists)
    }

    func testGuidedOpeningLocksOnlyPlayerTwentyFive() {
        launch(extraArguments: ["--ui-testing-stage-one-battle"])

        XCTAssertTrue(app.buttons["deal-button"].waitForExistence(timeout: 8))

        XCTAssertTrue(app.buttons["bet-type-player"].isEnabled)
        XCTAssertFalse(app.buttons["bet-type-banker"].isEnabled)
        XCTAssertTrue(app.buttons["bet-type-banker"].label.contains("Unlocks after the guided first hand."), app.buttons["bet-type-banker"].label)
        XCTAssertFalse(app.buttons["bet-type-tie"].isEnabled)
        XCTAssertTrue(app.buttons["bet-type-tie"].label.contains("Unlocks after the guided first hand."), app.buttons["bet-type-tie"].label)

        XCTAssertTrue(app.buttons["bet-amount-2500"].isEnabled)
        XCTAssertFalse(app.buttons["bet-amount-5000"].isEnabled)
        XCTAssertTrue(app.buttons["bet-amount-5000"].label.contains("Unlocks after the guided first hand."), app.buttons["bet-amount-5000"].label)
        XCTAssertFalse(app.buttons["bet-amount-7500"].isEnabled)
    }

    func testFinalReviewShowsIntentionalProgressState() {
        launch(extraArguments: ["--ui-testing-stage-one-battle", "--ui-testing-hold-review-state"])

        let deal = app.buttons["deal-button"]
        XCTAssertTrue(deal.waitForExistence(timeout: 8))
        deal.tap()

        let review = app.buttons["reviewing-hand-progress"]
        XCTAssertTrue(review.waitForExistence(timeout: 3))
        XCTAssertFalse(review.isEnabled)
        XCTAssertFalse(app.buttons["deal-button"].exists)
    }

    func testGameInfoSheetShowsRouteRulesAndPayouts() {
        launch(extraArguments: ["--ui-testing-stage-one-battle"])

        let info = app.buttons["game-info-button"]
        XCTAssertTrue(info.waitForExistence(timeout: 8))
        XCTAssertTrue(info.isHittable)
        info.tap()

        XCTAssertTrue(app.descendants(matching: .any)["game-info-sheet"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Game Info"].exists)
        XCTAssertTrue(staticText(containing: "Stage 1 wagers are $25, $50, and $75").exists)
        XCTAssertTrue(staticText(containing: "Stage 2 wagers are $50 and $100").exists)
        XCTAssertTrue(staticText(containing: "guided first hand locks Player $25").exists)
        XCTAssertTrue(staticText(containing: "Banker normally pays 0.95:1").exists)
        XCTAssertTrue(app.buttons["game-info-close-button"].isHittable)
    }

    func testStageOneResultRowsAndRewardCTAStayReachable() {
        launch(extraArguments: ["--ui-testing-stage-one-result"])

        XCTAssertTrue(app.descendants(matching: .any)["stage-result"].waitForExistence(timeout: 8))
        XCTAssertTrue(staticText(containing: "Result").exists)
        XCTAssertTrue(staticText(containing: "Clear Rule").exists)
        XCTAssertTrue(staticText(containing: "Progress").exists)

        let continueButton = button(identifier: "stage-result-primary-button", labelPrefix: "Take 1 Reward")
        XCTAssertTrue(continueButton.exists)
        scrollUntilHittable(continueButton)
        XCTAssertTrue(continueButton.isHittable)
        continueButton.tap()

        XCTAssertTrue(app.buttons["reward-choice-1"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["reward-choice-1"].isHittable)
    }

    func testStageOneRewardChoiceIsImmediatelyReachable() {
        launch(extraArguments: ["--ui-testing-stage-one-reward"])

        let firstReward = app.buttons["reward-choice-1"]
        XCTAssertTrue(firstReward.waitForExistence(timeout: 8))
        XCTAssertTrue(firstReward.isHittable)
    }

    func testStageOneBattlePassesCoreAccessibilityAudit() throws {
        launch(extraArguments: ["--ui-testing-stage-one-battle"])

        XCTAssertTrue(app.buttons["deal-button"].waitForExistence(timeout: 8))
        try performCoreAccessibilityAudit()
    }

    func testStageOneResultPassesCoreAccessibilityAudit() throws {
        launch(extraArguments: ["--ui-testing-stage-one-result"])

        XCTAssertTrue(app.descendants(matching: .any)["stage-result"].waitForExistence(timeout: 8))
        try performCoreAccessibilityAudit()
    }

    func testStageOneRewardPassesCoreAccessibilityAudit() throws {
        launch(extraArguments: ["--ui-testing-stage-one-reward"])

        XCTAssertTrue(app.buttons["reward-choice-1"].waitForExistence(timeout: 8))
        try performCoreAccessibilityAudit()
    }

    private func contactButton(_ index: Int) -> XCUIElement {
        let identified = app.buttons["contact-card-\(index)"]
        if identified.exists {
            return identified
        }

        return app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "position \(index) of 6")
        ).firstMatch
    }

    private func staticText(containing text: String) -> XCUIElement {
        app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", text)
        ).firstMatch
    }

    private func button(identifier: String, labelPrefix: String) -> XCUIElement {
        let identified = app.buttons[identifier]
        if identified.exists {
            return identified
        }

        return app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH %@", labelPrefix)
        ).firstMatch
    }

    private func scrollUntilHittable(_ element: XCUIElement, maxSwipes: Int = 3) {
        var remainingSwipes = maxSwipes
        while element.exists && !element.isHittable && remainingSwipes > 0 {
            app.swipeUp()
            remainingSwipes -= 1
        }
    }

    private func performCoreAccessibilityAudit() throws {
        try app.performAccessibilityAudit(for: [
            .hitRegion,
            .sufficientElementDescription,
            .trait,
            .textClipped
        ])
    }

    private func launch(extraArguments: [String] = []) {
        app.launchArguments = ["--ui-testing", "--reset-run"] + extraArguments
        app.launch()
    }
}
