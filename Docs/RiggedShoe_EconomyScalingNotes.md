# Rigged Shoe Economy Scaling Notes

This pass replaces arbitrary flat rewards with ante-scaled rewards.

## Stage Ante Table

- Stage 1: $25
- Stage 2: $50
- Stage 3: $75
- Stage 4: $100
- Stage 5 Boss: $150
- Stage 6: $200
- Stage 7: $300
- Stage 8 Boss: $400
- Stage 9: $600
- Stage 10 Final Boss: $800

## Bet Limits

- Minimum bet is the current stage ante.
- Maximum bet is the lesser of the stage max cap or 25% of current bankroll.
- Future modifiers can break or alter this cap intentionally, but base gameplay now prevents early all-in abuse.

## Reward Rules

- Normal stage clear cash is 1x to 2x ante.
- Boss clear cash is 3x to 5x ante.
- Stage clear Chips are 2 to 4.
- Boss clear Chips are 5 to 8.
- Cash grants are capped at 50% of current bankroll unless a future reward explicitly opts into risky uncapped behavior.

## Converted Content

- Stage rewards now use ante-scaled cash, Chips, or Heat relief.
- Vault Leak now grants a bounded boss payout plus Chips instead of a flat $25,000.
- Player/Banker win bonuses and major economy upgrades now use ante-scaled effects.
- Legacy flat cash effects are converted at runtime against the Stage 1 ante baseline, then capped by ante and bankroll.

## Debug Logging

Reward calculations print in DEBUG builds with:

- Stage number
- Ante
- Base cash
- Final cash
- Chips
- Cap applied
- Reason
