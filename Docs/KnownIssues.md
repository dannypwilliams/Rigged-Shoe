# Rigged Shoe Known Issues

Updated: 2026-06-22

## Balance

- Stage 4 is too easy in the latest 600-run headless simulation: 73.3% clear versus a 60-70% target.
- Stage 6 is slightly above target: 61.4% clear versus a 45-60% target.
- Stage 8 is still slightly too easy: 50.0% clear versus a 30-45% target, with 38 attempts.
- Stage 9 is still too easy: 47.4% clear versus a 20-35% target, with only 19 attempts.
- Final Boss is in target after the House repeated-side pressure fix: 22.2% clear versus a 10-25% target, with only 9 attempts.
- `banker.house-favorite` is the most picked and most triggered modifier in the latest report; it may be too universally attractive.
- `final.closer` was picked but did not trigger in the latest batch; final-hand trigger support may need a reducer/simulator pass.

## UX

- A fresh-install physical iOS Simulator tap-through completed Stage 1 through Reward Draft, but a full run through Boss 1 has not yet been completed after the latest content expansion.
- Starting contact selection was refit into a compact featured-contact picker plus horizontal contact rail. This needs fresh SE simulator verification.
- Modal flow overlays should hide inactive Game Room controls from the accessibility tree.
- Disabled shop Buy/Reroll buttons now use dimmed styling. This needs fresh physical verification in the shop phase.
- Shop pacing and touch targets still need fresh small-screen verification after the Stage 1 fixes.
- Boss warning clarity needs physical verification.
- Reward draft speed is readable for Stage 1 on SE, but later boss/relic reward drafts still need physical verification.

## Technical

- `Tools/Simulation/rigged_shoe_sim.py` is a compact mirror of the Swift model, not a shared Swift engine. It parses current modifier/contact catalogs but simplifies effect behavior.
- Attachment effects are wired through modifier resolution, but manual attachment target selection remains future work.
- Expanded content now reaches the requested catalog counts and is parsed by the headless simulation, but the newest branches are still only lightly exercised until another physical playthrough is completed.
- Some expanded modifier hooks use existing `custom` effects as battle-log-ready placeholders for future reducers rather than fully unique mechanics.

## Build / Test

- Build and unit test verification should be rerun after each balance or content patch.
- Latest simulator-backed unit test pass: `./Scripts/mac_test_simulator.sh` succeeded on 2026-06-22 after the contact-picker and disabled-shop-button fixes.
- Latest headless simulation pass: 600 runs with seed `20260622`, 19.92 MB peak RSS, written to `Docs/sim-post-contact-ui-fix-20260622.json`.
