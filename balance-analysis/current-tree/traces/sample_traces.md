# Deterministic Trace Samples

These traces are compact examples generated from the same root seed as the aggregate study. They are diagnostic examples, not additional aggregate samples.

## representative / random / 1145657687388359458

- Completed: no; final stage: 4; failure: `stage_4_heat`.
- Ending bankroll: $562.5; heat: 10; hands: 26; build: `bet.high-roller|bet.small-ball|tie.jackpot-discipline|tie.tie-whisperer`.
- Rewards: Table Comp, Cool Down, High Table Cut.
- Modifiers picked: tie.tie-whisperer, bet.small-ball, tie.jackpot-discipline.

```text
start seed=1145657687388359458 policy=random contact=contact.whale bankroll_cents=32500 chips=3 heat=1
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=32500 heat=1 chips=3 boss=none active_mods=bet.high-roller
hand stage=1 hand=1 bet=player bet_cents=2500 winner=banker player_total=1 banker_total=8 natural=true return_cents=0 bankroll_cents=30000 heat=1 opponent_profit_cents=2375 reveal_count=0
hand stage=1 hand=2 bet=tie bet_cents=2500 winner=player player_total=6 banker_total=2 natural=false return_cents=0 bankroll_cents=27500 heat=1 opponent_profit_cents=-125 reveal_count=0
hand stage=1 hand=3 bet=tie bet_cents=2500 winner=banker player_total=2 banker_total=7 natural=false return_cents=0 bankroll_cents=25000 heat=1 opponent_profit_cents=-2625 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=player player_total=7 banker_total=4 natural=false return_cents=0 bankroll_cents=22500 heat=1 opponent_profit_cents=-5125 reveal_count=0
hand stage=1 hand=5 bet=tie bet_cents=2500 winner=banker player_total=8 banker_total=9 natural=true return_cents=0 bankroll_cents=20000 heat=1 opponent_profit_cents=-10125 reveal_count=0
stage_result stage=1 clear=true profit_cents=-12500 opponent_profit_cents=-10125 tolerance_cents=22500 bankroll_cents=20000 heat=2 chips=5
stage_reward_rewards=Table Comp
shop_modifiers=tie.tie-whisperer
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=23750 heat=2 chips=2 boss=none active_mods=bet.high-roller;tie.tie-whisperer
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=banker player_total=0 banker_total=6 natural=false return_cents=10000 bankroll_cents=29750 heat=3 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=2 bet=player bet_cents=5000 winner=player player_total=9 banker_total=3 natural=true return_cents=10000 bankroll_cents=35750 heat=4 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=3 bet=tie bet_cents=5000 winner=player player_total=8 banker_total=7 natural=false return_cents=0 bankroll_cents=30750 heat=4 opponent_profit_cents=-5000 reveal_count=1
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=player player_total=6 banker_total=2 natural=false return_cents=0 bankroll_cents=25750 heat=4 opponent_profit_cents=-10000 reveal_count=1
hand stage=2 hand=5 bet=tie bet_cents=5000 winner=banker player_total=2 banker_total=6 natural=false return_cents=0 bankroll_cents=20750 heat=4 opponent_profit_cents=-20000 reveal_count=1
hand stage=2 hand=6 bet=player bet_cents=5000 winner=player player_total=9 banker_total=8 natural=true return_cents=10000 bankroll_cents=26750 heat=5 opponent_profit_cents=-25000 reveal_count=1
stage_result stage=2 clear=true profit_cents=3000 opponent_profit_cents=-25000 tolerance_cents=15000 bankroll_cents=26750 heat=5 chips=5
stage_reward_rewards=Cool Down
shop_modifiers=bet.small-ball
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=26750 heat=3 chips=2 boss=none active_mods=bet.high-roller;tie.tie-whisperer;bet.small-ball
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=player player_total=8 banker_total=2 natural=true return_cents=0 bankroll_cents=19250 heat=3 opponent_profit_cents=-7500 reveal_count=0
hand stage=3 hand=2 bet=tie bet_cents=7500 winner=player player_total=5 banker_total=4 natural=false return_cents=0 bankroll_cents=11750 heat=3 opponent_profit_cents=0 reveal_count=1
hand stage=3 hand=3 bet=player bet_cents=7500 winner=player player_total=9 banker_total=4 natural=true return_cents=15000 bankroll_cents=22625 heat=4 opponent_profit_cents=-7500 reveal_count=1
hand stage=3 hand=4 bet=player bet_cents=7500 winner=player player_total=8 banker_total=5 natural=false return_cents=15000 bankroll_cents=33500 heat=5 opponent_profit_cents=-15000 reveal_count=1
hand stage=3 hand=5 bet=player bet_cents=7500 winner=player player_total=9 banker_total=6 natural=true return_cents=15000 bankroll_cents=44375 heat=6 opponent_profit_cents=-22500 reveal_count=1
hand stage=3 hand=6 bet=player bet_cents=7500 winner=player player_total=9 banker_total=4 natural=true return_cents=15000 bankroll_cents=55250 heat=7 opponent_profit_cents=-15000 reveal_count=1
hand stage=3 hand=7 bet=tie bet_cents=7500 winner=player player_total=7 banker_total=2 natural=false return_cents=0 bankroll_cents=47750 heat=7 opponent_profit_cents=-22500 reveal_count=1
stage_result stage=3 clear=true profit_cents=21000 opponent_profit_cents=-22500 tolerance_cents=15000 bankroll_cents=47750 heat=7 chips=5
stage_reward_rewards=High Table Cut
shop_modifiers=tie.jackpot-discipline
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=62750 heat=7 chips=1 boss=none active_mods=bet.high-roller;tie.tie-whisperer;bet.small-ball;tie.jackpot-discipline
hand stage=4 hand=1 bet=tie bet_cents=10000 winner=player player_total=6 banker_total=4 natural=false return_cents=0 bankroll_cents=52750 heat=7 opponent_profit_cents=-20000 reveal_count=1
hand stage=4 hand=2 bet=player bet_cents=10000 winner=player player_total=8 banker_total=4 natural=true return_cents=20000 bankroll_cents=67250 heat=8 opponent_profit_cents=-40000 reveal_count=1
hand stage=4 hand=3 bet=banker bet_cents=10000 winner=player player_total=8 banker_total=0 natural=true return_cents=0 bankroll_cents=57250 heat=8 opponent_profit_cents=-60000 reveal_count=1
hand stage=4 hand=4 bet=tie bet_cents=10000 winner=player player_total=4 banker_total=3 natural=false return_cents=0 bankroll_cents=47250 heat=8 opponent_profit_cents=-70000 reveal_count=1
hand stage=4 hand=5 bet=player bet_cents=10000 winner=banker player_total=2 banker_total=8 natural=true return_cents=0 bankroll_cents=37250 heat=8 opponent_profit_cents=-51000 reveal_count=1
hand stage=4 hand=6 bet=tie bet_cents=10000 winner=player player_total=8 banker_total=1 natural=false return_cents=0 bankroll_cents=27250 heat=8 opponent_profit_cents=-71000 reveal_count=1
hand stage=4 hand=7 bet=player bet_cents=10000 winner=player player_total=8 banker_total=7 natural=false return_cents=20000 bankroll_cents=41750 heat=9 opponent_profit_cents=-91000 reveal_count=1
hand stage=4 hand=8 bet=player bet_cents=10000 winner=player player_total=7 banker_total=6 natural=false return_cents=20000 bankroll_cents=56250 heat=10 opponent_profit_cents=-101000 reveal_count=1
stage_result stage=4 clear=false profit_cents=-6500 opponent_profit_cents=-101000 tolerance_cents=5000 bankroll_cents=56250 heat=10 chips=1
finish completed=false final_stage=4 failure=stage_4_heat ending_bankroll_cents=56250 highest_bankroll_cents=67250 heat=10 owned_mods=bet.high-roller;tie.tie-whisperer;bet.small-ball;tie.jackpot-discipline
```

## representative / novice / 16179982617195473639

- Completed: no; final stage: 5; failure: `stage_5_opponent_loss`.
- Ending bankroll: $867.5; heat: 2; hands: 34; build: `bet.small-ball|core.opening-tell|debt.last-dollar|economy.coupon-book|economy.interest-ledger`.
- Rewards: Rare Modifier Voucher, High Table Cut, Modifier Voucher, Modifier Voucher.
- Modifiers picked: bet.small-ball, debt.last-dollar, control.discard-favor.

```text
start seed=16179982617195473639 policy=novice contact=contact.accountant bankroll_cents=25000 chips=5 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25875 heat=0 chips=5 boss=none active_mods=economy.interest-ledger
hand stage=1 hand=1 bet=banker bet_cents=2500 winner=player player_total=4 banker_total=0 natural=false return_cents=0 bankroll_cents=23375 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=2500 winner=banker player_total=3 banker_total=9 natural=false return_cents=4875 bankroll_cents=25750 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=banker player_total=4 banker_total=6 natural=false return_cents=4875 bankroll_cents=28125 heat=0 opponent_profit_cents=-7500 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=banker player_total=2 banker_total=8 natural=true return_cents=4875 bankroll_cents=30500 heat=0 opponent_profit_cents=-5125 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=banker player_total=6 banker_total=7 natural=false return_cents=4875 bankroll_cents=32875 heat=0 opponent_profit_cents=-10125 reveal_count=0
stage_result stage=1 clear=true profit_cents=7875 opponent_profit_cents=-10125 tolerance_cents=22500 bankroll_cents=32875 heat=0 chips=8
stage_reward_rewards=Rare Modifier Voucher
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=34625 heat=0 chips=8 boss=none active_mods=economy.interest-ledger;core.opening-tell
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=7 natural=false return_cents=10000 bankroll_cents=39625 heat=0 opponent_profit_cents=5000 reveal_count=3
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=7 natural=true return_cents=0 bankroll_cents=34625 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=banker player_total=5 banker_total=9 natural=true return_cents=10000 bankroll_cents=39625 heat=0 opponent_profit_cents=5000 reveal_count=3
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=player player_total=7 banker_total=2 natural=false return_cents=0 bankroll_cents=34625 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=29625 heat=0 opponent_profit_cents=10000 reveal_count=3
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=banker player_total=3 banker_total=6 natural=false return_cents=10000 bankroll_cents=34625 heat=0 opponent_profit_cents=15000 reveal_count=3
stage_result stage=2 clear=true profit_cents=1750 opponent_profit_cents=15000 tolerance_cents=15000 bankroll_cents=34625 heat=0 chips=11
stage_reward_rewards=High Table Cut
shop_modifiers=bet.small-ball
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=47250 heat=0 chips=8 boss=none active_mods=economy.interest-ledger;core.opening-tell;bet.small-ball
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=39750 heat=0 opponent_profit_cents=-7500 reveal_count=3
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=banker player_total=1 banker_total=2 natural=false return_cents=14625 bankroll_cents=48750 heat=0 opponent_profit_cents=-15000 reveal_count=3
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=8 natural=true return_cents=14625 bankroll_cents=57750 heat=0 opponent_profit_cents=-7875 reveal_count=3
hand stage=3 hand=4 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=9 natural=false return_cents=14625 bankroll_cents=66750 heat=0 opponent_profit_cents=-750 reveal_count=3
hand stage=3 hand=5 bet=banker bet_cents=7500 winner=player player_total=9 banker_total=0 natural=false return_cents=0 bankroll_cents=59250 heat=0 opponent_profit_cents=-8250 reveal_count=3
hand stage=3 hand=6 bet=banker bet_cents=7500 winner=banker player_total=3 banker_total=7 natural=false return_cents=14625 bankroll_cents=68250 heat=0 opponent_profit_cents=-15750 reveal_count=3
hand stage=3 hand=7 bet=banker bet_cents=7500 winner=banker player_total=7 banker_total=9 natural=true return_cents=14625 bankroll_cents=77250 heat=0 opponent_profit_cents=-8625 reveal_count=3
stage_result stage=3 clear=true profit_cents=32625 opponent_profit_cents=-8625 tolerance_cents=15000 bankroll_cents=77250 heat=0 chips=11
stage_reward_rewards=Modifier Voucher
shop_modifiers=debt.last-dollar
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=83250 heat=0 chips=7 boss=none active_mods=economy.interest-ledger;core.opening-tell;bet.small-ball;debt.last-dollar
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=player player_total=6 banker_total=3 natural=false return_cents=0 bankroll_cents=76250 heat=0 opponent_profit_cents=-20000 reveal_count=3
hand stage=4 hand=2 bet=banker bet_cents=10000 winner=banker player_total=1 banker_total=7 natural=false return_cents=19500 bankroll_cents=88250 heat=0 opponent_profit_cents=-1000 reveal_count=3
hand stage=4 hand=3 bet=banker bet_cents=10000 winner=player player_total=8 banker_total=5 natural=true return_cents=0 bankroll_cents=78250 heat=0 opponent_profit_cents=-21000 reveal_count=3
hand stage=4 hand=4 bet=banker bet_cents=10000 winner=banker player_total=8 banker_total=9 natural=true return_cents=19500 bankroll_cents=90250 heat=0 opponent_profit_cents=-31000 reveal_count=3
hand stage=4 hand=5 bet=banker bet_cents=10000 winner=player player_total=8 banker_total=3 natural=true return_cents=0 bankroll_cents=80250 heat=0 opponent_profit_cents=-51000 reveal_count=3
hand stage=4 hand=6 bet=banker bet_cents=10000 winner=banker player_total=5 banker_total=8 natural=true return_cents=19500 bankroll_cents=92250 heat=0 opponent_profit_cents=-32000 reveal_count=3
hand stage=4 hand=7 bet=banker bet_cents=10000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=82250 heat=0 opponent_profit_cents=-52000 reveal_count=3
hand stage=4 hand=8 bet=banker bet_cents=10000 winner=banker player_total=4 banker_total=6 natural=false return_cents=19500 bankroll_cents=94250 heat=0 opponent_profit_cents=-62000 reveal_count=3
stage_result stage=4 clear=true profit_cents=17000 opponent_profit_cents=-62000 tolerance_cents=5000 bankroll_cents=94250 heat=0 chips=11
stage_reward_rewards=Modifier Voucher
shop_modifiers=control.discard-favor
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=103250 heat=0 chips=7 boss=Pit Boss active_mods=economy.interest-ledger;core.opening-tell;bet.small-ball;debt.last-dollar;economy.coupon-book
hand stage=5 hand=1 bet=banker bet_cents=15000 winner=banker player_total=1 banker_total=6 natural=false return_cents=29250 bankroll_cents=121250 heat=0 opponent_profit_cents=14250 reveal_count=3
hand stage=5 hand=2 bet=banker bet_cents=15000 winner=player player_total=9 banker_total=4 natural=false return_cents=0 bankroll_cents=110750 heat=0 opponent_profit_cents=-750 reveal_count=3
hand stage=5 hand=3 bet=banker bet_cents=15000 winner=banker player_total=0 banker_total=9 natural=true return_cents=29250 bankroll_cents=128750 heat=0 opponent_profit_cents=-12750 reveal_count=3
hand stage=5 hand=4 bet=banker bet_cents=15000 winner=banker player_total=1 banker_total=4 natural=false return_cents=29250 bankroll_cents=146750 heat=1 opponent_profit_cents=4500 reveal_count=3
hand stage=5 hand=5 bet=banker bet_cents=15000 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=131750 heat=1 opponent_profit_cents=-22500 reveal_count=3
hand stage=5 hand=6 bet=banker bet_cents=15000 winner=player player_total=9 banker_total=4 natural=false return_cents=0 bankroll_cents=116750 heat=1 opponent_profit_cents=-4500 reveal_count=3
hand stage=5 hand=7 bet=banker bet_cents=15000 winner=player player_total=8 banker_total=7 natural=false return_cents=0 bankroll_cents=101750 heat=1 opponent_profit_cents=13500 reveal_count=3
hand stage=5 hand=8 bet=banker bet_cents=15000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=86750 heat=2 opponent_profit_cents=31500 reveal_count=3
stage_result stage=5 clear=false profit_cents=-7500 opponent_profit_cents=31500 tolerance_cents=0 bankroll_cents=86750 heat=2 chips=8
finish completed=false final_stage=5 failure=stage_5_opponent_loss ending_bankroll_cents=86750 highest_bankroll_cents=146750 heat=2 owned_mods=economy.interest-ledger;core.opening-tell;bet.small-ball;debt.last-dollar;economy.coupon-book
```

## representative / greedy / 3565109935037220113

- Completed: no; final stage: 5; failure: `stage_5_heat`.
- Ending bankroll: $6,978.75; heat: 10; hands: 31; build: `bet.high-roller|bet.small-ball|core.clean-hands|natural.natural-bonus|player.player-tempo`.
- Rewards: Modifier Voucher, Cool Down, Modifier Voucher, Cool Down.
- Modifiers picked: core.clean-hands, player.player-tempo, bet.small-ball.

```text
start seed=3565109935037220113 policy=greedy contact=contact.whale bankroll_cents=32500 chips=3 heat=1
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=32500 heat=1 chips=3 boss=none active_mods=bet.high-roller
hand stage=1 hand=1 bet=banker bet_cents=7500 winner=banker player_total=1 banker_total=7 natural=false return_cents=14625 bankroll_cents=41125 heat=2 opponent_profit_cents=2375 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=10000 winner=player player_total=8 banker_total=2 natural=false return_cents=0 bankroll_cents=31125 heat=2 opponent_profit_cents=-125 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=7500 winner=player player_total=8 banker_total=3 natural=true return_cents=0 bankroll_cents=23625 heat=2 opponent_profit_cents=2375 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=5000 winner=banker player_total=6 banker_total=7 natural=false return_cents=9750 bankroll_cents=29375 heat=3 opponent_profit_cents=4750 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=5000 winner=player player_total=1 banker_total=0 natural=false return_cents=0 bankroll_cents=24375 heat=3 opponent_profit_cents=-250 reveal_count=0
stage_result stage=1 clear=true profit_cents=-8125 opponent_profit_cents=-250 tolerance_cents=22500 bankroll_cents=24375 heat=4 chips=5
stage_reward_rewards=Modifier Voucher
shop_modifiers=core.clean-hands
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=24375 heat=4 chips=2 boss=none active_mods=bet.high-roller;bet.small-ball;core.clean-hands
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=banker player_total=1 banker_total=5 natural=false return_cents=10000 bankroll_cents=31625 heat=4 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=tie player_total=8 banker_total=8 natural=true return_cents=5000 bankroll_cents=31625 heat=4 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=6 natural=true return_cents=0 bankroll_cents=26625 heat=4 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=8 banker_total=9 natural=true return_cents=10000 bankroll_cents=33875 heat=5 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=tie player_total=1 banker_total=1 natural=false return_cents=5000 bankroll_cents=33875 heat=5 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=28875 heat=5 opponent_profit_cents=0 reveal_count=0
stage_result stage=2 clear=true profit_cents=4500 opponent_profit_cents=0 tolerance_cents=15000 bankroll_cents=28875 heat=5 chips=5
stage_reward_rewards=Cool Down
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=28875 heat=3 chips=5 boss=none active_mods=bet.high-roller;bet.small-ball;core.clean-hands
hand stage=3 hand=1 bet=tie bet_cents=7500 winner=tie player_total=8 banker_total=8 natural=true return_cents=82500 bankroll_cents=107250 heat=3 opponent_profit_cents=0 reveal_count=0
hand stage=3 hand=2 bet=tie bet_cents=25000 winner=banker player_total=0 banker_total=7 natural=false return_cents=0 bankroll_cents=82250 heat=3 opponent_profit_cents=-7500 reveal_count=0
hand stage=3 hand=3 bet=tie bet_cents=15000 winner=tie player_total=9 banker_total=9 natural=true return_cents=165000 bankroll_cents=237125 heat=4 opponent_profit_cents=-7500 reveal_count=0
hand stage=3 hand=4 bet=tie bet_cents=25000 winner=player player_total=5 banker_total=3 natural=false return_cents=0 bankroll_cents=212125 heat=4 opponent_profit_cents=-15000 reveal_count=0
hand stage=3 hand=5 bet=tie bet_cents=25000 winner=tie player_total=1 banker_total=1 natural=false return_cents=275000 bankroll_cents=469000 heat=5 opponent_profit_cents=-15000 reveal_count=0
hand stage=3 hand=6 bet=tie bet_cents=25000 winner=tie player_total=5 banker_total=5 natural=false return_cents=275000 bankroll_cents=725875 heat=6 opponent_profit_cents=-15000 reveal_count=0
hand stage=3 hand=7 bet=tie bet_cents=25000 winner=banker player_total=6 banker_total=8 natural=false return_cents=0 bankroll_cents=700875 heat=6 opponent_profit_cents=-7875 reveal_count=0
stage_result stage=3 clear=true profit_cents=672000 opponent_profit_cents=-7875 tolerance_cents=15000 bankroll_cents=700875 heat=6 chips=8
stage_reward_rewards=Modifier Voucher
shop_modifiers=player.player-tempo
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=700875 heat=6 chips=4 boss=none active_mods=bet.high-roller;bet.small-ball;core.clean-hands;natural.natural-bonus;player.player-tempo
hand stage=4 hand=1 bet=banker bet_cents=40000 winner=banker player_total=2 banker_total=5 natural=false return_cents=78000 bankroll_cents=749375 heat=6 opponent_profit_cents=19000 reveal_count=0
hand stage=4 hand=2 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=2 natural=false return_cents=0 bankroll_cents=709375 heat=6 opponent_profit_cents=-1000 reveal_count=0
hand stage=4 hand=3 bet=banker bet_cents=40000 winner=tie player_total=4 banker_total=4 natural=false return_cents=40000 bankroll_cents=709375 heat=6 opponent_profit_cents=-1000 reveal_count=0
hand stage=4 hand=4 bet=banker bet_cents=40000 winner=player player_total=8 banker_total=6 natural=true return_cents=0 bankroll_cents=669375 heat=6 opponent_profit_cents=-11000 reveal_count=0
hand stage=4 hand=5 bet=banker bet_cents=40000 winner=tie player_total=6 banker_total=6 natural=false return_cents=40000 bankroll_cents=669375 heat=6 opponent_profit_cents=-11000 reveal_count=0
hand stage=4 hand=6 bet=banker bet_cents=40000 winner=banker player_total=4 banker_total=6 natural=false return_cents=78000 bankroll_cents=717875 heat=7 opponent_profit_cents=8000 reveal_count=0
hand stage=4 hand=7 bet=banker bet_cents=40000 winner=banker player_total=3 banker_total=8 natural=true return_cents=78000 bankroll_cents=766375 heat=8 opponent_profit_cents=27000 reveal_count=0
hand stage=4 hand=8 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=726375 heat=8 opponent_profit_cents=17000 reveal_count=0
stage_result stage=4 clear=true profit_cents=25500 opponent_profit_cents=17000 tolerance_cents=5000 bankroll_cents=726375 heat=8 chips=7
stage_reward_rewards=Cool Down
shop_modifiers=bet.small-ball
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=726375 heat=6 chips=4 boss=Pit Boss active_mods=bet.high-roller;bet.small-ball;core.clean-hands;natural.natural-bonus;player.player-tempo
hand stage=5 hand=1 bet=banker bet_cents=60000 winner=banker player_total=1 banker_total=8 natural=true return_cents=117000 bankroll_cents=802125 heat=7 opponent_profit_cents=-15000 reveal_count=0
hand stage=5 hand=2 bet=banker bet_cents=60000 winner=player player_total=8 banker_total=2 natural=true return_cents=0 bankroll_cents=742125 heat=7 opponent_profit_cents=-30000 reveal_count=0
hand stage=5 hand=3 bet=banker bet_cents=60000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=682125 heat=7 opponent_profit_cents=-12000 reveal_count=0
hand stage=5 hand=4 bet=banker bet_cents=60000 winner=player player_total=9 banker_total=3 natural=false return_cents=0 bankroll_cents=622125 heat=8 opponent_profit_cents=6000 reveal_count=0
hand stage=5 hand=5 bet=banker bet_cents=60000 winner=banker player_total=7 banker_total=9 natural=false return_cents=117000 bankroll_cents=697875 heat=10 opponent_profit_cents=-21000 reveal_count=0
stage_result stage=5 clear=false profit_cents=-28500 opponent_profit_cents=-21000 tolerance_cents=0 bankroll_cents=697875 heat=10 chips=4
finish completed=false final_stage=5 failure=stage_5_heat ending_bankroll_cents=697875 highest_bankroll_cents=802125 heat=10 owned_mods=bet.high-roller;bet.small-ball;core.clean-hands;natural.natural-bonus;player.player-tempo
```

## representative / risk_aware / 14021648824970372475

- Completed: no; final stage: 4; failure: `stage_4_opponent_loss`.
- Ending bankroll: $607.5; heat: 0; hands: 26; build: `core.clean-hands|core.opening-tell|final.closer`.
- Rewards: Cool Down, Rare Modifier Voucher, Cool Down.
- Modifiers picked: core.clean-hands, core.clean-hands, final.closer.

```text
start seed=14021648824970372475 policy=risk_aware contact=contact.ghost bankroll_cents=25000 chips=3 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25000 heat=0 chips=3 boss=none active_mods=core.clean-hands
hand stage=1 hand=1 bet=banker bet_cents=5000 winner=player player_total=6 banker_total=5 natural=false return_cents=0 bankroll_cents=20000 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=5 natural=true return_cents=0 bankroll_cents=15000 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=12500 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=banker player_total=4 banker_total=8 natural=true return_cents=4875 bankroll_cents=14875 heat=0 opponent_profit_cents=-125 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=banker player_total=1 banker_total=2 natural=false return_cents=4875 bankroll_cents=17250 heat=0 opponent_profit_cents=-5125 reveal_count=0
stage_result stage=1 clear=true profit_cents=-7750 opponent_profit_cents=-5125 tolerance_cents=22500 bankroll_cents=17250 heat=1 chips=5
stage_reward_rewards=Cool Down
shop_modifiers=core.clean-hands
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=17250 heat=0 chips=2 boss=none active_mods=core.clean-hands
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=player player_total=4 banker_total=1 natural=false return_cents=0 bankroll_cents=12250 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=player player_total=5 banker_total=2 natural=false return_cents=0 bankroll_cents=7250 heat=0 opponent_profit_cents=-10000 reveal_count=0
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=banker player_total=0 banker_total=3 natural=false return_cents=10000 bankroll_cents=12250 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=8 banker_total=9 natural=true return_cents=10000 bankroll_cents=17250 heat=0 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=banker player_total=2 banker_total=6 natural=false return_cents=10000 bankroll_cents=22250 heat=0 opponent_profit_cents=-10000 reveal_count=0
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=17250 heat=0 opponent_profit_cents=-15000 reveal_count=0
stage_result stage=2 clear=true profit_cents=0 opponent_profit_cents=-15000 tolerance_cents=15000 bankroll_cents=17250 heat=0 chips=4
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=core.clean-hands
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=17250 heat=0 chips=1 boss=none active_mods=core.clean-hands;core.opening-tell
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=banker player_total=1 banker_total=8 natural=true return_cents=14625 bankroll_cents=24375 heat=0 opponent_profit_cents=7125 reveal_count=3
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=banker player_total=1 banker_total=8 natural=true return_cents=14625 bankroll_cents=31500 heat=0 opponent_profit_cents=-375 reveal_count=3
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=player player_total=9 banker_total=3 natural=true return_cents=0 bankroll_cents=24000 heat=0 opponent_profit_cents=-7875 reveal_count=3
hand stage=3 hand=4 bet=banker bet_cents=7500 winner=banker player_total=7 banker_total=8 natural=true return_cents=14625 bankroll_cents=31125 heat=0 opponent_profit_cents=-750 reveal_count=3
hand stage=3 hand=5 bet=banker bet_cents=7500 winner=banker player_total=5 banker_total=9 natural=true return_cents=14625 bankroll_cents=38250 heat=0 opponent_profit_cents=6375 reveal_count=3
hand stage=3 hand=6 bet=banker bet_cents=7500 winner=player player_total=8 banker_total=5 natural=false return_cents=0 bankroll_cents=30750 heat=0 opponent_profit_cents=13875 reveal_count=3
hand stage=3 hand=7 bet=banker bet_cents=7500 winner=player player_total=9 banker_total=4 natural=false return_cents=0 bankroll_cents=23250 heat=0 opponent_profit_cents=6375 reveal_count=3
stage_result stage=3 clear=true profit_cents=6000 opponent_profit_cents=6375 tolerance_cents=15000 bankroll_cents=23250 heat=0 chips=3
stage_reward_rewards=Cool Down
shop_modifiers=final.closer
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=23250 heat=0 chips=0 boss=none active_mods=core.clean-hands;core.opening-tell;final.closer
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=tie player_total=5 banker_total=5 natural=false return_cents=10000 bankroll_cents=23250 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=4 hand=2 bet=banker bet_cents=10000 winner=tie player_total=5 banker_total=5 natural=false return_cents=10000 bankroll_cents=23250 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=4 hand=3 bet=banker bet_cents=10000 winner=banker player_total=0 banker_total=6 natural=false return_cents=19500 bankroll_cents=32750 heat=0 opponent_profit_cents=19000 reveal_count=3
hand stage=4 hand=4 bet=banker bet_cents=10000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=22750 heat=0 opponent_profit_cents=9000 reveal_count=3
hand stage=4 hand=5 bet=banker bet_cents=10000 winner=banker player_total=1 banker_total=8 natural=true return_cents=19500 bankroll_cents=32250 heat=0 opponent_profit_cents=28000 reveal_count=3
hand stage=4 hand=6 bet=banker bet_cents=10000 winner=banker player_total=6 banker_total=7 natural=false return_cents=19500 bankroll_cents=41750 heat=0 opponent_profit_cents=47000 reveal_count=3
hand stage=4 hand=7 bet=banker bet_cents=10000 winner=banker player_total=1 banker_total=8 natural=true return_cents=19500 bankroll_cents=51250 heat=0 opponent_profit_cents=66000 reveal_count=3
hand stage=4 hand=8 bet=banker bet_cents=10000 winner=banker player_total=2 banker_total=7 natural=false return_cents=19500 bankroll_cents=60750 heat=0 opponent_profit_cents=56000 reveal_count=3
stage_result stage=4 clear=false profit_cents=37500 opponent_profit_cents=56000 tolerance_cents=5000 bankroll_cents=60750 heat=0 chips=0
finish completed=false final_stage=4 failure=stage_4_opponent_loss ending_bankroll_cents=60750 highest_bankroll_cents=60750 heat=0 owned_mods=core.clean-hands;core.opening-tell;final.closer
```

## representative / optimized / 6875500689133562470

- Completed: no; final stage: 10; failure: `stage_10_heat`.
- Ending bankroll: $83,097.5; heat: 10; hands: 72; build: `core.opening-tell|counter.false-read|player.side-step|tie.tie-whisperer|vision.soft-peek`.
- Rewards: Ante Kickback, Rare Modifier Voucher, Chip Runner, Rare Modifier Voucher, Echo Chamber, Modifier Voucher, Attachment Case, Echo Chamber, Table Comp.
- Modifiers picked: counter.false-read, player.side-step, tie.tie-whisperer, vision.soft-peek, natural.natural-read, tie.tie-whisperer, player.side-step, tie.equalizer.

```text
start seed=6875500689133562470 policy=optimized contact=contact.dealer bankroll_cents=22500 chips=3 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=22500 heat=0 chips=3 boss=none active_mods=core.opening-tell
hand stage=1 hand=1 bet=banker bet_cents=5000 winner=tie player_total=9 banker_total=9 natural=true return_cents=5000 bankroll_cents=22500 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=1 hand=2 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=7 natural=false return_cents=9750 bankroll_cents=27250 heat=0 opponent_profit_cents=-2500 reveal_count=3
hand stage=1 hand=3 bet=banker bet_cents=5000 winner=banker player_total=6 banker_total=8 natural=false return_cents=9750 bankroll_cents=32000 heat=0 opponent_profit_cents=-5000 reveal_count=3
hand stage=1 hand=4 bet=banker bet_cents=5000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=27000 heat=0 opponent_profit_cents=-7500 reveal_count=3
hand stage=1 hand=5 bet=banker bet_cents=5000 winner=banker player_total=5 banker_total=6 natural=false return_cents=9750 bankroll_cents=31750 heat=0 opponent_profit_cents=-12500 reveal_count=3
stage_result stage=1 clear=true profit_cents=9250 opponent_profit_cents=-12500 tolerance_cents=22500 bankroll_cents=31750 heat=0 chips=6
stage_reward_rewards=Ante Kickback
shop_modifiers=counter.false-read
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=34250 heat=0 chips=2 boss=none active_mods=core.opening-tell;counter.false-read
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=29750 heat=0 opponent_profit_cents=-5000 reveal_count=3
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=8 natural=true return_cents=10000 bankroll_cents=34750 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=0 natural=true return_cents=0 bankroll_cents=30250 heat=0 opponent_profit_cents=-5000 reveal_count=3
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=2 banker_total=5 natural=false return_cents=10000 bankroll_cents=35250 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=3 natural=true return_cents=0 bankroll_cents=30750 heat=0 opponent_profit_cents=10000 reveal_count=3
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=banker player_total=0 banker_total=2 natural=false return_cents=10000 bankroll_cents=35750 heat=0 opponent_profit_cents=15000 reveal_count=3
stage_result stage=2 clear=true profit_cents=1500 opponent_profit_cents=15000 tolerance_cents=15000 bankroll_cents=35750 heat=0 chips=5
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=player.side-step
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=35750 heat=0 chips=2 boss=none active_mods=core.opening-tell;counter.false-read;player.side-step
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=banker player_total=2 banker_total=4 natural=false return_cents=14625 bankroll_cents=42875 heat=0 opponent_profit_cents=7125 reveal_count=4
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=banker player_total=8 banker_total=9 natural=true return_cents=14625 bankroll_cents=50000 heat=0 opponent_profit_cents=-375 reveal_count=4
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=7 natural=false return_cents=14625 bankroll_cents=57125 heat=0 opponent_profit_cents=6750 reveal_count=4
hand stage=3 hand=4 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=8 natural=true return_cents=14625 bankroll_cents=64250 heat=0 opponent_profit_cents=13875 reveal_count=4
hand stage=3 hand=5 bet=banker bet_cents=15000 winner=player player_total=6 banker_total=3 natural=false return_cents=0 bankroll_cents=50750 heat=0 opponent_profit_cents=6375 reveal_count=4
hand stage=3 hand=6 bet=banker bet_cents=7500 winner=banker player_total=0 banker_total=8 natural=true return_cents=14625 bankroll_cents=57875 heat=0 opponent_profit_cents=-1125 reveal_count=4
hand stage=3 hand=7 bet=banker bet_cents=7500 winner=banker player_total=5 banker_total=8 natural=true return_cents=14625 bankroll_cents=65000 heat=0 opponent_profit_cents=6000 reveal_count=4
stage_result stage=3 clear=true profit_cents=29250 opponent_profit_cents=6000 tolerance_cents=15000 bankroll_cents=65000 heat=0 chips=4
stage_reward_rewards=Chip Runner
shop_modifiers=tie.tie-whisperer;vision.soft-peek
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=65000 heat=0 chips=0 boss=none active_mods=core.opening-tell;counter.false-read;player.side-step;tie.tie-whisperer;vision.soft-peek
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=banker player_total=3 banker_total=8 natural=true return_cents=19500 bankroll_cents=74500 heat=0 opponent_profit_cents=19000 reveal_count=4
hand stage=4 hand=2 bet=tie bet_cents=10000 winner=tie player_total=0 banker_total=0 natural=false return_cents=90000 bankroll_cents=154500 heat=0 opponent_profit_cents=19000 reveal_count=4
hand stage=4 hand=3 bet=player bet_cents=20000 winner=banker player_total=2 banker_total=9 natural=false return_cents=0 bankroll_cents=136500 heat=0 opponent_profit_cents=38000 reveal_count=4
hand stage=4 hand=4 bet=player bet_cents=20000 winner=player player_total=7 banker_total=0 natural=false return_cents=40000 bankroll_cents=156500 heat=0 opponent_profit_cents=28000 reveal_count=4
hand stage=4 hand=5 bet=banker bet_cents=30000 winner=banker player_total=3 banker_total=9 natural=true return_cents=58500 bankroll_cents=185000 heat=0 opponent_profit_cents=47000 reveal_count=4
hand stage=4 hand=6 bet=banker bet_cents=20000 winner=banker player_total=0 banker_total=7 natural=false return_cents=39000 bankroll_cents=204000 heat=0 opponent_profit_cents=66000 reveal_count=4
hand stage=4 hand=7 bet=banker bet_cents=40000 winner=banker player_total=6 banker_total=9 natural=true return_cents=78000 bankroll_cents=242000 heat=0 opponent_profit_cents=85000 reveal_count=4
hand stage=4 hand=8 bet=tie bet_cents=40000 winner=tie player_total=9 banker_total=9 natural=true return_cents=360000 bankroll_cents=562000 heat=0 opponent_profit_cents=165000 reveal_count=4
stage_result stage=4 clear=true profit_cents=497000 opponent_profit_cents=165000 tolerance_cents=5000 bankroll_cents=562000 heat=0 chips=4
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=natural.natural-read
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=562000 heat=0 chips=1 boss=Pit Boss active_mods=core.opening-tell;counter.false-read;player.side-step;tie.tie-whisperer;vision.soft-peek
hand stage=5 hand=1 bet=player bet_cents=30000 winner=player player_total=6 banker_total=2 natural=false return_cents=60000 bankroll_cents=592000 heat=0 opponent_profit_cents=-15000 reveal_count=4
hand stage=5 hand=2 bet=banker bet_cents=60000 winner=banker player_total=5 banker_total=8 natural=true return_cents=117000 bankroll_cents=649000 heat=1 opponent_profit_cents=-30000 reveal_count=4
hand stage=5 hand=3 bet=banker bet_cents=30000 winner=banker player_total=1 banker_total=5 natural=false return_cents=58500 bankroll_cents=677500 heat=1 opponent_profit_cents=-15750 reveal_count=4
hand stage=5 hand=4 bet=player bet_cents=30000 winner=player player_total=6 banker_total=2 natural=false return_cents=60000 bankroll_cents=707500 heat=1 opponent_profit_cents=-30750 reveal_count=4
hand stage=5 hand=5 bet=player bet_cents=60000 winner=player player_total=8 banker_total=4 natural=true return_cents=120000 bankroll_cents=767500 heat=2 opponent_profit_cents=-750 reveal_count=4
hand stage=5 hand=6 bet=tie bet_cents=15000 winner=tie player_total=4 banker_total=4 natural=false return_cents=135000 bankroll_cents=887500 heat=3 opponent_profit_cents=-750 reveal_count=4
hand stage=5 hand=7 bet=banker bet_cents=30000 winner=player player_total=9 banker_total=3 natural=false return_cents=0 bankroll_cents=860500 heat=3 opponent_profit_cents=-15750 reveal_count=4
hand stage=5 hand=8 bet=player bet_cents=30000 winner=banker player_total=3 banker_total=6 natural=false return_cents=0 bankroll_cents=833500 heat=3 opponent_profit_cents=-30750 reveal_count=4
stage_result stage=5 clear=true profit_cents=271500 opponent_profit_cents=-30750 tolerance_cents=0 bankroll_cents=833500 heat=3 chips=7
boss_reward_rewards=Echo Chamber
shop_modifiers=tie.tie-whisperer
stage_start stage=6 hands=8 ante_cents=20000 min_bet_cents=20000 bankroll_cents=833500 heat=3 chips=4 boss=none active_mods=core.opening-tell;counter.false-read;player.side-step;tie.tie-whisperer;vision.soft-peek
hand stage=6 hand=1 bet=tie bet_cents=20000 winner=banker player_total=3 banker_total=4 natural=false return_cents=0 bankroll_cents=815500 heat=3 opponent_profit_cents=-20000 reveal_count=4
hand stage=6 hand=2 bet=player bet_cents=40000 winner=player player_total=4 banker_total=0 natural=false return_cents=80000 bankroll_cents=855500 heat=3 opponent_profit_cents=0 reveal_count=4
hand stage=6 hand=3 bet=player bet_cents=80000 winner=player player_total=8 banker_total=5 natural=true return_cents=160000 bankroll_cents=935500 heat=3 opponent_profit_cents=-20000 reveal_count=4
hand stage=6 hand=4 bet=player bet_cents=40000 winner=player player_total=5 banker_total=4 natural=false return_cents=80000 bankroll_cents=975500 heat=3 opponent_profit_cents=-40000 reveal_count=4
hand stage=6 hand=5 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=7 natural=false return_cents=78000 bankroll_cents=1013500 heat=3 opponent_profit_cents=-2000 reveal_count=4
hand stage=6 hand=6 bet=tie bet_cents=20000 winner=tie player_total=5 banker_total=5 natural=false return_cents=180000 bankroll_cents=1173500 heat=3 opponent_profit_cents=-2000 reveal_count=4
hand stage=6 hand=7 bet=player bet_cents=40000 winner=player player_total=6 banker_total=5 natural=false return_cents=80000 bankroll_cents=1213500 heat=3 opponent_profit_cents=-22000 reveal_count=4
hand stage=6 hand=8 bet=tie bet_cents=80000 winner=tie player_total=7 banker_total=7 natural=false return_cents=720000 bankroll_cents=1853500 heat=3 opponent_profit_cents=-22000 reveal_count=4
stage_result stage=6 clear=true profit_cents=1020000 opponent_profit_cents=-22000 tolerance_cents=0 bankroll_cents=1853500 heat=3 chips=9
stage_reward_rewards=Modifier Voucher
shop_modifiers=player.side-step
stage_start stage=7 hands=9 ante_cents=30000 min_bet_cents=30000 bankroll_cents=1853500 heat=3 chips=6 boss=none active_mods=core.opening-tell;counter.false-read;player.side-step;tie.tie-whisperer;vision.soft-peek
hand stage=7 hand=1 bet=banker bet_cents=120000 winner=banker player_total=5 banker_total=8 natural=true return_cents=234000 bankroll_cents=1967500 heat=3 opponent_profit_cents=28500 reveal_count=4
hand stage=7 hand=2 bet=player bet_cents=120000 winner=player player_total=9 banker_total=7 natural=true return_cents=240000 bankroll_cents=2087500 heat=3 opponent_profit_cents=-1500 reveal_count=4
hand stage=7 hand=3 bet=banker bet_cents=120000 winner=banker player_total=5 banker_total=9 natural=true return_cents=234000 bankroll_cents=2201500 heat=3 opponent_profit_cents=84000 reveal_count=4
hand stage=7 hand=4 bet=player bet_cents=60000 winner=player player_total=7 banker_total=3 natural=false return_cents=120000 bankroll_cents=2261500 heat=3 opponent_profit_cents=54000 reveal_count=4
hand stage=7 hand=5 bet=tie bet_cents=30000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=2234500 heat=3 opponent_profit_cents=24000 reveal_count=4
hand stage=7 hand=6 bet=player bet_cents=60000 winner=tie player_total=3 banker_total=3 natural=false return_cents=60000 bankroll_cents=2240500 heat=3 opponent_profit_cents=744000 reveal_count=4
hand stage=7 hand=7 bet=player bet_cents=60000 winner=player player_total=6 banker_total=3 natural=false return_cents=120000 bankroll_cents=2300500 heat=3 opponent_profit_cents=714000 reveal_count=4
hand stage=7 hand=8 bet=player bet_cents=60000 winner=player player_total=5 banker_total=1 natural=false return_cents=120000 bankroll_cents=2360500 heat=3 opponent_profit_cents=684000 reveal_count=4
hand stage=7 hand=9 bet=banker bet_cents=60000 winner=banker player_total=2 banker_total=7 natural=false return_cents=117000 bankroll_cents=2417500 heat=3 opponent_profit_cents=769500 reveal_count=4
stage_result stage=7 clear=true profit_cents=564000 opponent_profit_cents=769500 tolerance_cents=240000 bankroll_cents=2417500 heat=3 chips=16
stage_reward_rewards=Attachment Case
stage_start stage=8 hands=10 ante_cents=40000 min_bet_cents=40000 bankroll_cents=2417500 heat=3 chips=16 boss=The Inspector active_mods=core.opening-tell;counter.false-read;player.side-step;tie.tie-whisperer;vision.soft-peek
hand stage=8 hand=1 bet=banker bet_cents=175000 winner=banker player_total=3 banker_total=8 natural=true return_cents=341250 bankroll_cents=2583750 heat=5 opponent_profit_cents=198000 reveal_count=4
hand stage=8 hand=2 bet=player bet_cents=175000 winner=player player_total=9 banker_total=7 natural=true return_cents=350000 bankroll_cents=2758750 heat=5 opponent_profit_cents=238000 reveal_count=4
hand stage=8 hand=3 bet=tie bet_cents=40000 winner=player player_total=9 banker_total=8 natural=false return_cents=0 bankroll_cents=2722750 heat=5 opponent_profit_cents=198000 reveal_count=4
hand stage=8 hand=4 bet=banker bet_cents=175000 winner=banker player_total=7 banker_total=9 natural=true return_cents=341250 bankroll_cents=2889000 heat=5 opponent_profit_cents=236000 reveal_count=4
hand stage=8 hand=5 bet=banker bet_cents=80000 winner=banker player_total=0 banker_total=6 natural=false return_cents=156000 bankroll_cents=2965000 heat=5 opponent_profit_cents=274000 reveal_count=4
hand stage=8 hand=6 bet=banker bet_cents=175000 winner=banker player_total=5 banker_total=8 natural=true return_cents=341250 bankroll_cents=3131250 heat=5 opponent_profit_cents=234000 reveal_count=4
hand stage=8 hand=7 bet=banker bet_cents=175000 winner=banker player_total=8 banker_total=9 natural=true return_cents=341250 bankroll_cents=3297500 heat=5 opponent_profit_cents=272000 reveal_count=4
hand stage=8 hand=8 bet=player bet_cents=80000 winner=banker player_total=3 banker_total=4 natural=false return_cents=0 bankroll_cents=3225500 heat=5 opponent_profit_cents=310000 reveal_count=4
hand stage=8 hand=9 bet=player bet_cents=80000 winner=banker player_total=6 banker_total=9 natural=false return_cents=0 bankroll_cents=3153500 heat=5 opponent_profit_cents=348000 reveal_count=4
hand stage=8 hand=10 bet=banker bet_cents=175000 winner=banker player_total=6 banker_total=8 natural=true return_cents=341250 bankroll_cents=3319750 heat=5 opponent_profit_cents=308000 reveal_count=4
stage_result stage=8 clear=true profit_cents=902250 opponent_profit_cents=308000 tolerance_cents=0 bankroll_cents=3319750 heat=5 chips=23
boss_reward_rewards=Echo Chamber
stage_start stage=9 hands=10 ante_cents=60000 min_bet_cents=60000 bankroll_cents=3319750 heat=5 chips=22 boss=none active_mods=core.opening-tell;counter.false-read;player.side-step;tie.tie-whisperer;vision.soft-peek
hand stage=9 hand=1 bet=tie bet_cents=250000 winner=tie player_total=6 banker_total=6 natural=false return_cents=2250000 bankroll_cents=5319750 heat=5 opponent_profit_cents=0 reveal_count=4
hand stage=9 hand=2 bet=player bet_cents=120000 winner=player player_total=6 banker_total=1 natural=false return_cents=240000 bankroll_cents=5439750 heat=5 opponent_profit_cents=-60000 reveal_count=4
hand stage=9 hand=3 bet=banker bet_cents=120000 winner=player player_total=8 banker_total=5 natural=false return_cents=0 bankroll_cents=5331750 heat=7 opponent_profit_cents=0 reveal_count=4
hand stage=9 hand=4 bet=player bet_cents=250000 winner=player player_total=9 banker_total=6 natural=true return_cents=530000 bankroll_cents=5611750 heat=7 opponent_profit_cents=-60000 reveal_count=4
hand stage=9 hand=5 bet=banker bet_cents=250000 winner=banker player_total=7 banker_total=9 natural=true return_cents=487500 bankroll_cents=5849250 heat=7 opponent_profit_cents=-180000 reveal_count=4
hand stage=9 hand=6 bet=banker bet_cents=250000 winner=banker player_total=4 banker_total=8 natural=true return_cents=502500 bankroll_cents=6101750 heat=7 opponent_profit_cents=-123000 reveal_count=4
hand stage=9 hand=7 bet=player bet_cents=120000 winner=player player_total=8 banker_total=5 natural=false return_cents=240000 bankroll_cents=6221750 heat=7 opponent_profit_cents=-183000 reveal_count=4
hand stage=9 hand=8 bet=tie bet_cents=250000 winner=tie player_total=6 banker_total=6 natural=false return_cents=2250000 bankroll_cents=8221750 heat=7 opponent_profit_cents=-183000 reveal_count=4
hand stage=9 hand=9 bet=player bet_cents=120000 winner=banker player_total=0 banker_total=3 natural=false return_cents=0 bankroll_cents=8113750 heat=7 opponent_profit_cents=-126000 reveal_count=4
hand stage=9 hand=10 bet=player bet_cents=250000 winner=player player_total=9 banker_total=3 natural=true return_cents=500000 bankroll_cents=8363750 heat=7 opponent_profit_cents=-6000 reveal_count=4
stage_result stage=9 clear=true profit_cents=5044000 opponent_profit_cents=-6000 tolerance_cents=0 bankroll_cents=8363750 heat=7 chips=27
stage_reward_rewards=Table Comp
shop_modifiers=tie.equalizer
stage_start stage=10 hands=12 ante_cents=80000 min_bet_cents=80000 bankroll_cents=8453750 heat=7 chips=21 boss=The House active_mods=core.opening-tell;counter.false-read;player.side-step;tie.tie-whisperer;vision.soft-peek
hand stage=10 hand=1 bet=player bet_cents=160000 winner=banker player_total=7 banker_total=9 natural=false return_cents=0 bankroll_cents=8309750 heat=10 opponent_profit_cents=396000 reveal_count=4
stage_result stage=10 clear=false profit_cents=-144000 opponent_profit_cents=396000 tolerance_cents=0 bankroll_cents=8309750 heat=10 chips=21
finish completed=false final_stage=10 failure=stage_10_heat ending_bankroll_cents=8309750 highest_bankroll_cents=8363750 heat=10 owned_mods=core.opening-tell;counter.false-read;player.side-step;tie.tie-whisperer;vision.soft-peek
```

## anomaly_high_bankroll / optimized / 2182477019275242731

- Completed: yes; final stage: 10; failure: `run_complete`.
- Ending bankroll: $1,039,750; heat: 1; hands: 83; build: `core.clean-hands|core.opening-tell|heat.floor-distraction|vision.dealer-glance|vision.pattern-memory`.
- Rewards: High Card Drop, Rare Modifier Voucher, Table Comp, Rare Modifier Voucher, Player Consortium, Cool Down, Table Comp, Player Consortium, High Table Cut.
- Modifiers picked: vision.dealer-glance, core.clean-hands, core.clean-hands, heat.floor-distraction, vision.dealer-glance, vision.pattern-memory, core.opening-tell, counter.false-read, counter.false-read, counter.false-read.

```text
start seed=2182477019275242731 policy=optimized contact=contact.dealer bankroll_cents=22500 chips=3 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=22500 heat=0 chips=3 boss=none active_mods=core.opening-tell
hand stage=1 hand=1 bet=banker bet_cents=5000 winner=banker player_total=3 banker_total=9 natural=true return_cents=9750 bankroll_cents=27250 heat=0 opponent_profit_cents=2375 reveal_count=3
hand stage=1 hand=2 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=9 natural=true return_cents=9750 bankroll_cents=32000 heat=0 opponent_profit_cents=-125 reveal_count=3
hand stage=1 hand=3 bet=banker bet_cents=5000 winner=banker player_total=3 banker_total=7 natural=false return_cents=9750 bankroll_cents=36750 heat=0 opponent_profit_cents=-2625 reveal_count=3
hand stage=1 hand=4 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=31750 heat=0 opponent_profit_cents=-5125 reveal_count=3
hand stage=1 hand=5 bet=banker bet_cents=5000 winner=player player_total=6 banker_total=3 natural=false return_cents=0 bankroll_cents=26750 heat=0 opponent_profit_cents=-10125 reveal_count=3
stage_result stage=1 clear=true profit_cents=4250 opponent_profit_cents=-10125 tolerance_cents=22500 bankroll_cents=26750 heat=0 chips=6
stage_reward_rewards=High Card Drop
shop_modifiers=vision.dealer-glance;core.clean-hands
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=26750 heat=0 chips=0 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=banker player_total=1 banker_total=9 natural=true return_cents=10000 bankroll_cents=31750 heat=0 opponent_profit_cents=5000 reveal_count=3
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=26750 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=banker player_total=1 banker_total=8 natural=true return_cents=10000 bankroll_cents=31750 heat=0 opponent_profit_cents=5000 reveal_count=3
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=7 natural=false return_cents=10000 bankroll_cents=36750 heat=0 opponent_profit_cents=10000 reveal_count=3
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=banker player_total=2 banker_total=5 natural=false return_cents=10000 bankroll_cents=41750 heat=0 opponent_profit_cents=0 reveal_count=3
hand stage=2 hand=6 bet=banker bet_cents=10000 winner=banker player_total=5 banker_total=7 natural=false return_cents=20000 bankroll_cents=51750 heat=0 opponent_profit_cents=5000 reveal_count=3
stage_result stage=2 clear=true profit_cents=25000 opponent_profit_cents=5000 tolerance_cents=15000 bankroll_cents=51750 heat=0 chips=3
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=core.clean-hands
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=51750 heat=0 chips=0 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands
hand stage=3 hand=1 bet=player bet_cents=7500 winner=player player_total=9 banker_total=4 natural=true return_cents=15000 bankroll_cents=59250 heat=0 opponent_profit_cents=-7500 reveal_count=4
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=player player_total=4 banker_total=2 natural=false return_cents=0 bankroll_cents=51750 heat=0 opponent_profit_cents=0 reveal_count=4
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=44250 heat=0 opponent_profit_cents=-7500 reveal_count=4
hand stage=3 hand=4 bet=player bet_cents=7500 winner=tie player_total=6 banker_total=6 natural=false return_cents=7500 bankroll_cents=44250 heat=0 opponent_profit_cents=-7500 reveal_count=4
hand stage=3 hand=5 bet=banker bet_cents=7500 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=36750 heat=0 opponent_profit_cents=-15000 reveal_count=4
hand stage=3 hand=6 bet=player bet_cents=7500 winner=player player_total=8 banker_total=3 natural=true return_cents=15000 bankroll_cents=44250 heat=0 opponent_profit_cents=-7500 reveal_count=4
hand stage=3 hand=7 bet=player bet_cents=7500 winner=player player_total=2 banker_total=0 natural=false return_cents=15000 bankroll_cents=51750 heat=0 opponent_profit_cents=-15000 reveal_count=4
stage_result stage=3 clear=true profit_cents=0 opponent_profit_cents=-15000 tolerance_cents=15000 bankroll_cents=51750 heat=0 chips=2
stage_reward_rewards=Table Comp
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=63000 heat=0 chips=1 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=banker player_total=0 banker_total=6 natural=false return_cents=19500 bankroll_cents=72500 heat=0 opponent_profit_cents=19000 reveal_count=4
hand stage=4 hand=2 bet=player bet_cents=10000 winner=banker player_total=2 banker_total=9 natural=false return_cents=0 bankroll_cents=62500 heat=0 opponent_profit_cents=38000 reveal_count=4
hand stage=4 hand=3 bet=tie bet_cents=10000 winner=player player_total=8 banker_total=0 natural=false return_cents=0 bankroll_cents=52500 heat=0 opponent_profit_cents=18000 reveal_count=4
hand stage=4 hand=4 bet=banker bet_cents=10000 winner=banker player_total=0 banker_total=8 natural=true return_cents=19500 bankroll_cents=62000 heat=0 opponent_profit_cents=8000 reveal_count=4
hand stage=4 hand=5 bet=player bet_cents=10000 winner=player player_total=8 banker_total=0 natural=true return_cents=20000 bankroll_cents=72000 heat=0 opponent_profit_cents=-12000 reveal_count=4
hand stage=4 hand=6 bet=banker bet_cents=10000 winner=player player_total=8 banker_total=6 natural=false return_cents=0 bankroll_cents=62000 heat=0 opponent_profit_cents=-32000 reveal_count=4
hand stage=4 hand=7 bet=tie bet_cents=10000 winner=tie player_total=7 banker_total=7 natural=false return_cents=90000 bankroll_cents=142000 heat=0 opponent_profit_cents=-32000 reveal_count=4
hand stage=4 hand=8 bet=banker bet_cents=30000 winner=banker player_total=4 banker_total=9 natural=true return_cents=58500 bankroll_cents=170500 heat=0 opponent_profit_cents=-42000 reveal_count=4
stage_result stage=4 clear=true profit_cents=107500 opponent_profit_cents=-42000 tolerance_cents=5000 bankroll_cents=170500 heat=0 chips=5
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=heat.floor-distraction
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=170500 heat=0 chips=1 boss=Pit Boss active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands;heat.floor-distraction
hand stage=5 hand=1 bet=player bet_cents=30000 winner=player player_total=5 banker_total=0 natural=false return_cents=60000 bankroll_cents=200500 heat=0 opponent_profit_cents=-15000 reveal_count=5
hand stage=5 hand=2 bet=player bet_cents=45000 winner=player player_total=7 banker_total=3 natural=false return_cents=90000 bankroll_cents=245500 heat=0 opponent_profit_cents=0 reveal_count=5
hand stage=5 hand=3 bet=player bet_cents=30000 winner=banker player_total=6 banker_total=9 natural=false return_cents=0 bankroll_cents=215500 heat=0 opponent_profit_cents=-12000 reveal_count=5
hand stage=5 hand=4 bet=banker bet_cents=45000 winner=banker player_total=6 banker_total=8 natural=true return_cents=87750 bankroll_cents=258250 heat=0 opponent_profit_cents=2250 reveal_count=5
hand stage=5 hand=5 bet=player bet_cents=60000 winner=player player_total=6 banker_total=4 natural=false return_cents=120000 bankroll_cents=318250 heat=1 opponent_profit_cents=-27750 reveal_count=5
hand stage=5 hand=6 bet=player bet_cents=60000 winner=player player_total=9 banker_total=5 natural=true return_cents=120000 bankroll_cents=378250 heat=2 opponent_profit_cents=-12750 reveal_count=5
hand stage=5 hand=7 bet=banker bet_cents=60000 winner=banker player_total=0 banker_total=7 natural=false return_cents=117000 bankroll_cents=435250 heat=3 opponent_profit_cents=-27750 reveal_count=5
hand stage=5 hand=8 bet=banker bet_cents=30000 winner=banker player_total=1 banker_total=3 natural=false return_cents=58500 bankroll_cents=463750 heat=3 opponent_profit_cents=-13500 reveal_count=5
stage_result stage=5 clear=true profit_cents=293250 opponent_profit_cents=-13500 tolerance_cents=0 bankroll_cents=463750 heat=3 chips=7
boss_reward_rewards=Player Consortium
shop_modifiers=vision.dealer-glance
stage_start stage=6 hands=8 ante_cents=20000 min_bet_cents=20000 bankroll_cents=463750 heat=3 chips=4 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands;heat.floor-distraction
hand stage=6 hand=1 bet=player bet_cents=40000 winner=player player_total=9 banker_total=0 natural=false return_cents=80000 bankroll_cents=503750 heat=3 opponent_profit_cents=20000 reveal_count=5
hand stage=6 hand=2 bet=banker bet_cents=80000 winner=banker player_total=3 banker_total=8 natural=true return_cents=156000 bankroll_cents=579750 heat=3 opponent_profit_cents=39000 reveal_count=5
hand stage=6 hand=3 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=1 natural=false return_cents=78000 bankroll_cents=617750 heat=3 opponent_profit_cents=19000 reveal_count=5
hand stage=6 hand=4 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=8 natural=false return_cents=78000 bankroll_cents=655750 heat=3 opponent_profit_cents=-1000 reveal_count=5
hand stage=6 hand=5 bet=banker bet_cents=80000 winner=banker player_total=7 banker_total=8 natural=true return_cents=156000 bankroll_cents=731750 heat=3 opponent_profit_cents=-41000 reveal_count=5
hand stage=6 hand=6 bet=banker bet_cents=80000 winner=banker player_total=6 banker_total=9 natural=false return_cents=156000 bankroll_cents=807750 heat=3 opponent_profit_cents=-61000 reveal_count=5
hand stage=6 hand=7 bet=player bet_cents=80000 winner=player player_total=7 banker_total=5 natural=false return_cents=160000 bankroll_cents=887750 heat=3 opponent_profit_cents=-41000 reveal_count=5
hand stage=6 hand=8 bet=player bet_cents=80000 winner=player player_total=9 banker_total=1 natural=true return_cents=160000 bankroll_cents=967750 heat=3 opponent_profit_cents=-61000 reveal_count=5
stage_result stage=6 clear=true profit_cents=504000 opponent_profit_cents=-61000 tolerance_cents=0 bankroll_cents=967750 heat=3 chips=9
stage_reward_rewards=Cool Down
shop_modifiers=vision.pattern-memory;core.opening-tell
stage_start stage=7 hands=9 ante_cents=30000 min_bet_cents=30000 bankroll_cents=967750 heat=1 chips=1 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands;heat.floor-distraction;vision.pattern-memory
hand stage=7 hand=1 bet=banker bet_cents=120000 winner=banker player_total=0 banker_total=7 natural=false return_cents=234000 bankroll_cents=1087750 heat=1 opponent_profit_cents=28500 reveal_count=5
hand stage=7 hand=2 bet=banker bet_cents=60000 winner=banker player_total=0 banker_total=1 natural=false return_cents=117000 bankroll_cents=1150750 heat=1 opponent_profit_cents=57000 reveal_count=5
hand stage=7 hand=3 bet=tie bet_cents=30000 winner=banker player_total=0 banker_total=1 natural=false return_cents=0 bankroll_cents=1120750 heat=1 opponent_profit_cents=142500 reveal_count=5
hand stage=7 hand=4 bet=tie bet_cents=120000 winner=tie player_total=6 banker_total=6 natural=false return_cents=1080000 bankroll_cents=2086750 heat=1 opponent_profit_cents=142500 reveal_count=5
hand stage=7 hand=5 bet=banker bet_cents=60000 winner=banker player_total=1 banker_total=5 natural=false return_cents=117000 bankroll_cents=2149750 heat=1 opponent_profit_cents=171000 reveal_count=5
hand stage=7 hand=6 bet=banker bet_cents=120000 winner=banker player_total=6 banker_total=8 natural=true return_cents=234000 bankroll_cents=2269750 heat=1 opponent_profit_cents=256500 reveal_count=5
hand stage=7 hand=7 bet=player bet_cents=60000 winner=player player_total=8 banker_total=5 natural=false return_cents=120000 bankroll_cents=2335750 heat=1 opponent_profit_cents=226500 reveal_count=5
hand stage=7 hand=8 bet=player bet_cents=120000 winner=player player_total=8 banker_total=7 natural=true return_cents=240000 bankroll_cents=2461750 heat=1 opponent_profit_cents=196500 reveal_count=5
hand stage=7 hand=9 bet=player bet_cents=120000 winner=player player_total=9 banker_total=6 natural=true return_cents=240000 bankroll_cents=2587750 heat=1 opponent_profit_cents=286500 reveal_count=5
stage_result stage=7 clear=true profit_cents=1620000 opponent_profit_cents=286500 tolerance_cents=240000 bankroll_cents=2587750 heat=1 chips=11
stage_reward_rewards=Table Comp
shop_modifiers=counter.false-read
stage_start stage=8 hands=10 ante_cents=40000 min_bet_cents=40000 bankroll_cents=2632750 heat=1 chips=8 boss=The Inspector active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands;heat.floor-distraction;vision.pattern-memory
hand stage=8 hand=1 bet=player bet_cents=80000 winner=banker player_total=5 banker_total=8 natural=false return_cents=0 bankroll_cents=2552750 heat=0 opponent_profit_cents=198000 reveal_count=5
hand stage=8 hand=2 bet=player bet_cents=80000 winner=player player_total=6 banker_total=1 natural=false return_cents=160000 bankroll_cents=2640750 heat=0 opponent_profit_cents=238000 reveal_count=5
hand stage=8 hand=3 bet=banker bet_cents=175000 winner=banker player_total=2 banker_total=6 natural=false return_cents=341250 bankroll_cents=2815000 heat=0 opponent_profit_cents=276000 reveal_count=5
hand stage=8 hand=4 bet=player bet_cents=80000 winner=banker player_total=4 banker_total=8 natural=false return_cents=0 bankroll_cents=2735000 heat=0 opponent_profit_cents=314000 reveal_count=5
hand stage=8 hand=5 bet=banker bet_cents=175000 winner=banker player_total=1 banker_total=9 natural=true return_cents=341250 bankroll_cents=2909250 heat=0 opponent_profit_cents=352000 reveal_count=5
hand stage=8 hand=6 bet=tie bet_cents=175000 winner=tie player_total=8 banker_total=8 natural=true return_cents=1575000 bankroll_cents=4317250 heat=0 opponent_profit_cents=352000 reveal_count=5
hand stage=8 hand=7 bet=tie bet_cents=175000 winner=tie player_total=7 banker_total=7 natural=false return_cents=1575000 bankroll_cents=5725250 heat=0 opponent_profit_cents=352000 reveal_count=5
hand stage=8 hand=8 bet=banker bet_cents=175000 winner=banker player_total=3 banker_total=5 natural=false return_cents=341250 bankroll_cents=5899500 heat=0 opponent_profit_cents=390000 reveal_count=5
hand stage=8 hand=9 bet=banker bet_cents=175000 winner=banker player_total=8 banker_total=9 natural=true return_cents=341250 bankroll_cents=6073750 heat=0 opponent_profit_cents=428000 reveal_count=5
hand stage=8 hand=10 bet=banker bet_cents=175000 winner=banker player_total=7 banker_total=8 natural=true return_cents=341250 bankroll_cents=6248000 heat=0 opponent_profit_cents=388000 reveal_count=5
stage_result stage=8 clear=true profit_cents=3615250 opponent_profit_cents=388000 tolerance_cents=0 bankroll_cents=6248000 heat=0 chips=15
boss_reward_rewards=Player Consortium
shop_modifiers=counter.false-read
stage_start stage=9 hands=10 ante_cents=60000 min_bet_cents=60000 bankroll_cents=6248000 heat=0 chips=11 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands;heat.floor-distraction;vision.pattern-memory
hand stage=9 hand=1 bet=player bet_cents=250000 winner=player player_total=8 banker_total=4 natural=true return_cents=1500000 bankroll_cents=7510000 heat=0 opponent_profit_cents=-60000 reveal_count=5
hand stage=9 hand=2 bet=banker bet_cents=250000 winner=banker player_total=5 banker_total=8 natural=true return_cents=1437500 bankroll_cents=8709500 heat=0 opponent_profit_cents=-3000 reveal_count=5
hand stage=9 hand=3 bet=banker bet_cents=250000 winner=banker player_total=0 banker_total=5 natural=false return_cents=1437500 bankroll_cents=9909000 heat=0 opponent_profit_cents=54000 reveal_count=5
hand stage=9 hand=4 bet=banker bet_cents=250000 winner=banker player_total=7 banker_total=9 natural=false return_cents=1437500 bankroll_cents=11108500 heat=0 opponent_profit_cents=111000 reveal_count=5
hand stage=9 hand=5 bet=tie bet_cents=250000 winner=tie player_total=8 banker_total=8 natural=true return_cents=10250000 bankroll_cents=21120500 heat=0 opponent_profit_cents=111000 reveal_count=5
hand stage=9 hand=6 bet=player bet_cents=250000 winner=player player_total=8 banker_total=3 natural=true return_cents=1500000 bankroll_cents=22382500 heat=0 opponent_profit_cents=51000 reveal_count=5
hand stage=9 hand=7 bet=banker bet_cents=250000 winner=banker player_total=2 banker_total=9 natural=true return_cents=1437500 bankroll_cents=23582000 heat=0 opponent_profit_cents=108000 reveal_count=5
hand stage=9 hand=8 bet=banker bet_cents=250000 winner=banker player_total=6 banker_total=8 natural=true return_cents=1437500 bankroll_cents=24781500 heat=0 opponent_profit_cents=165000 reveal_count=5
hand stage=9 hand=9 bet=banker bet_cents=120000 winner=banker player_total=2 banker_total=5 natural=false return_cents=690000 bankroll_cents=25363500 heat=0 opponent_profit_cents=222000 reveal_count=5
hand stage=9 hand=10 bet=banker bet_cents=250000 winner=banker player_total=1 banker_total=9 natural=true return_cents=1437500 bankroll_cents=26563000 heat=0 opponent_profit_cents=102000 reveal_count=5
stage_result stage=9 clear=true profit_cents=20315000 opponent_profit_cents=102000 tolerance_cents=0 bankroll_cents=26563000 heat=0 chips=16
stage_reward_rewards=High Table Cut
shop_modifiers=counter.false-read
stage_start stage=10 hands=12 ante_cents=80000 min_bet_cents=80000 bankroll_cents=26683000 heat=0 chips=13 boss=The House active_mods=core.opening-tell;vision.dealer-glance;core.clean-hands;heat.floor-distraction;vision.pattern-memory
hand stage=10 hand=1 bet=tie bet_cents=400000 winner=tie player_total=7 banker_total=7 natural=false return_cents=16400000 bankroll_cents=42699000 heat=0 opponent_profit_cents=320000 reveal_count=5
hand stage=10 hand=2 bet=banker bet_cents=400000 winner=banker player_total=0 banker_total=7 natural=false return_cents=2300000 bankroll_cents=44615000 heat=0 opponent_profit_cents=396000 reveal_count=5
hand stage=10 hand=3 bet=banker bet_cents=400000 winner=banker player_total=4 banker_total=9 natural=true return_cents=2300000 bankroll_cents=46531000 heat=0 opponent_profit_cents=472000 reveal_count=5
hand stage=10 hand=4 bet=tie bet_cents=400000 winner=tie player_total=9 banker_total=9 natural=true return_cents=16400000 bankroll_cents=62547000 heat=0 opponent_profit_cents=472000 reveal_count=5
hand stage=10 hand=5 bet=player bet_cents=160000 winner=player player_total=7 banker_total=5 natural=false return_cents=960000 bankroll_cents=63363000 heat=0 opponent_profit_cents=632000 reveal_count=5
hand stage=10 hand=6 bet=banker bet_cents=400000 winner=banker player_total=5 banker_total=6 natural=false return_cents=2300000 bankroll_cents=65279000 heat=0 opponent_profit_cents=708000 reveal_count=5
hand stage=10 hand=7 bet=tie bet_cents=400000 winner=tie player_total=6 banker_total=6 natural=false return_cents=16400000 bankroll_cents=81295000 heat=1 opponent_profit_cents=708000 reveal_count=5
hand stage=10 hand=8 bet=banker bet_cents=400000 winner=banker player_total=5 banker_total=6 natural=false return_cents=2300000 bankroll_cents=83211000 heat=1 opponent_profit_cents=784000 reveal_count=5
hand stage=10 hand=9 bet=player bet_cents=160000 winner=player player_total=5 banker_total=2 natural=false return_cents=960000 bankroll_cents=84027000 heat=1 opponent_profit_cents=704000 reveal_count=5
hand stage=10 hand=10 bet=tie bet_cents=400000 winner=tie player_total=8 banker_total=8 natural=true return_cents=16400000 bankroll_cents=100043000 heat=1 opponent_profit_cents=704000 reveal_count=5
hand stage=10 hand=11 bet=player bet_cents=400000 winner=player player_total=7 banker_total=5 natural=false return_cents=2400000 bankroll_cents=102059000 heat=1 opponent_profit_cents=624000 reveal_count=5
hand stage=10 hand=12 bet=banker bet_cents=400000 winner=banker player_total=0 banker_total=9 natural=true return_cents=2300000 bankroll_cents=103975000 heat=1 opponent_profit_cents=700000 reveal_count=5
stage_result stage=10 clear=true profit_cents=77292000 opponent_profit_cents=700000 tolerance_cents=0 bankroll_cents=103975000 heat=1 chips=22
finish completed=true final_stage=10 failure=run_complete ending_bankroll_cents=103975000 highest_bankroll_cents=103975000 heat=1 owned_mods=core.opening-tell;vision.dealer-glance;core.clean-hands;heat.floor-distraction;vision.pattern-memory
```

## anomaly_early_failure / optimized / 7565164398174258285

- Completed: no; final stage: 1; failure: `stage_1_opponent_loss`.
- Ending bankroll: $100; heat: 0; hands: 5; build: `core.opening-tell`.
- Rewards: none.
- Modifiers picked: none.

```text
start seed=7565164398174258285 policy=optimized contact=contact.dealer bankroll_cents=22500 chips=3 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=22500 heat=0 chips=3 boss=none active_mods=core.opening-tell
hand stage=1 hand=1 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=17500 heat=0 opponent_profit_cents=-2500 reveal_count=3
hand stage=1 hand=2 bet=banker bet_cents=2500 winner=player player_total=8 banker_total=0 natural=true return_cents=0 bankroll_cents=15000 heat=0 opponent_profit_cents=-5000 reveal_count=3
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=12500 heat=0 opponent_profit_cents=-2500 reveal_count=3
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=player player_total=5 banker_total=4 natural=false return_cents=0 bankroll_cents=10000 heat=0 opponent_profit_cents=-5000 reveal_count=3
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=tie player_total=5 banker_total=5 natural=false return_cents=2500 bankroll_cents=10000 heat=0 opponent_profit_cents=35000 reveal_count=3
stage_result stage=1 clear=false profit_cents=-12500 opponent_profit_cents=35000 tolerance_cents=22500 bankroll_cents=10000 heat=0 chips=3
finish completed=false final_stage=1 failure=stage_1_opponent_loss ending_bankroll_cents=10000 highest_bankroll_cents=17500 heat=0 owned_mods=core.opening-tell
```

## anomaly_heat_failure / optimized / 10706458417670280869

- Completed: no; final stage: 10; failure: `stage_10_heat`.
- Ending bankroll: $118,618.75; heat: 10; hands: 72; build: `banker.dealers-nod|core.opening-tell|core.opening-tell|economy.interest-ledger|vision.dealer-glance`.
- Rewards: Rare Modifier Voucher, Cool Down, Rare Modifier Voucher, Ante Kickback, Player Consortium, Attachment Case, Table Comp, Banker Consortium, High Table Cut.
- Modifiers picked: core.opening-tell, vision.dealer-glance, banker.dealers-nod, vision.dealer-glance, economy.interest-ledger, pair.pair-hunter, banker.dealers-nod, core.opening-tell, vision.soft-peek.

```text
start seed=10706458417670280869 policy=optimized contact=contact.dealer bankroll_cents=22500 chips=3 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=22500 heat=0 chips=3 boss=none active_mods=core.opening-tell
hand stage=1 hand=1 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=5 natural=true return_cents=0 bankroll_cents=17500 heat=0 opponent_profit_cents=-2500 reveal_count=3
hand stage=1 hand=2 bet=banker bet_cents=2500 winner=player player_total=6 banker_total=4 natural=false return_cents=0 bankroll_cents=15000 heat=0 opponent_profit_cents=-5000 reveal_count=3
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=player player_total=9 banker_total=4 natural=true return_cents=0 bankroll_cents=12500 heat=0 opponent_profit_cents=-2500 reveal_count=3
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=banker player_total=4 banker_total=7 natural=false return_cents=4875 bankroll_cents=14875 heat=0 opponent_profit_cents=-125 reveal_count=3
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=banker player_total=4 banker_total=7 natural=false return_cents=4875 bankroll_cents=17250 heat=0 opponent_profit_cents=-5125 reveal_count=3
stage_result stage=1 clear=true profit_cents=-5250 opponent_profit_cents=-5125 tolerance_cents=22500 bankroll_cents=17250 heat=1 chips=5
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=core.opening-tell
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=17250 heat=1 chips=0 boss=none active_mods=core.opening-tell
hand stage=2 hand=1 bet=player bet_cents=5000 winner=player player_total=8 banker_total=1 natural=false return_cents=10000 bankroll_cents=22250 heat=1 opponent_profit_cents=-5000 reveal_count=5
hand stage=2 hand=2 bet=player bet_cents=5000 winner=player player_total=8 banker_total=0 natural=true return_cents=10000 bankroll_cents=27250 heat=1 opponent_profit_cents=-10000 reveal_count=5
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=banker player_total=3 banker_total=8 natural=true return_cents=10000 bankroll_cents=32250 heat=1 opponent_profit_cents=-5000 reveal_count=5
hand stage=2 hand=4 bet=player bet_cents=5000 winner=player player_total=4 banker_total=1 natural=false return_cents=10000 bankroll_cents=37250 heat=1 opponent_profit_cents=-10000 reveal_count=5
hand stage=2 hand=5 bet=player bet_cents=5000 winner=player player_total=9 banker_total=0 natural=true return_cents=10000 bankroll_cents=42250 heat=1 opponent_profit_cents=0 reveal_count=5
hand stage=2 hand=6 bet=player bet_cents=10000 winner=player player_total=8 banker_total=6 natural=true return_cents=20000 bankroll_cents=52250 heat=1 opponent_profit_cents=-5000 reveal_count=5
stage_result stage=2 clear=true profit_cents=35000 opponent_profit_cents=-5000 tolerance_cents=15000 bankroll_cents=52250 heat=1 chips=3
stage_reward_rewards=Cool Down
shop_modifiers=vision.dealer-glance
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=52250 heat=0 chips=0 boss=none active_mods=core.opening-tell;vision.dealer-glance
hand stage=3 hand=1 bet=player bet_cents=7500 winner=player player_total=7 banker_total=3 natural=false return_cents=15000 bankroll_cents=59750 heat=0 opponent_profit_cents=-7500 reveal_count=5
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=banker player_total=0 banker_total=9 natural=true return_cents=14625 bankroll_cents=66875 heat=0 opponent_profit_cents=-15000 reveal_count=5
hand stage=3 hand=3 bet=player bet_cents=15000 winner=player player_total=4 banker_total=2 natural=false return_cents=30000 bankroll_cents=81875 heat=0 opponent_profit_cents=-22500 reveal_count=5
hand stage=3 hand=4 bet=banker bet_cents=15000 winner=banker player_total=3 banker_total=4 natural=false return_cents=29250 bankroll_cents=96125 heat=0 opponent_profit_cents=-15375 reveal_count=5
hand stage=3 hand=5 bet=player bet_cents=22500 winner=player player_total=8 banker_total=5 natural=true return_cents=45000 bankroll_cents=118625 heat=0 opponent_profit_cents=-22875 reveal_count=5
hand stage=3 hand=6 bet=banker bet_cents=15000 winner=banker player_total=2 banker_total=4 natural=false return_cents=29250 bankroll_cents=132875 heat=0 opponent_profit_cents=-30375 reveal_count=5
hand stage=3 hand=7 bet=tie bet_cents=25000 winner=tie player_total=7 banker_total=7 natural=false return_cents=275000 bankroll_cents=382875 heat=0 opponent_profit_cents=-30375 reveal_count=5
stage_result stage=3 clear=true profit_cents=330625 opponent_profit_cents=-30375 tolerance_cents=15000 bankroll_cents=382875 heat=0 chips=2
stage_reward_rewards=Rare Modifier Voucher
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=382875 heat=0 chips=1 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.opening-tell
hand stage=4 hand=1 bet=banker bet_cents=40000 winner=banker player_total=3 banker_total=8 natural=true return_cents=78000 bankroll_cents=420875 heat=0 opponent_profit_cents=19000 reveal_count=5
hand stage=4 hand=2 bet=banker bet_cents=40000 winner=banker player_total=2 banker_total=7 natural=false return_cents=78000 bankroll_cents=458875 heat=0 opponent_profit_cents=38000 reveal_count=5
hand stage=4 hand=3 bet=banker bet_cents=40000 winner=banker player_total=5 banker_total=7 natural=false return_cents=78000 bankroll_cents=496875 heat=0 opponent_profit_cents=57000 reveal_count=5
hand stage=4 hand=4 bet=player bet_cents=20000 winner=banker player_total=4 banker_total=5 natural=false return_cents=0 bankroll_cents=476875 heat=0 opponent_profit_cents=47000 reveal_count=5
hand stage=4 hand=5 bet=player bet_cents=20000 winner=banker player_total=2 banker_total=6 natural=false return_cents=0 bankroll_cents=456875 heat=0 opponent_profit_cents=66000 reveal_count=5
hand stage=4 hand=6 bet=player bet_cents=40000 winner=player player_total=9 banker_total=0 natural=true return_cents=80000 bankroll_cents=496875 heat=0 opponent_profit_cents=46000 reveal_count=5
hand stage=4 hand=7 bet=banker bet_cents=40000 winner=banker player_total=4 banker_total=7 natural=false return_cents=78000 bankroll_cents=534875 heat=0 opponent_profit_cents=65000 reveal_count=5
hand stage=4 hand=8 bet=player bet_cents=40000 winner=player player_total=7 banker_total=1 natural=false return_cents=80000 bankroll_cents=574875 heat=0 opponent_profit_cents=55000 reveal_count=5
stage_result stage=4 clear=true profit_cents=192000 opponent_profit_cents=55000 tolerance_cents=5000 bankroll_cents=574875 heat=0 chips=4
stage_reward_rewards=Ante Kickback
shop_modifiers=banker.dealers-nod
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=584875 heat=0 chips=0 boss=Pit Boss active_mods=core.opening-tell;vision.dealer-glance;core.opening-tell;banker.dealers-nod
hand stage=5 hand=1 bet=tie bet_cents=60000 winner=tie player_total=8 banker_total=8 natural=true return_cents=540000 bankroll_cents=1064875 heat=1 opponent_profit_cents=0 reveal_count=5
hand stage=5 hand=2 bet=player bet_cents=30000 winner=banker player_total=3 banker_total=4 natural=false return_cents=0 bankroll_cents=1034875 heat=1 opponent_profit_cents=-15000 reveal_count=5
hand stage=5 hand=3 bet=player bet_cents=30000 winner=player player_total=7 banker_total=0 natural=false return_cents=60000 bankroll_cents=1064875 heat=1 opponent_profit_cents=-30000 reveal_count=5
hand stage=5 hand=4 bet=player bet_cents=60000 winner=player player_total=9 banker_total=4 natural=true return_cents=120000 bankroll_cents=1124875 heat=2 opponent_profit_cents=-12000 reveal_count=5
hand stage=5 hand=5 bet=player bet_cents=60000 winner=player player_total=7 banker_total=6 natural=false return_cents=120000 bankroll_cents=1184875 heat=4 opponent_profit_cents=21000 reveal_count=5
hand stage=5 hand=6 bet=banker bet_cents=60000 winner=banker player_total=3 banker_total=5 natural=false return_cents=117000 bankroll_cents=1241875 heat=5 opponent_profit_cents=6000 reveal_count=5
hand stage=5 hand=7 bet=banker bet_cents=60000 winner=banker player_total=2 banker_total=9 natural=true return_cents=117000 bankroll_cents=1298875 heat=6 opponent_profit_cents=20250 reveal_count=5
hand stage=5 hand=8 bet=banker bet_cents=60000 winner=banker player_total=3 banker_total=6 natural=false return_cents=117000 bankroll_cents=1355875 heat=7 opponent_profit_cents=37500 reveal_count=5
stage_result stage=5 clear=true profit_cents=771000 opponent_profit_cents=37500 tolerance_cents=0 bankroll_cents=1355875 heat=7 chips=6
boss_reward_rewards=Player Consortium
shop_modifiers=vision.dealer-glance
stage_start stage=6 hands=8 ante_cents=20000 min_bet_cents=20000 bankroll_cents=1355875 heat=7 chips=2 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.opening-tell;banker.dealers-nod
hand stage=6 hand=1 bet=banker bet_cents=80000 winner=banker player_total=8 banker_total=9 natural=true return_cents=156000 bankroll_cents=1431875 heat=7 opponent_profit_cents=-20000 reveal_count=5
hand stage=6 hand=2 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=8 natural=false return_cents=78000 bankroll_cents=1469875 heat=7 opponent_profit_cents=-40000 reveal_count=5
hand stage=6 hand=3 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=9 natural=false return_cents=78000 bankroll_cents=1507875 heat=7 opponent_profit_cents=-60000 reveal_count=5
hand stage=6 hand=4 bet=banker bet_cents=80000 winner=banker player_total=5 banker_total=8 natural=true return_cents=156000 bankroll_cents=1583875 heat=7 opponent_profit_cents=-80000 reveal_count=5
hand stage=6 hand=5 bet=banker bet_cents=80000 winner=banker player_total=5 banker_total=6 natural=false return_cents=156000 bankroll_cents=1659875 heat=7 opponent_profit_cents=-120000 reveal_count=5
hand stage=6 hand=6 bet=banker bet_cents=80000 winner=banker player_total=2 banker_total=6 natural=false return_cents=156000 bankroll_cents=1735875 heat=7 opponent_profit_cents=-140000 reveal_count=5
hand stage=6 hand=7 bet=banker bet_cents=80000 winner=banker player_total=3 banker_total=6 natural=false return_cents=156000 bankroll_cents=1811875 heat=7 opponent_profit_cents=-160000 reveal_count=5
hand stage=6 hand=8 bet=player bet_cents=80000 winner=player player_total=7 banker_total=6 natural=false return_cents=160000 bankroll_cents=1891875 heat=7 opponent_profit_cents=-140000 reveal_count=5
stage_result stage=6 clear=true profit_cents=536000 opponent_profit_cents=-140000 tolerance_cents=0 bankroll_cents=1891875 heat=7 chips=7
stage_reward_rewards=Attachment Case
shop_modifiers=economy.interest-ledger;pair.pair-hunter
stage_start stage=7 hands=9 ante_cents=30000 min_bet_cents=30000 bankroll_cents=1902375 heat=7 chips=2 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.opening-tell;banker.dealers-nod;economy.interest-ledger
hand stage=7 hand=1 bet=player bet_cents=60000 winner=banker player_total=5 banker_total=6 natural=false return_cents=0 bankroll_cents=1842375 heat=7 opponent_profit_cents=28500 reveal_count=5
hand stage=7 hand=2 bet=banker bet_cents=120000 winner=banker player_total=0 banker_total=8 natural=true return_cents=234000 bankroll_cents=1956375 heat=7 opponent_profit_cents=57000 reveal_count=5
hand stage=7 hand=3 bet=banker bet_cents=120000 winner=banker player_total=1 banker_total=8 natural=true return_cents=234000 bankroll_cents=2070375 heat=7 opponent_profit_cents=142500 reveal_count=5
hand stage=7 hand=4 bet=banker bet_cents=60000 winner=banker player_total=0 banker_total=1 natural=false return_cents=117000 bankroll_cents=2127375 heat=7 opponent_profit_cents=171000 reveal_count=5
hand stage=7 hand=5 bet=banker bet_cents=120000 winner=banker player_total=4 banker_total=9 natural=true return_cents=234000 bankroll_cents=2241375 heat=7 opponent_profit_cents=199500 reveal_count=5
hand stage=7 hand=6 bet=player bet_cents=60000 winner=player player_total=4 banker_total=1 natural=false return_cents=120000 bankroll_cents=2301375 heat=7 opponent_profit_cents=289500 reveal_count=5
hand stage=7 hand=7 bet=player bet_cents=120000 winner=player player_total=9 banker_total=8 natural=true return_cents=240000 bankroll_cents=2421375 heat=7 opponent_profit_cents=259500 reveal_count=5
hand stage=7 hand=8 bet=player bet_cents=60000 winner=player player_total=7 banker_total=2 natural=false return_cents=120000 bankroll_cents=2481375 heat=7 opponent_profit_cents=229500 reveal_count=5
hand stage=7 hand=9 bet=player bet_cents=120000 winner=player player_total=8 banker_total=0 natural=true return_cents=240000 bankroll_cents=2601375 heat=7 opponent_profit_cents=319500 reveal_count=5
stage_result stage=7 clear=true profit_cents=709500 opponent_profit_cents=319500 tolerance_cents=240000 bankroll_cents=2601375 heat=7 chips=13
stage_reward_rewards=Table Comp
shop_modifiers=banker.dealers-nod;core.opening-tell
stage_start stage=8 hands=10 ante_cents=40000 min_bet_cents=40000 bankroll_cents=2820375 heat=7 chips=5 boss=The Inspector active_mods=core.opening-tell;vision.dealer-glance;core.opening-tell;banker.dealers-nod;economy.interest-ledger
hand stage=8 hand=1 bet=player bet_cents=175000 winner=player player_total=8 banker_total=6 natural=false return_cents=350000 bankroll_cents=2995375 heat=9 opponent_profit_cents=120000 reveal_count=5
hand stage=8 hand=2 bet=banker bet_cents=175000 winner=banker player_total=6 banker_total=9 natural=true return_cents=341250 bankroll_cents=3161625 heat=9 opponent_profit_cents=80000 reveal_count=5
hand stage=8 hand=3 bet=player bet_cents=40000 winner=player player_total=5 banker_total=0 natural=false return_cents=80000 bankroll_cents=3201625 heat=9 opponent_profit_cents=40000 reveal_count=5
hand stage=8 hand=4 bet=player bet_cents=40000 winner=banker player_total=5 banker_total=9 natural=false return_cents=0 bankroll_cents=3161625 heat=9 opponent_profit_cents=78000 reveal_count=5
hand stage=8 hand=5 bet=player bet_cents=40000 winner=banker player_total=5 banker_total=6 natural=false return_cents=0 bankroll_cents=3121625 heat=9 opponent_profit_cents=116000 reveal_count=5
hand stage=8 hand=6 bet=player bet_cents=175000 winner=player player_total=6 banker_total=4 natural=false return_cents=350000 bankroll_cents=3296625 heat=9 opponent_profit_cents=156000 reveal_count=5
hand stage=8 hand=7 bet=banker bet_cents=175000 winner=banker player_total=4 banker_total=5 natural=false return_cents=341250 bankroll_cents=3462875 heat=9 opponent_profit_cents=194000 reveal_count=5
hand stage=8 hand=8 bet=player bet_cents=40000 winner=banker player_total=1 banker_total=6 natural=false return_cents=0 bankroll_cents=3422875 heat=9 opponent_profit_cents=232000 reveal_count=5
hand stage=8 hand=9 bet=tie bet_cents=175000 winner=tie player_total=6 banker_total=6 natural=false return_cents=1575000 bankroll_cents=4822875 heat=9 opponent_profit_cents=232000 reveal_count=5
hand stage=8 hand=10 bet=banker bet_cents=40000 winner=player player_total=2 banker_total=0 natural=false return_cents=0 bankroll_cents=4782875 heat=9 opponent_profit_cents=272000 reveal_count=5
stage_result stage=8 clear=true profit_cents=2136500 opponent_profit_cents=272000 tolerance_cents=0 bankroll_cents=4782875 heat=9 chips=11
boss_reward_rewards=Banker Consortium
shop_modifiers=vision.soft-peek
stage_start stage=9 hands=10 ante_cents=60000 min_bet_cents=60000 bankroll_cents=5043875 heat=9 chips=8 boss=none active_mods=core.opening-tell;vision.dealer-glance;core.opening-tell;banker.dealers-nod;economy.interest-ledger
hand stage=9 hand=1 bet=player bet_cents=250000 winner=player player_total=9 banker_total=0 natural=true return_cents=500000 bankroll_cents=5293875 heat=9 opponent_profit_cents=-60000 reveal_count=5
hand stage=9 hand=2 bet=banker bet_cents=250000 winner=banker player_total=3 banker_total=6 natural=false return_cents=487500 bankroll_cents=5531375 heat=9 opponent_profit_cents=-3000 reveal_count=5
hand stage=9 hand=3 bet=banker bet_cents=250000 winner=banker player_total=4 banker_total=8 natural=true return_cents=487500 bankroll_cents=5768875 heat=9 opponent_profit_cents=54000 reveal_count=5
hand stage=9 hand=4 bet=banker bet_cents=250000 winner=banker player_total=5 banker_total=8 natural=true return_cents=487500 bankroll_cents=6006375 heat=9 opponent_profit_cents=111000 reveal_count=5
hand stage=9 hand=5 bet=player bet_cents=250000 winner=player player_total=9 banker_total=3 natural=true return_cents=500000 bankroll_cents=6256375 heat=9 opponent_profit_cents=231000 reveal_count=5
hand stage=9 hand=6 bet=player bet_cents=250000 winner=player player_total=9 banker_total=7 natural=true return_cents=500000 bankroll_cents=6506375 heat=9 opponent_profit_cents=171000 reveal_count=5
hand stage=9 hand=7 bet=banker bet_cents=250000 winner=banker player_total=0 banker_total=7 natural=false return_cents=487500 bankroll_cents=6743875 heat=9 opponent_profit_cents=228000 reveal_count=5
hand stage=9 hand=8 bet=player bet_cents=250000 winner=player player_total=7 banker_total=1 natural=false return_cents=500000 bankroll_cents=6993875 heat=9 opponent_profit_cents=168000 reveal_count=5
hand stage=9 hand=9 bet=tie bet_cents=250000 winner=tie player_total=9 banker_total=9 natural=true return_cents=2250000 bankroll_cents=8993875 heat=9 opponent_profit_cents=168000 reveal_count=5
hand stage=9 hand=10 bet=tie bet_cents=250000 winner=tie player_total=8 banker_total=8 natural=true return_cents=2250000 bankroll_cents=10993875 heat=9 opponent_profit_cents=168000 reveal_count=5
stage_result stage=9 clear=true profit_cents=6211000 opponent_profit_cents=168000 tolerance_cents=0 bankroll_cents=10993875 heat=9 chips=13
stage_reward_rewards=High Table Cut
stage_start stage=10 hands=12 ante_cents=80000 min_bet_cents=80000 bankroll_cents=11781875 heat=9 chips=12 boss=The House active_mods=core.opening-tell;vision.dealer-glance;core.opening-tell;banker.dealers-nod;economy.interest-ledger
hand stage=10 hand=1 bet=player bet_cents=80000 winner=player player_total=6 banker_total=0 natural=false return_cents=160000 bankroll_cents=11861875 heat=10 opponent_profit_cents=240000 reveal_count=5
stage_result stage=10 clear=false profit_cents=748000 opponent_profit_cents=240000 tolerance_cents=0 bankroll_cents=11861875 heat=10 chips=12
finish completed=false final_stage=10 failure=stage_10_heat ending_bankroll_cents=11861875 highest_bankroll_cents=11861875 heat=10 owned_mods=core.opening-tell;vision.dealer-glance;core.opening-tell;banker.dealers-nod;economy.interest-ledger
```

