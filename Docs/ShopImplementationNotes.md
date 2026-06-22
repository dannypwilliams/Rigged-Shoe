# Rigged Shoe Shop Implementation Notes

Updated: 2026-06-22

The rebuilt shop phase is now live after reward drafts. It is intentionally compact: four offers, active/bench modifiers, one consumable slot, one relic slot, freeze, reroll, buy, sell, and duplicate leveling.

## Data Flow

- `ShopState` stores ante, reroll cost, offers, frozen IDs, and feature flags.
- `ShopOffer` references content by ID so persistence stays small.
- `GameViewModel.prepareShop(forceReroll:)` generates offers for the current stage.
- `ShopPhaseView` renders the state and sends buy/sell/freeze/reroll intents back to `GameViewModel`.

## Offer Generation

The shop generates four offers:

- Mostly modifiers.
- Some consumables.
- Some attachments.
- Frozen unsold offers carry forward.
- Starting contact tags bias matching modifier offers.
- Tier scales from stage number and bosses defeated.

Current tier curve:

- Tier 1: stages 1-2.
- Tier 2: stages 3-4.
- Tier 3: after Boss 1.
- Tier 4: after Boss 2.
- Tier 5: final stretch, stage 9+.

## Modifier Inventory

- Active slots: 5.
- Bench slots: 2.
- Buying a duplicate modifier levels the existing instance up to Level 3.
- New modifiers fill active slots first, then bench slots.
- Selling a modifier returns its sell value in Chips.

## Consumables

- Consumable slot limit: 1.
- Using a consumable immediately applies its supported effects and removes it.
- Currently functional consumable effects include bankroll, Chips, Heat, reveals, burns, card movement, card injection, and card removal.

## Attachments

- Attachments auto-attach to the first compatible active modifier.
- Attachment offers now preview their current target, for example `Attaches to Banker Bias`.
- If there is no compatible active modifier, the shop disables the purchase and explains why.
- Attachment definitions are stored once by ID; active modifier instances hold attached IDs.
- Modifier resolution applies compatible attachment effects whenever the base modifier triggers.
- Duplicate attachment definitions are ignored to prevent duplicate-ID dictionary crashes.

## Debug Verification

`GameViewModel.debugRunPhase3Checks()` now includes a shop-flow smoke check. It snapshots and restores the real run state, then verifies:

- Buying a duplicate modifier levels the existing copy.
- Consumable purchases respect the one-slot limit and show the full-slot block reason.
- Compatible attachments preview their target and apply to the active modifier.
- Incompatible attachments are blocked with a readable reason.
- Frozen offers survive reroll.
- Bench/equip movement respects slot limits.
- Selling a modifier grants Chips.

There is also a real XCTest target, `RiggedShoeTests`, with `ShopBackboneTests`.
Run it from the project root with:

```sh
Scripts/mac_test_simulator.sh 'id=<SIMULATOR_UDID>'
```

Or call Xcode directly with a concrete simulator destination:

```sh
xcodebuild test -project RiggedShoe.xcodeproj -scheme RiggedShoe -destination 'id=<SIMULATOR_UDID>' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO
```

Current coverage includes catalog counts/unique IDs, shop tier curve, frozen-offer reroll carryover, starting-contact references, and the modifier engine debug suite.

## Known Future Work

- Manual attachment target selection.
- More than one consumable slot through rewards/relics.
- Full shop discount reducers for `addShopDiscount` and `addRerollDiscount`.
- Boss relic offer pool beyond `Eye in the Sky`.
- Better visual comparison between held modifiers and shop copies.
