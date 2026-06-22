# Rigged Shoe Physical Playtest Report

Updated: 2026-06-22

## Status

Physical iOS Simulator testing was partially completed on the `RiggedShoe-SE-Layout-Test` simulator device, including a fresh reinstall smoke pass after the bet-flow fix.

This was a RAM-conscious smoke test, not a full fresh-install Stage 1-to-final-boss run. The test verified the main flow across starting contact selection, Game Room, Stage 1 battle, Stage Result, and Reward Draft. A full manual playthrough through Boss 1 and deeper shop usage is still required before calling the vertical slice app-ready.

## Intended Workflow

Use one common iPhone simulator, preferably the existing `RiggedShoe-SE-Layout-Test` device, and run a short player-like pass:

1. Build and launch Rigged Shoe.
2. Start a fresh run.
3. Choose a starting contact.
4. Enter Stage 1 battle.
5. Place Player, Banker, and Tie bets where legal.
6. Change bet amounts.
7. Complete Stage 1.
8. Choose a reward.
9. Enter the shop.
10. Buy one modifier.
11. Freeze one offer if available.
12. Reroll if Chips allow.
13. Continue to Stage 2.
14. Play through Stage 2.
15. Continue toward Boss 1 if practical.

## UX Questions To Answer

- Is the Game Room still the obvious main path?
- Are bankroll, Chips, Heat, stage, and hand count always visible?
- Are Player, Banker, Tie, and bet amount buttons thumb-friendly?
- Does the bet cap explanation make sense after the new minimum-bet cap fix?
- Are modifier triggers visible without slowing the hand down?
- Is the reward draft fast to understand?
- Does the shop clearly show buy, freeze, reroll, sell, and level-up behavior?
- Does the player understand why a stage clears or fails?
- Do boss rules feel like counterplay instead of hidden punishment?

## Known Pre-Test Risks

- Stage 8 and Stage 9 are too easy in the current headless report, but that may be distorted by low reach counts.
- Stage 3 bankroll-minimum failures are still slightly high.
- The shop and reward screens have model/test coverage, but still need tap-through verification on the smallest supported iPhone layout.

## Environment Used

- Simulator device: `RiggedShoe-SE-Layout-Test`.
- App bundle: `com.danielwilliams.RiggedShoe`.
- Build style: local Debug simulator build.
- Screenshots captured:
  - `Docs/PlaytestScreenshots/physical-playtest-launch-20260622.png`
  - `Docs/PlaytestScreenshots/physical-playtest-after-wait-20260622.png`
  - `Docs/PlaytestScreenshots/physical-playtest-after-betfix-fresh-launch-20260622.png`
  - `Docs/PlaytestScreenshots/physical-playtest-after-betfix-contact-20260622.png`
  - `Docs/PlaytestScreenshots/physical-playtest-final-fresh-contact-20260622.png`

## Steps Performed

1. Booted the SE layout simulator.
2. Built, installed, and launched a fresh Debug simulator app.
3. Waited through the launch surface.
4. Reached starting contact selection.
5. Started the default Tourist run.
6. Verified the scripted tutorial hand used Player and the current Stage 1 minimum bet.
7. Changed bet side and amount during normal hands.
8. Completed all five Stage 1 hands.
9. Reached Stage Cleared.
10. Opened Reward Draft.
11. Ran a 600-run headless smoke simulation after the UI fixes.

## Verified Working

- Deal button was visible and tappable on the SE-size test device.
- Stage 1 now starts with legal current-stage bet buttons: $25 and $50 playable, larger buttons visibly capped/locked.
- The scripted tutorial hand no longer strands the player on an invalid $10 bet.
- The old every-few-hands `Choose an Upgrade` overlay no longer interrupts Stage 1 after hand 2.
- Stage Cleared screen fit the small screen and showed Draft Reward.
- Reward Draft displayed three choices and remained readable.
- Stage Result compared the player against the opponent and explained profit/loss, bankroll, Heat, Chips, table event, optional objective, and build.
- Reward Draft appeared after Stage 1 instead of the legacy UpgradeCard overlay.

## UX Issues Found

- Starting contact selection visually opened scrolled into the middle of the contact grid on the SE simulator. This was addressed after the smoke test by replacing the tall grid with a featured selected-contact card and horizontal contact rail. It still needs fresh physical verification.
- Background Game Room controls were still present in the accessibility tree while modal flow overlays were visible. Visually this was acceptable, but accessibility should hide inactive background controls.
- Disabled shop Buy buttons were functionally disabled, but their visual styling still looked too close to enabled yellow buttons. This was addressed after the smoke test with dimmed disabled button styling and still needs fresh shop-phase verification.
- Full boss-flow physical testing was not reached in this smoke pass.
- The Stage 2 unlock copy was stale during the first reward-draft tap-through (`New bet unlocked: $20`). It was corrected afterward to derive from the actual next-stage bet table.

## Result

- Simulator launched: Yes, fresh-install Stage 1 smoke test completed.
- Build result: Debug simulator app built and launched successfully. Simulator-backed unit tests passed after the bet-flow, legacy-overlay, contact-picker, and disabled-shop-button fixes.
- Bugs fixed from physical evidence: invalid tutorial $10 bet soft-lock, current-stage bet button mismatch, legacy upgrade overlay interrupting compact battles, and stale Stage 2 bet-unlock copy.
- Follow-up UI fixes after this smoke pass: compact starting contact picker and clearer disabled shop buttons.
- Latest headless follow-up: 600 runs with seed `20260622`, 19.92 MB peak RSS, written to `Docs/sim-post-contact-ui-fix-20260622.json`.
- Screenshots: Captured in `Docs/PlaytestScreenshots/`.
- Current verdict: Stage 1 main path is physically navigable on the SE test device, but Boss 1, deeper shop usage, and Stage 2+ pacing still need a longer physical playthrough.
