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

    private func contactButton(_ index: Int) -> XCUIElement {
        let identified = app.buttons["contact-card-\(index)"]
        if identified.exists {
            return identified
        }

        return app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "position \(index) of 6")
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

    private func launch(extraArguments: [String] = []) {
        app.launchArguments = ["--ui-testing", "--reset-run"] + extraArguments
        app.launch()
    }
}
