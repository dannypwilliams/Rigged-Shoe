# Bosses

Bosses are strategic build tests. They should pressure narrow builds without hard-deleting entire archetypes.

## Schedule

Implemented deterministic schedule:

- Stage 5: Pit Boss.
- Stage 8: The Inspector.
- Stage 10: The House.

The existing boss-rush challenge may still use the broader boss pool.

The broader boss/elite pool now includes The Whale, The Insider, The Auditor, and The Collector in addition to the prior surveillance, shuffler, tag-suppression, and final House bosses.

## Boss Rules

Current boss rules are bridged through the existing `Boss`, `BossManager`, and `GameViewModel` hand-resolution systems:

- Pit Boss: betting the same side 4 times in a row adds 1 Heat, and repeated-side betting gives the opponent a small ante-scaled score boost.
- The Inspector: reveal and shoe-control effects are reduced by 1 card where possible, and the first reveal/control action this stage adds 1 Heat.
- The House: combines Pit Boss repeated-side pressure, Inspector reveal/control pressure, forced shuffling, restored Banker commission, Tie payout cap, a halfway table-pressure shift, and a one-time dominant-tag adaptation.

This keeps the current app stable while the rebuilt `BossState` model remains available for a more data-driven boss catalog in a future phase.

## Boss Rewards

Boss rewards are generated through `BossReward.randomChoices`.

Boss reward choices can now grant boss relics. The current relic pool contains:

- Pit Boss Nod.
- Vault Key.
- Private Room.
- House Ledger.
- Loaded Sleeve.
- Red Phone.
- Backroom Dealer.
- Whale Credit.
- Fake Shuffle Machine.
- Surveillance Loop.
- Casino Host.
- House Blueprint.
- Whale Marker.
- Cooler Token.
- Insider Note.
- Audit Shield.
- Collector Waiver.
- Cooler Deck.
- Final Pass.
- Back Wall Phone.

## UI Integration

Existing boss flow remains:

- Boss announcement.
- Boss battle.
- Boss defeated reward draft.
- Reward selection.
- Shop.

`RewardDraftState.bossDraft` records boss reward draft metadata for future UI.

## Verification

`RiggedShoeTests/ShopBackboneTests.swift` verifies:

- Bosses appear at stages 5, 8, and 10.
- Boss relic reward IDs resolve to real relic definitions.
- The relic catalog contains 20 unique relics.
- Rebuild bosses use visible pressure and do not randomly disable acquired upgrades.

## Simplified For This Pass

Boss rules still live in the existing ViewModel bridge instead of a standalone `BossState` reducer. The current implementation favors visible pressure and battle-log feedback over hard-disabling whole archetypes.
