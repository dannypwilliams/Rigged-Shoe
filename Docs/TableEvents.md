# Table Events

Table events add stage variety without replacing opponent battles.

## Model

Defined in `RiggedShoe/Models/OpponentModels.swift`.

Each `TableEvent` contains:

- ID.
- Name.
- Summary.
- Table rules.
- Optional bonus Chips on clear.

## Implemented Events

The current pool contains 16 events:

- No Commission Night.
- High Minimums.
- Tight Surveillance.
- Tie Promo.
- Cold Table.
- Private Table.
- Lucky Shoe.
- Bad Cut.
- Distracted Pit.
- Rich Crowd.
- Tourist Rush.
- Final Hand Spotlight.
- Natural Bonus Table.
- Pair Watch.
- Marker Desk.
- Cooler Shift.

## Rule Interpretation

Material rule hooks currently implemented include:

- Minimum bet changes.
- Maximum bet changes.
- Banker commission changes.
- Tie payout changes.
- Reward bonus Chips.

Other table events are currently represented as custom rules and summaries so UI, battle logs, and future engine passes can hook them safely without changing the model. The expansion events intentionally introduce Natural, Pair, Debt/Loan, and Streak-counter themes without adding a new stage system.

## Secondary Objectives

Secondary objectives are optional goals shown in the stage preview and checked at stage result.

Implemented objectives:

- Win without gaining Heat.
- End with profit.
- Trigger 3 effects.
- Win a Tie bet.
- Never bet above 25% bankroll.
- Win with at least 2 bet sides.
- Finish ahead by 2x ante.
- Win the final hand.
- Beat opponent without consumables.
- Recover after falling behind.

Reward is currently +1 Chip when complete.

## Verification

Tests verify:

- 16 table events exist.
- 10 secondary objectives exist.
- Stage preview includes the current table event and secondary objective.
