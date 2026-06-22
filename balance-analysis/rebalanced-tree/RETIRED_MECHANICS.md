# Retired Mechanics Register

Date: 2026-06-22

The rebalanced production roster is owned by `ActiveModifierCatalog` and contains exactly 41 active IDs. The source records below remain in `Modifier.allContent` for archive, diagnostics, and save compatibility, but they are not eligible for starter selection, normal shops, random modifier drafts, production reward pools, or production simulator build generation.

## Consolidation Rules

| Retired family | Replacement path |
| --- | --- |
| Banker overflow | `banker.commission-dodge`, `banker.banker-anchor`, `banker.dealers-nod`, `banker.banco-press`, `banker.banker-lock` |
| Player overflow and counter | `player.side-step`, `player.punto-insurance`, `player.reversal-read`, `player.player-tempo`, `player.break-pattern` |
| Tie overflow | `tie.tie-whisperer`, `tie.mirror-bet`, `tie.split-signal`, `tie.equalizer`, `tie.tie-master` |
| Vision overflow | `core.opening-tell`, `vision.soft-peek`, `vision.deep-read`, `vision.pattern-memory`, `vision.tie-forecast`, `vision.third-card-forecast` |
| Shoe control and loaded-shoe overflow | `control.soft-cut`, `control.slipstream`, `loaded.add-nine`, `loaded.marked-nine`, `control.hot-cut` |
| Heat overflow | `core.clean-hands`, `heat.low-profile`, `heat.soft-footsteps`, `bet.press-edge`, `bet.high-roller`, `boss.house-crack` |
| Economy/debt overflow | `core.lucky-chip`, `economy.interest-ledger`, `economy.comp-points`, `debt.emergency-marker`, `debt.last-dollar`, `boss.boss-bounty` |
| Natural, pair, final-hand, sabotage | Retired until the effects have visible decisions and simulator-measurable value |

## Retired IDs

| Retired ID | Status | Replacement or reason |
| --- | --- | --- |
| `banker.backroom-banco` | Retired source retained | Banker Heat payout moved to `banker.banker-lock`. |
| `banker.banco-battery` | Retired source retained | Repeat ante cash removed from Banker tree. |
| `banker.house-favorite` | Retired source retained | First Banker win economy folded into active Banker/Economy pieces. |
| `banker.loyal-customer` | Retired source retained | Redundant first-win Banker payout retired. |
| `bet.careful-hands` | Retired source retained | Generic loss refund folded into `debt.last-dollar` and side insurance. |
| `bet.flat-better` | Retired source retained | Generic any-win bonus replaced by archetype-specific bonuses. |
| `bet.insurance-marker` | Retired source retained | Generic refunds replaced by side-specific insurance. |
| `bet.loss-limit` | Retired source retained | Large loss-limit pattern replaced by capped comeback tools. |
| `bet.overbet-permit` | Retired source retained | Bet-limit bending deferred until stronger UI support exists. |
| `bet.parlay-slip` | Retired source retained | Chip generation concentrated in starters and capstones. |
| `bet.safe-marker` | Retired source retained | Generic per-hand refund removed. |
| `bet.small-ball` | Retired source retained | Small-bet economy merged into `economy.comp-points`. |
| `boss.countermeasure` | Retired source retained | Boss ordinary shop family removed. |
| `boss.final-table-pass` | Retired source retained | Boss Heat relief moved to capstones/relics. |
| `boss.inside-job` | Retired source retained | Boss forecast moved to `vision.third-card-forecast`. |
| `control.burn-notice` | Retired source retained | Burn behavior folded into controlled, budgeted shoe-control tools. |
| `control.card-delay` | Retired source retained | Displacement merged into `control.soft-cut`. |
| `control.control-burn` | Retired source retained | Burn-heavy Heat line removed from active tree. |
| `control.dealer-slip` | Retired source retained | Explicitly merged into `control.soft-cut`. |
| `control.dealers-thumb` | Retired source retained | Boss-only displacement replaced by `control.hot-cut`. |
| `control.discard-favor` | Retired source retained | Burn plus cash loop removed. |
| `control.shoe-pocket` | Retired source retained | Card insertion merged into `loaded.add-nine`. |
| `counter.countertrend-plus` | Retired source retained | Counter family merged into `player.reversal-read`. |
| `counter.false-read` | Retired source retained | Loss reveal/refund overlap removed. |
| `counter.mirror-punish` | Retired source retained | Comeback cash merged into `debt.last-dollar`. |
| `counter.reverse-count` | Retired source retained | Log-only card draw hook retired. |
| `counter.turnaround-table` | Retired source retained | First win after loss chip burst removed. |
| `debt.credit-line` | Retired source retained | Debt boss cash compressed into `debt.emergency-marker`. |
| `debt.debt-collector` | Retired source retained | Debt as standalone family retired. |
| `debt.marker-chain` | Retired source retained | Buying-modifier rebate loop removed. |
| `economy.boss-bonus` | Retired source retained | Boss economy moved to `boss.boss-bounty`. |
| `economy.chip-stipend` | Retired source retained | Passive stage chip stipend removed. |
| `economy.coupon-book` | Retired source retained | Shop-discount effect deferred. |
| `economy.duplicate-finder` | Retired source retained | Duplicate-bias hook removed from active pool. |
| `economy.freeze-discount` | Retired source retained | Freeze/reroll economy deferred. |
| `economy.sellback` | Retired source retained | Sellback economy not part of the first 41. |
| `economy.shop-regular` | Retired source retained | Shop-entry discount removed from active tree. |
| `final.closer` | Retired source retained | Final-hand family retired for now. |
| `final.crown-hand` | Retired source retained | Final boss chip burst retired. |
| `final.house-breaker` | Retired source retained | Final-hand capstone replaced by archetype capstones. |
| `final.last-look` | Retired source retained | Final-hand forecast retired. |
| `final.redemption-hand` | Retired source retained | Final-hand refund retired. |
| `heat.backroom-pass` | Retired source retained | Boss Heat relief moved to `heat.low-profile`/capstones. |
| `heat.camera-blindspot` | Retired source retained | Strong Heat prevention retired. |
| `heat.cool-customer` | Retired source retained | Win-based Heat removal plus chips retired. |
| `heat.floor-distraction` | Retired source retained | Heat prevention folded into `heat.soft-footsteps`. |
| `heat.pit-boss-bribe` | Retired source retained | Opponent suppression not yet visible enough. |
| `heat.quiet-dealer` | Retired source retained | Shoe-control Heat softening retired. |
| `heat.surveillance-loop` | Retired source retained | Log-only boss suppression retired. |
| `loaded.eight-stack` | Retired source retained | Loaded-shoe family compressed to two regulars plus capstone. |
| `loaded.nine-engine` | Retired source retained | Legendary loaded-shoe engine replaced by `control.hot-cut`. |
| `loaded.nine-worship` | Retired source retained | Natural/loaded economy overlap retired. |
| `natural.natural-bonus` | Retired source retained | Natural family retired for this pass. |
| `natural.natural-comp` | Retired source retained | Natural family retired for this pass. |
| `natural.natural-read` | Retired source retained | Natural family retired for this pass. |
| `natural.perfect-nine` | Retired source retained | Natural family retired for this pass. |
| `natural.snap-nine` | Retired source retained | Natural family retired for this pass. |
| `pair.matchbook` | Retired source retained | Pair family retired for this pass. |
| `pair.pair-hunter` | Retired source retained | Pair family retired for this pass. |
| `pair.split-pocket` | Retired source retained | Pair family retired for this pass. |
| `pair.twin-engine` | Retired source retained | Pair family retired for this pass. |
| `pair.twin-signal` | Retired source retained | Pair family retired for this pass. |
| `player.countertrend` | Retired source retained | First Player win cash moved to active Player tempo/reversal. |
| `player.punto-strike` | Retired source retained | Ante burst removed. |
| `player.sharp-turn` | Retired source retained | Chip generation folded into `core.player-surge`. |
| `player.underdog-side` | Retired source retained | Player Heat payout moved to `player.break-pattern`. |
| `sabotage.cold-read` | Retired source retained | Sabotage family retired until visible opponent manipulation exists. |
| `sabotage.house-static` | Retired source retained | Sabotage/Heat overlap retired. |
| `sabotage.opponent-tax` | Retired source retained | Opponent score manipulation deferred. |
| `sabotage.table-chat` | Retired source retained | Log-only hand-start hook retired. |
| `sabotage.tempo-theft` | Retired source retained | Reroll/opponent hook retired. |
| `tie.dead-heat` | Retired source retained | Ante cash removed from Tie build. |
| `tie.final-hand-tie` | Retired source retained | Final-hand Tie insurance retired. |
| `tie.jackpot-discipline` | Retired source retained | Redundant Tie-loss refund retired. |
| `tie.longshot-ledger` | Retired source retained | Tie payout handled by `tie.equalizer` and `tie.tie-master`. |
| `vision.banker-forecast` | Retired source retained | Banker-specific forecast folded into active Vision/Banker pieces. |
| `vision.boss-scout` | Retired source retained | Boss forecast moved to capstone. |
| `vision.dealer-glance` | Retired source retained | Duplicate stage-start reveal retired. |
| `vision.face-down-count` | Retired source retained | Log-only card draw hook retired. |

