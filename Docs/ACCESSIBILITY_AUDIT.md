# Accessibility Audit

## Completed

- Contact cards expose selected state, difficulty, material resource changes, and selection hint.
- Heat is displayed as current/cap with status.
- Functional panels/buttons now use regular geometry rather than skewed hit targets.
- Stage flow copy uses House/Table Profile rather than defeated-opponent framing.
- Debug QA menu remains behind `#if DEBUG`.

## Must Re-test Before External Beta

- VoiceOver order on all run-flow overlays.
- Larger Dynamic Type on smallest iPhone.
- Game Info contrast and dismissal.
- Disabled wager reasons during guided first hand.
- Final summary coherence at high bankroll/Chips values.

## Residual Risk

Snapshot tests are not yet automated. Treat manual screenshots as required evidence until the snapshot gate exists.
