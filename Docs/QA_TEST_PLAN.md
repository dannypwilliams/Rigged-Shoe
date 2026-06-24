# QA Test Plan

## Core Matrix

- Clean install: choose all six Contacts, verify data and accessibility labels.
- Stage flow: Stage 1 to reward to shop to Stage 2.
- Boss flow: start at 5, 10, 15, 20, 25, 30 through debug menu and clear each.
- Final flow: Stage 30 clear reaches Casino Cleared; earlier stages never do.
- Persistence: background/resume during battle, stage result, reward draft, shop, boss announcement, and final summary.
- Rapid input: double Deal, double reward, double shop purchase, double continue.
- Layout: smallest supported iPhone, standard iPhone, larger text, long copy, high numbers.
- Accessibility: VoiceOver order, complete Heat value, disabled wager reasons, card rank/suit labels.

## Automated Coverage

- Baccarat resolution.
- Guided shoe depletion.
- Legal wager caps.
- Stage definition 1-30.
- Boss schedule.
- Stage 30 final clear.
- Reward idempotence.
- Full modifier capacity safety.
- Save/restore reward selection.

## Exit Gate

- No P0/P1 correctness issues.
- Build succeeds in beta/debug configuration.
- Unit tests pass.
- Visual clipping issues are either fixed or listed with severity and reproduction.
