# Rebuild Phase Final Report

Updated: 2026-06-22

## Completed

- Added opponent battle structure around named casino opponents.
- Added 16 non-boss opponents with betting styles, weaknesses, flavor text, modifiers, and difficulty ratings.
- Reworked stage preview data to show opponent identity, table event, secondary objective, reward tier, and boss warning.
- Reworked stage result data to compare player profit against opponent profit.
- Added deterministic boss schedule for stages 5, 8, and 10.
- Rebuilt boss behavior so Pit Boss, The Inspector, and The House apply visible pressure instead of random upgrade deletion.
- Added Pit Boss repeated-side Heat and opponent-score pressure.
- Added Inspector reveal/control Heat pressure and one-card reveal reduction.
- Added House combined pressure: repeated-side Heat, reveal/control audit, forced shuffling, restored commission, Tie cap, midpoint pressure shift, and adaptive dominant-tag Heat.
- Added 20 boss relic definitions.
- Added boss reward choices that can grant relics.
- Added `RewardDraftState` plus normal and boss draft metadata.
- Added build-aware normal reward draft weighting and pivot-choice support.
- Added stage reward effects that can grant modifiers, consumables, attachments, boss relics, Chips, Heat relief, and bankroll.
- Added 16 table events.
- Added secondary objective system with 10 optional objectives.
- Added run summary build archetype and loss explanation support.
- Expanded the modifier catalog to 120 total modifiers across 16 archetype groups.
- Expanded shop-side content to 30 consumables and 30 attachments.
- Expanded starting contacts to 12 options.
- Expanded meta future-hook placeholders to 10 unlock hooks.
- Added tests covering content counts, boss schedule, reward draft metadata, stage preview data, and opponent score comparison.

## Simplified

- Boss rules still bridge through `GameViewModel` and the existing `Boss`/`BossManager` instead of fully replacing them with `BossState`.
- Boss pressure is model-backed and logged, but opponent action presentation is still lightweight compared with the eventual full boss reducer.
- Several table events and newly expanded content branches exist as data/custom rules before their full mechanical interpretation.
- Reward screens still render the existing `StageReward` and `BossReward` cards; `RewardDraftState` now supplies the rebuilt draft context for future UI polish.
- Unlock hooks remain framework-level placeholders in profile/meta systems rather than a full new meta-progression pass.

## Remaining

- Add opponent action presentation to the battle log so players see opponent bets and triggers during hands.
- Expand `RewardDraftState` into a dedicated UI card layout that shows choice type, tags, and fit hint.
- Route custom table event rules into live hand logic where useful.
- Add a complete manual simulator playthrough through Stage 10 after the next UI polish pass.
- Complete a fresh physical iOS Simulator playthrough after the latest content and final-boss tuning.
- Tune Boss 2 and Stage 9 after physical evidence confirms whether the current 47.8% and 45.5% headless late-game rates reflect the real player experience.

## Verification

- Debug iOS Simulator build: passed after the late-game balance patch.
- Simulator unit tests: passed after the late-game balance patch.
- Latest headless balance simulation: 720 runs, 20.08 MB peak RSS, 120 modifiers parsed, 12 contacts parsed.
- Latest Boss 2 conditional clear rate: 47.8%, slightly above the requested 30-45% target band.
- Latest Stage 9 conditional clear rate: 45.5%, above the requested 20-35% target band.
- Latest Final Boss conditional clear rate: 20.0%, inside the requested 10-25% target band.
- Test suite: `RiggedShoeTests/ShopBackboneTests.swift`.
- Latest verification added boss-rule guards for visible pressure, no random boss upgrade disabling, deterministic boss schedule, and Inspector audit pressure.
