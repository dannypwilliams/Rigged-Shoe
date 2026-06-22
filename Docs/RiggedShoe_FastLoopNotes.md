# Rigged Shoe Fast Roguelite Loop Notes

Updated: 2026-06-22

This phase changes run progression from a long objective ladder into a compact battle loop while preserving baccarat betting and hand resolution.

## Current Loop

1. **Run Start**
   - The run assigns a neutral starting contact.
   - The contact step exists so future unlockable contacts can plug in without changing the table flow.

2. **Stage Preview**
   - Shows stage number, opponent, ante, fixed hand count, table rule, reward tier, and boss warning.
   - Boss stages are currently Stage 5, Stage 8, and Stage 10.

3. **Battle**
   - The player still chooses Player, Banker, or Tie.
   - The player still chooses bet amount.
   - Baccarat hand resolution and shoe manipulation remain unchanged.
   - Stages now resolve after fixed hand counts:
     - Stage 1: 5 hands
     - Stage 2: 6 hands
     - Stage 3: 7 hands
     - Stage 4: 8 hands
     - Stage 5: Boss 1, 8 hands
     - Stage 6: 8 hands
     - Stage 7: 9 hands
     - Stage 8: Boss 2, 10 hands
     - Stage 9: 10 hands
     - Stage 10: Final Boss, 12 hands

4. **Stage Result**
   - Shows win/loss, profit/loss, bankroll change, Heat change, Chips earned, and failure reason.
   - Bankruptcy and max Heat end the run after the result screen.

5. **Reward Draft**
   - The current stage reward choices are still used.
   - This is intentionally a bridge until modifiers and shop inventory replace the old reward pool.

6. **Shop Phase**
   - Minimal phase for now.
   - Shows run Chips, Heat, bankroll, and next stage.
   - Full buy/sell/reroll/attachment behavior should be implemented in the next phase.

7. **Next Stage**
   - The shop advances to the next stage preview.
   - Stage start effects and bet normalization run before preview.

8. **Run Complete / Run Failed**
   - Clearing Stage 10 completes the run.
   - Bankroll <= 0, Heat >= maxHeat, or future boss/stage conditions fail the run.

## New Live State

`RunManager` now owns:

- `flowState`
- run Chips
- Heat and max Heat
- stage-start Heat/Chips
- last stage result

`Stage` now provides:

- ante
- boss stage flag
- opponent name
- table rule summary
- reward tier
- stage clear Chips

## Intentionally Deferred

- Full shop purchases
- Modifier buy/sell/level/attach behavior
- Opponent scoring
- Strong Heat tuning
- Starting contact choices and effects
- Replacement of legacy upgrade reward pool with modifier drafts

The important part now is that the player has a clear, fast, repeatable rhythm:

**Preview -> short baccarat battle -> result -> reward -> shop -> next table.**
