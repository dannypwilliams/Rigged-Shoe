# Rigged Shoe Asset Roadmap

## Goal

Move the vertical slice from functional placeholder art to a readable crooked-casino identity without changing the core loop. Assets should make the player instantly understand three things: what table they are on, what kind of cheat/build they are running, and how much attention they are drawing.

## Priority 1: Core Table Readability

1. Card faces and backs
   - High-contrast baccarat card faces at iPhone SE size.
   - One branded card back for the shoe.
   - Optional marked-card variants for Card Reader effects.

2. Baccarat table and shoe
   - Crooked green felt table surface with clearer Player, Banker, and Tie zones.
   - Shoe prop with a readable remaining-card count plate.
   - Subtle burn-card tray or discard stack for future table effects.

3. Result and payout feedback
   - Result badges for Player, Banker, Tie, Push, and Heat Warning.
   - Ledger icons for bankroll gain/loss, chip gain/loss, and heat changes.
   - Small visual treatment for "Deal First Hand" vs ordinary "Deal".

## Priority 2: Heat System Fantasy

1. Heat meter
   - Three band treatments: Cool, Noticed, Heat Hot.
   - Distinct warning state when the Pit Boss penalty is near.
   - Small flame/chip hybrid icon that still reads at toolbar size.

2. Pit Boss pressure moments
   - Pit Boss Warning card art for the exposure penalty.
   - Short shake/flash treatment for Heat gain.
   - Cooling visual for rewards that reduce Heat.

3. Table event stickers
   - No Commission Night, Tourist Rush, and other table event stamps.
   - Designed as crooked casino paperwork rather than generic badges.

## Priority 3: Archetype Identity

1. Card Reader
   - Visual language: marked sleeves, bent corners, surveillance glints.
   - Reward card stamp color: cool blue or green.
   - Example assets: Bent Corner, Burn Watcher, Marked Sleeve.

2. Comp Scammer
   - Visual language: drink tickets, comp slips, loyalty cards, fake vouchers.
   - Reward card stamp color: gold.
   - Example assets: Comp Points, Loyalty Fraud, Chip Runner.

3. Heat Gambler
   - Visual language: red markers, pit boss eyes, blacklisted signs.
   - Reward card stamp color: red.
   - Example assets: All-In Alibi, Red Flag Bet, Cool Down.

## Priority 4: Characters And Places

1. Starting contacts
   - The Dealer's Nephew: nervous insider, table tell focus.
   - The Comp Queen: polished host/scammer, chip and comp economy focus.
   - The Red Marker: risky high-heat regular, pressure-for-value focus.

2. Opponents
   - Stage 1 Nervous Tourist: harmless but swingy.
   - Stage 2 Weekend Regular: banker-lean regular.
   - Later opponents can start as silhouettes with one strong prop each.

3. Rooms
   - Game Room: table-first, utilitarian.
   - Shop Phase: backroom counter, vouchers, chips.
   - Settings/Lounge: quieter casino support spaces.

## Priority 5: Audio And Motion

1. Audio cues
   - Card deal, chip payout, chip loss, Heat gain, Pit Boss warning, reward draft, shop purchase.

2. Motion
   - Short card flip/deal animation.
   - Heat pulse on gain.
   - Reward card select lift.
   - Keep all motion optional under Reduce Motion.

## Production Notes

- Target iPhone SE readability first, then scale up.
- Prefer vector/PDF for icons and stamps; use PNG at 2x/3x for painterly or textured pieces.
- Keep text out of art where possible so copy can remain in SwiftUI and stay accessible.
- Build assets in small replaceable groups: table kit, heat kit, archetype stamp kit, character portraits, then room backgrounds.
- The current vertical slice should keep using existing placeholder art until each asset group can be swapped in as a complete pass.
