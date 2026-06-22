# Reward Drafts

Reward drafts happen after winning a stage and before entering the shop.

## Model

Defined in `RiggedShoe/Models/StageReward.swift`.

Key types:

- `RewardDraftState`
- `RewardDraftKind`
- `RewardDraftChoice`
- `RewardDraftChoiceType`

The app still renders `StageReward` and `BossReward` in the existing reward screens. `RewardDraftState` records the rebuilt draft context: stage, kind, build archetype, dominant tags, choice types, and fit hints.

## Normal Stage Drafts

Normal reward drafts offer 3 choices from the stage reward pool.

Current draftable types include:

- Ante-scaled bankroll.
- Chips.
- Heat reduction.
- Modifier voucher.
- Rare modifier voucher.
- Consumable case.
- Attachment case.
- Shoe manipulation rewards.
- Legacy upgrade rewards.

The generation path is `StageReward.randomDraftChoices`.

## Boss Drafts

Boss reward drafts offer 3 choices from `BossReward`.

Current boss rewards include:

- Boss relic grants.
- Rare/legendary upgrade-style rewards.
- Ante-scaled bankroll and Chips.
- Heat/build-oriented rewards.

## Build Awareness

Draft generation reads active modifier tags.

- Rewards matching dominant tags are lightly weighted up.
- At least one pivot/off-build option is preserved when possible.
- Each draft choice stores a fit hint such as "Fits your current build" or "Off-build pivot".

## Reward Application

Implemented in `GameViewModel.applyStageReward`.

Rebuild reward effects can now:

- Add bankroll.
- Add Chips.
- Reduce Heat.
- Draft a modifier into active/bench slots.
- Add a consumable.
- Apply an attachment to a compatible active modifier.
- Grant a boss relic.

If a reward cannot apply because a slot or compatible target is unavailable, it grants a small Chip fallback and logs the reason.

## Persistence

Pending reward names are already saved. On restore, `RunPersistenceManager` reconstructs `RewardDraftState` from the pending stage or boss choices.

## Verification

Tests verify:

- Draft state contains the same number of choices as rewards.
- Dominant tags are detected.
- Duplicate reward names are not offered in the same draft.
- Fit hints are produced.
