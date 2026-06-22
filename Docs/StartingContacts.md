# Rigged Shoe Starting Contacts

Updated: 2026-06-22

Starting contacts live in `RiggedShoe/Models/ShopModels.swift` as `StartingContact.allContacts`.

Contacts are the first Super Auto Pets-style identity choice in the rebuilt run. They choose an opening modifier, adjust starting pressure, and bias future shop offers.

## Current Contacts

The current pool contains 12 contacts.

### The Tourist

- Difficulty: Easy
- Identity: Beginner / Flexible
- Starts with: Lucky Chip
- Bias: Economy, Banker, Player
- Notes: Default contact. No bankroll or Heat penalty.

### The Accountant

- Difficulty: Easy
- Identity: Economy / Small Ball
- Starts with: Interest Ledger
- Bias: Economy, Bet Control
- Notes: Starts with extra Chips and keeps early max bets tighter at 70% of the normal cap.

### The Dealer

- Difficulty: Medium
- Identity: Shoe Vision / Natural Hunter
- Starts with: Opening Tell
- Bias: Shoe Vision, Natural
- Notes: Begins with less bankroll but immediate information.

### The Mechanic

- Difficulty: Medium
- Identity: Shoe Control / Loaded Shoe
- Starts with: Burn Notice
- Bias: Shoe Control, Card Sculpting
- Notes: Adds initial Heat, but the opening modifier now actually burns cards before deal through the modifier engine.

### The Grifter

- Difficulty: Medium
- Identity: Player Pivot / Counter Master
- Starts with: Side Step
- Bias: Player, Comeback
- Notes: Encourages taking Player-side shots and using reveal feedback after wins.

### The Ghost

- Difficulty: Medium
- Identity: Heat / Stealth
- Starts with: Clean Hands
- Bias: Heat, Opponent Sabotage
- Notes: Good for cheating-heavy builds because Heat prevention is now wired to Heat-producing modifier triggers. Immediate cash rewards are reduced to 80%, pushing the build toward stealth and survival.

### The Whale

- Difficulty: Hard
- Identity: High Roller / Comeback
- Starts with: High Roller
- Bias: Bet Control, Comeback
- Notes: More bankroll, more Heat risk.

### The Tie Chaser

- Difficulty: Hard
- Identity: Tie Hunter
- Starts with: Tie Insurance
- Bias: Tie, Comeback
- Notes: Lower bankroll and higher variance, but stronger Tie shop direction.

### The Naturalist

- Difficulty: Medium
- Identity: Natural Hunter
- Starts with: Natural Read and Natural Marker
- Bias: Natural, Shoe Vision
- Notes: Teaches that natural 8/9 results can become a build lane without guaranteeing wins.

### The Pair Spotter

- Difficulty: Medium
- Identity: Pair Hunter / Tie
- Starts with: Pair Hunter
- Bias: Pair, Tie, Economy
- Notes: Converts rare pair events into reads and resources.

### The Marker Broker

- Difficulty: Hard
- Identity: Debt / Comeback
- Starts with: Emergency Marker
- Bias: Economy, Comeback, Heat
- Notes: Starts with more bankroll and Heat pressure, making it a riskier comeback route.

### The Closer

- Difficulty: Medium
- Identity: Final Hand Specialist
- Starts with: Closer
- Bias: Streak, Boss, Bet Control
- Notes: Built for short battles where the final hand decides the table.

## Adding A Contact

1. Add a `StartingContact` entry to `allContacts`.
2. Use a single opening modifier unless the contact is intentionally advanced.
3. Keep bankroll and Heat adjustments small enough that Stage 1 remains playable.
4. Include `shopBiasTags`; the shop generator weights matching modifiers higher.
5. Update this document when the contact becomes player-facing.
