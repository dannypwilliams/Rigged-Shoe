# Ship Week Changelog

## 2026-06-23 Release Playability Pass

- Fixed final-stage continuation so clearing Stage 2 ends at the run-complete/replay path instead of creating an unused reward draft.
- Made Stage 1 reward selection idempotent by accepting only rewards that are still in the pending draft list.
- Added a no-legal-wager safeguard: when bankroll falls below the current table minimum, the run resolves to an explained stage result instead of leaving dead battle controls.
- Changed new shop modifier purchases to respect the five active modifier slots instead of silently overflowing into hidden bench storage.
- Replaced the native Game Info confirmation dialog with the existing high-contrast custom help sheet and added release-route rules for hand counts, legal bets, Tie pushes, No Commission Night, Chips, Heat, and the guided first hand.
- Updated result/reward copy to describe solvency through fixed hand counts rather than opponent score-margin logic.
- Added deterministic coverage for final-stage replay, reward double-tap prevention, below-minimum failure resolution, full modifier capacity, and restore-after-reward behavior.
- Cleared local macOS extended attributes from project files so simulator signing works when building with DerivedData outside the synced Documents workspace.

