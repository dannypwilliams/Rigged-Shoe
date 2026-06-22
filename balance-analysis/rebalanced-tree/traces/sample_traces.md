# Deterministic Trace Samples

These traces are compact examples generated from the same root seed as the aggregate study. They are diagnostic examples, not additional aggregate samples.

## representative / random / 1145657687388359458

- Completed: no; final stage: 2; failure: `stage_2_bankroll_minimum`.
- Ending bankroll: $27; heat: 1; hands: 11; build: `core.opening-tell|player.reversal-read`.
- Rewards: Chip Runner.
- Modifiers picked: player.reversal-read.

```text
start seed=1145657687388359458 policy=random contact=contact.opening-tell bankroll_cents=24000 chips=3 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=24000 heat=0 chips=3 boss=none active_mods=core.opening-tell
hand stage=1 hand=1 bet=player bet_cents=2500 winner=banker player_total=1 banker_total=8 natural=true return_cents=0 bankroll_cents=21500 heat=0 opponent_profit_cents=2375 reveal_count=1
hand stage=1 hand=2 bet=tie bet_cents=2500 winner=player player_total=6 banker_total=2 natural=false return_cents=0 bankroll_cents=19000 heat=0 opponent_profit_cents=-125 reveal_count=1
hand stage=1 hand=3 bet=tie bet_cents=2500 winner=banker player_total=2 banker_total=7 natural=false return_cents=0 bankroll_cents=16500 heat=0 opponent_profit_cents=-2625 reveal_count=1
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=player player_total=7 banker_total=4 natural=false return_cents=0 bankroll_cents=14000 heat=0 opponent_profit_cents=-5125 reveal_count=1
hand stage=1 hand=5 bet=tie bet_cents=2500 winner=banker player_total=8 banker_total=9 natural=true return_cents=0 bankroll_cents=11500 heat=0 opponent_profit_cents=-10125 reveal_count=1
stage_result stage=1 clear=true profit_cents=-12500 opponent_profit_cents=-10125 tolerance_cents=22500 bankroll_cents=11500 heat=1 chips=5
stage_reward_rewards=Chip Runner
shop_modifiers=player.reversal-read
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=11500 heat=1 chips=3 boss=none active_mods=core.opening-tell;player.reversal-read
hand stage=2 hand=1 bet=tie bet_cents=5000 winner=banker player_total=0 banker_total=6 natural=false return_cents=0 bankroll_cents=6500 heat=1 opponent_profit_cents=5000 reveal_count=1
hand stage=2 hand=2 bet=player bet_cents=5000 winner=player player_total=9 banker_total=3 natural=true return_cents=10000 bankroll_cents=12100 heat=1 opponent_profit_cents=0 reveal_count=1
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=7 natural=false return_cents=0 bankroll_cents=7100 heat=1 opponent_profit_cents=-5000 reveal_count=1
hand stage=2 hand=4 bet=player bet_cents=5000 winner=player player_total=6 banker_total=2 natural=false return_cents=10000 bankroll_cents=12700 heat=1 opponent_profit_cents=-10000 reveal_count=1
hand stage=2 hand=5 bet=player bet_cents=5000 winner=banker player_total=2 banker_total=6 natural=false return_cents=0 bankroll_cents=7700 heat=1 opponent_profit_cents=-20000 reveal_count=1
hand stage=2 hand=6 bet=tie bet_cents=5000 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=2700 heat=1 opponent_profit_cents=-25000 reveal_count=1
stage_result stage=2 clear=false profit_cents=-8800 opponent_profit_cents=-25000 tolerance_cents=25000 bankroll_cents=2700 heat=1 chips=3
finish completed=false final_stage=2 failure=stage_2_bankroll_minimum ending_bankroll_cents=2700 highest_bankroll_cents=21500 heat=1 owned_mods=core.opening-tell;player.reversal-read
```

## representative / novice / 16179982617195473639

- Completed: no; final stage: 10; failure: `stage_10_heat`.
- Ending bankroll: $8,921.25; heat: 10; hands: 75; build: `banker.banco-press|banker.commission-dodge|core.lucky-chip|economy.interest-ledger|player.player-tempo`.
- Rewards: Chip Runner, Rare Modifier Voucher, Chip Runner, High Table Cut, Capstone Invitation, High Table Cut, Ante Kickback, Capstone Invitation, High Table Cut.
- Modifiers picked: banker.commission-dodge, economy.interest-ledger, player.player-tempo, banker.banco-press, tie.equalizer, economy.interest-ledger.

```text
start seed=16179982617195473639 policy=novice contact=contact.lucky-chip bankroll_cents=25000 chips=4 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25000 heat=0 chips=4 boss=none active_mods=core.lucky-chip
hand stage=1 hand=1 bet=banker bet_cents=2500 winner=player player_total=4 banker_total=0 natural=false return_cents=0 bankroll_cents=22500 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=2500 winner=banker player_total=3 banker_total=9 natural=false return_cents=4875 bankroll_cents=24875 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=banker player_total=4 banker_total=6 natural=false return_cents=4875 bankroll_cents=27250 heat=0 opponent_profit_cents=-7500 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=banker player_total=2 banker_total=8 natural=true return_cents=4875 bankroll_cents=29625 heat=0 opponent_profit_cents=-5125 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=banker player_total=6 banker_total=7 natural=false return_cents=4875 bankroll_cents=32000 heat=0 opponent_profit_cents=-10125 reveal_count=0
stage_result stage=1 clear=true profit_cents=7000 opponent_profit_cents=-10125 tolerance_cents=22500 bankroll_cents=32000 heat=0 chips=8
stage_reward_rewards=Chip Runner
shop_modifiers=banker.commission-dodge
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=32000 heat=0 chips=7 boss=none active_mods=core.lucky-chip;banker.commission-dodge
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=7 natural=false return_cents=10000 bankroll_cents=37250 heat=0 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=7 natural=true return_cents=0 bankroll_cents=32250 heat=0 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=banker player_total=5 banker_total=9 natural=true return_cents=10000 bankroll_cents=37500 heat=0 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=player player_total=7 banker_total=2 natural=false return_cents=0 bankroll_cents=32500 heat=0 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=27500 heat=0 opponent_profit_cents=10000 reveal_count=0
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=banker player_total=3 banker_total=6 natural=false return_cents=10000 bankroll_cents=32750 heat=0 opponent_profit_cents=15000 reveal_count=0
stage_result stage=2 clear=true profit_cents=750 opponent_profit_cents=15000 tolerance_cents=25000 bankroll_cents=32750 heat=0 chips=11
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=economy.interest-ledger
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=35375 heat=0 chips=9 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=27875 heat=0 opponent_profit_cents=-7500 reveal_count=0
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=banker player_total=1 banker_total=2 natural=false return_cents=14625 bankroll_cents=35375 heat=0 opponent_profit_cents=-15000 reveal_count=0
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=8 natural=true return_cents=14625 bankroll_cents=42875 heat=0 opponent_profit_cents=-7875 reveal_count=0
hand stage=3 hand=4 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=9 natural=false return_cents=14625 bankroll_cents=50375 heat=0 opponent_profit_cents=-750 reveal_count=0
hand stage=3 hand=5 bet=banker bet_cents=7500 winner=player player_total=9 banker_total=0 natural=false return_cents=0 bankroll_cents=42875 heat=0 opponent_profit_cents=-8250 reveal_count=0
hand stage=3 hand=6 bet=banker bet_cents=7500 winner=banker player_total=3 banker_total=7 natural=false return_cents=14625 bankroll_cents=50375 heat=0 opponent_profit_cents=-15750 reveal_count=0
hand stage=3 hand=7 bet=banker bet_cents=7500 winner=banker player_total=7 banker_total=9 natural=true return_cents=14625 bankroll_cents=57875 heat=0 opponent_profit_cents=-8625 reveal_count=0
stage_result stage=3 clear=true profit_cents=25125 opponent_profit_cents=-8625 tolerance_cents=37500 bankroll_cents=57875 heat=0 chips=13
stage_reward_rewards=Chip Runner
shop_modifiers=player.player-tempo
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=61375 heat=0 chips=11 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;player.player-tempo
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=player player_total=6 banker_total=3 natural=false return_cents=0 bankroll_cents=51375 heat=0 opponent_profit_cents=-20000 reveal_count=0
hand stage=4 hand=2 bet=banker bet_cents=10000 winner=banker player_total=1 banker_total=7 natural=false return_cents=19500 bankroll_cents=61375 heat=0 opponent_profit_cents=-1000 reveal_count=0
hand stage=4 hand=3 bet=banker bet_cents=10000 winner=player player_total=8 banker_total=5 natural=true return_cents=0 bankroll_cents=51375 heat=0 opponent_profit_cents=-21000 reveal_count=0
hand stage=4 hand=4 bet=banker bet_cents=10000 winner=banker player_total=8 banker_total=9 natural=true return_cents=19500 bankroll_cents=61375 heat=0 opponent_profit_cents=-31000 reveal_count=0
hand stage=4 hand=5 bet=banker bet_cents=10000 winner=player player_total=8 banker_total=3 natural=true return_cents=0 bankroll_cents=51375 heat=0 opponent_profit_cents=-51000 reveal_count=0
hand stage=4 hand=6 bet=banker bet_cents=10000 winner=banker player_total=5 banker_total=8 natural=true return_cents=19500 bankroll_cents=61375 heat=0 opponent_profit_cents=-32000 reveal_count=0
hand stage=4 hand=7 bet=banker bet_cents=10000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=51375 heat=0 opponent_profit_cents=-52000 reveal_count=0
hand stage=4 hand=8 bet=banker bet_cents=10000 winner=banker player_total=4 banker_total=6 natural=false return_cents=19500 bankroll_cents=61375 heat=0 opponent_profit_cents=-62000 reveal_count=0
stage_result stage=4 clear=true profit_cents=3500 opponent_profit_cents=-62000 tolerance_cents=80000 bankroll_cents=61375 heat=0 chips=15
stage_reward_rewards=High Table Cut
shop_modifiers=banker.banco-press
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=106625 heat=0 chips=11 boss=Pit Boss active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;player.player-tempo;banker.banco-press
hand stage=5 hand=1 bet=banker bet_cents=15000 winner=banker player_total=1 banker_total=6 natural=false return_cents=29250 bankroll_cents=129125 heat=0 opponent_profit_cents=14250 reveal_count=0
hand stage=5 hand=2 bet=banker bet_cents=15000 winner=player player_total=9 banker_total=4 natural=false return_cents=0 bankroll_cents=114125 heat=0 opponent_profit_cents=-750 reveal_count=0
hand stage=5 hand=3 bet=banker bet_cents=15000 winner=banker player_total=0 banker_total=9 natural=true return_cents=29250 bankroll_cents=136625 heat=0 opponent_profit_cents=-12750 reveal_count=0
hand stage=5 hand=4 bet=banker bet_cents=15000 winner=banker player_total=1 banker_total=4 natural=false return_cents=29250 bankroll_cents=159125 heat=1 opponent_profit_cents=4500 reveal_count=0
hand stage=5 hand=5 bet=banker bet_cents=15000 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=144125 heat=1 opponent_profit_cents=-22500 reveal_count=0
hand stage=5 hand=6 bet=banker bet_cents=15000 winner=player player_total=9 banker_total=4 natural=false return_cents=0 bankroll_cents=129125 heat=1 opponent_profit_cents=-4500 reveal_count=0
hand stage=5 hand=7 bet=banker bet_cents=15000 winner=player player_total=8 banker_total=7 natural=false return_cents=0 bankroll_cents=114125 heat=1 opponent_profit_cents=13500 reveal_count=0
hand stage=5 hand=8 bet=banker bet_cents=15000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=99125 heat=2 opponent_profit_cents=31500 reveal_count=0
stage_result stage=5 clear=true profit_cents=-2250 opponent_profit_cents=31500 tolerance_cents=105000 bankroll_cents=99125 heat=4 chips=18
boss_reward_rewards=Capstone Invitation
shop_modifiers=tie.equalizer
stage_start stage=6 hands=8 ante_cents=20000 min_bet_cents=20000 bankroll_cents=106125 heat=4 chips=13 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;player.player-tempo;banker.banco-press
hand stage=6 hand=1 bet=banker bet_cents=20000 winner=banker player_total=5 banker_total=6 natural=false return_cents=39000 bankroll_cents=136125 heat=4 opponent_profit_cents=19000 reveal_count=0
hand stage=6 hand=2 bet=banker bet_cents=20000 winner=banker player_total=0 banker_total=3 natural=false return_cents=39000 bankroll_cents=166125 heat=4 opponent_profit_cents=-1000 reveal_count=0
hand stage=6 hand=3 bet=banker bet_cents=20000 winner=player player_total=9 banker_total=1 natural=true return_cents=0 bankroll_cents=146125 heat=4 opponent_profit_cents=19000 reveal_count=0
hand stage=6 hand=4 bet=banker bet_cents=20000 winner=banker player_total=2 banker_total=7 natural=false return_cents=39000 bankroll_cents=176125 heat=4 opponent_profit_cents=38000 reveal_count=0
hand stage=6 hand=5 bet=banker bet_cents=20000 winner=banker player_total=0 banker_total=6 natural=false return_cents=39000 bankroll_cents=206125 heat=4 opponent_profit_cents=-2000 reveal_count=0
hand stage=6 hand=6 bet=banker bet_cents=20000 winner=banker player_total=4 banker_total=6 natural=false return_cents=39000 bankroll_cents=236125 heat=4 opponent_profit_cents=-22000 reveal_count=0
hand stage=6 hand=7 bet=banker bet_cents=20000 winner=tie player_total=6 banker_total=6 natural=false return_cents=20000 bankroll_cents=236125 heat=4 opponent_profit_cents=-22000 reveal_count=0
hand stage=6 hand=8 bet=banker bet_cents=20000 winner=tie player_total=4 banker_total=4 natural=false return_cents=20000 bankroll_cents=236125 heat=4 opponent_profit_cents=-22000 reveal_count=0
stage_result stage=6 clear=true profit_cents=137000 opponent_profit_cents=-22000 tolerance_cents=140000 bankroll_cents=236125 heat=4 chips=18
stage_reward_rewards=High Table Cut
shop_modifiers=economy.interest-ledger
stage_start stage=7 hands=9 ante_cents=30000 min_bet_cents=30000 bankroll_cents=334125 heat=4 chips=15 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;player.player-tempo;banker.banco-press
hand stage=7 hand=1 bet=banker bet_cents=30000 winner=banker player_total=3 banker_total=8 natural=true return_cents=58500 bankroll_cents=379125 heat=4 opponent_profit_cents=28500 reveal_count=0
hand stage=7 hand=2 bet=banker bet_cents=30000 winner=player player_total=7 banker_total=2 natural=false return_cents=0 bankroll_cents=349125 heat=4 opponent_profit_cents=-1500 reveal_count=0
hand stage=7 hand=3 bet=banker bet_cents=30000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=319125 heat=4 opponent_profit_cents=88500 reveal_count=0
hand stage=7 hand=4 bet=banker bet_cents=30000 winner=banker player_total=0 banker_total=4 natural=false return_cents=58500 bankroll_cents=364125 heat=4 opponent_profit_cents=117000 reveal_count=0
hand stage=7 hand=5 bet=banker bet_cents=30000 winner=banker player_total=3 banker_total=4 natural=false return_cents=58500 bankroll_cents=409125 heat=4 opponent_profit_cents=145500 reveal_count=0
hand stage=7 hand=6 bet=banker bet_cents=30000 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=379125 heat=4 opponent_profit_cents=235500 reveal_count=0
hand stage=7 hand=7 bet=banker bet_cents=30000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=349125 heat=4 opponent_profit_cents=205500 reveal_count=0
hand stage=7 hand=8 bet=banker bet_cents=30000 winner=banker player_total=4 banker_total=8 natural=true return_cents=58500 bankroll_cents=394125 heat=4 opponent_profit_cents=234000 reveal_count=0
hand stage=7 hand=9 bet=banker bet_cents=30000 winner=player player_total=9 banker_total=4 natural=true return_cents=0 bankroll_cents=364125 heat=4 opponent_profit_cents=324000 reveal_count=0
stage_result stage=7 clear=true profit_cents=48000 opponent_profit_cents=324000 tolerance_cents=360000 bankroll_cents=364125 heat=4 chips=19
stage_reward_rewards=Ante Kickback
stage_start stage=8 hands=10 ante_cents=40000 min_bet_cents=40000 bankroll_cents=448125 heat=4 chips=19 boss=The Inspector active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;player.player-tempo;banker.banco-press
hand stage=8 hand=1 bet=banker bet_cents=40000 winner=player player_total=9 banker_total=3 natural=false return_cents=0 bankroll_cents=408125 heat=4 opponent_profit_cents=-40000 reveal_count=0
hand stage=8 hand=2 bet=banker bet_cents=40000 winner=player player_total=9 banker_total=0 natural=true return_cents=0 bankroll_cents=368125 heat=4 opponent_profit_cents=0 reveal_count=0
hand stage=8 hand=3 bet=banker bet_cents=40000 winner=tie player_total=7 banker_total=7 natural=false return_cents=40000 bankroll_cents=368125 heat=4 opponent_profit_cents=0 reveal_count=0
hand stage=8 hand=4 bet=banker bet_cents=40000 winner=player player_total=9 banker_total=7 natural=false return_cents=0 bankroll_cents=328125 heat=4 opponent_profit_cents=-40000 reveal_count=0
hand stage=8 hand=5 bet=banker bet_cents=40000 winner=player player_total=9 banker_total=5 natural=true return_cents=0 bankroll_cents=288125 heat=4 opponent_profit_cents=-80000 reveal_count=0
hand stage=8 hand=6 bet=banker bet_cents=40000 winner=banker player_total=5 banker_total=9 natural=true return_cents=78000 bankroll_cents=348125 heat=4 opponent_profit_cents=-120000 reveal_count=0
hand stage=8 hand=7 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=308125 heat=4 opponent_profit_cents=-160000 reveal_count=0
hand stage=8 hand=8 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=268125 heat=4 opponent_profit_cents=-200000 reveal_count=0
hand stage=8 hand=9 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=228125 heat=4 opponent_profit_cents=-240000 reveal_count=0
hand stage=8 hand=10 bet=banker bet_cents=40000 winner=player player_total=6 banker_total=3 natural=false return_cents=0 bankroll_cents=188125 heat=4 opponent_profit_cents=-200000 reveal_count=0
stage_result stage=8 clear=true profit_cents=-236000 opponent_profit_cents=-200000 tolerance_cents=400000 bankroll_cents=188125 heat=6 chips=26
boss_reward_rewards=Capstone Invitation
stage_start stage=9 hands=10 ante_cents=60000 min_bet_cents=60000 bankroll_cents=224125 heat=6 chips=26 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;player.player-tempo;banker.banco-press
hand stage=9 hand=1 bet=banker bet_cents=60000 winner=banker player_total=0 banker_total=5 natural=false return_cents=117000 bankroll_cents=314125 heat=6 opponent_profit_cents=57000 reveal_count=0
hand stage=9 hand=2 bet=banker bet_cents=60000 winner=player player_total=9 banker_total=0 natural=true return_cents=0 bankroll_cents=254125 heat=8 opponent_profit_cents=117000 reveal_count=0
hand stage=9 hand=3 bet=banker bet_cents=60000 winner=banker player_total=5 banker_total=7 natural=false return_cents=117000 bankroll_cents=344125 heat=8 opponent_profit_cents=174000 reveal_count=0
hand stage=9 hand=4 bet=banker bet_cents=60000 winner=banker player_total=5 banker_total=8 natural=true return_cents=117000 bankroll_cents=434125 heat=8 opponent_profit_cents=231000 reveal_count=0
hand stage=9 hand=5 bet=banker bet_cents=60000 winner=banker player_total=8 banker_total=9 natural=false return_cents=117000 bankroll_cents=524125 heat=8 opponent_profit_cents=111000 reveal_count=0
hand stage=9 hand=6 bet=banker bet_cents=60000 winner=banker player_total=5 banker_total=6 natural=false return_cents=117000 bankroll_cents=614125 heat=8 opponent_profit_cents=168000 reveal_count=0
hand stage=9 hand=7 bet=banker bet_cents=60000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=554125 heat=8 opponent_profit_cents=108000 reveal_count=0
hand stage=9 hand=8 bet=banker bet_cents=60000 winner=banker player_total=4 banker_total=8 natural=true return_cents=117000 bankroll_cents=644125 heat=8 opponent_profit_cents=165000 reveal_count=0
hand stage=9 hand=9 bet=banker bet_cents=60000 winner=player player_total=9 banker_total=0 natural=false return_cents=0 bankroll_cents=584125 heat=8 opponent_profit_cents=105000 reveal_count=0
hand stage=9 hand=10 bet=banker bet_cents=60000 winner=player player_total=7 banker_total=5 natural=false return_cents=0 bankroll_cents=524125 heat=8 opponent_profit_cents=225000 reveal_count=0
stage_result stage=9 clear=true profit_cents=336000 opponent_profit_cents=225000 tolerance_cents=600000 bankroll_cents=524125 heat=8 chips=32
stage_reward_rewards=High Table Cut
stage_start stage=10 hands=12 ante_cents=80000 min_bet_cents=80000 bankroll_cents=812125 heat=8 chips=32 boss=The House active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;player.player-tempo;banker.banco-press
hand stage=10 hand=1 bet=banker bet_cents=80000 winner=player player_total=6 banker_total=5 natural=false return_cents=0 bankroll_cents=732125 heat=9 opponent_profit_cents=-80000 reveal_count=0
hand stage=10 hand=2 bet=banker bet_cents=80000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=652125 heat=9 opponent_profit_cents=-160000 reveal_count=0
hand stage=10 hand=3 bet=banker bet_cents=80000 winner=banker player_total=1 banker_total=4 natural=false return_cents=156000 bankroll_cents=772125 heat=9 opponent_profit_cents=-24000 reveal_count=0
hand stage=10 hand=4 bet=banker bet_cents=80000 winner=banker player_total=1 banker_total=5 natural=false return_cents=156000 bankroll_cents=892125 heat=10 opponent_profit_cents=112000 reveal_count=0
stage_result stage=10 clear=false profit_cents=128000 opponent_profit_cents=112000 tolerance_cents=800000 bankroll_cents=892125 heat=10 chips=33
finish completed=false final_stage=10 failure=stage_10_heat ending_bankroll_cents=892125 highest_bankroll_cents=892125 heat=10 owned_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;player.player-tempo;banker.banco-press
```

## representative / greedy / 3565109935037220113

- Completed: no; final stage: 10; failure: `stage_10_heat`.
- Ending bankroll: $6,001.25; heat: 10; hands: 79; build: `core.player-surge|heat.soft-footsteps|player.break-pattern|player.player-tempo|player.side-step`.
- Rewards: Rare Modifier Voucher, Chip Runner, Table Comp, Ante Kickback, Capstone Invitation, Ante Kickback, Table Comp, Capstone Invitation, Table Comp.
- Modifiers picked: player.side-step, player.side-step, player.player-tempo, heat.soft-footsteps, banker.commission-dodge, player.punto-insurance, player.punto-insurance, heat.soft-footsteps, player.player-tempo.

```text
start seed=3565109935037220113 policy=greedy contact=contact.player-surge bankroll_cents=25000 chips=3 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25000 heat=0 chips=3 boss=none active_mods=core.player-surge
hand stage=1 hand=1 bet=banker bet_cents=5000 winner=banker player_total=1 banker_total=7 natural=false return_cents=9750 bankroll_cents=29750 heat=0 opponent_profit_cents=2375 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=2 natural=false return_cents=0 bankroll_cents=24750 heat=0 opponent_profit_cents=-125 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=3 natural=true return_cents=0 bankroll_cents=19750 heat=0 opponent_profit_cents=2375 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=banker player_total=6 banker_total=7 natural=false return_cents=4875 bankroll_cents=22125 heat=0 opponent_profit_cents=4750 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=5000 winner=player player_total=1 banker_total=0 natural=false return_cents=0 bankroll_cents=17125 heat=0 opponent_profit_cents=-250 reveal_count=0
stage_result stage=1 clear=true profit_cents=-7875 opponent_profit_cents=-250 tolerance_cents=22500 bankroll_cents=17125 heat=1 chips=5
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=player.side-step
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=17125 heat=1 chips=3 boss=none active_mods=core.player-surge;player.side-step
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=banker player_total=1 banker_total=5 natural=false return_cents=10000 bankroll_cents=22125 heat=1 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=tie player_total=8 banker_total=8 natural=true return_cents=5000 bankroll_cents=22125 heat=1 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=6 natural=true return_cents=0 bankroll_cents=17125 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=8 banker_total=9 natural=true return_cents=10000 bankroll_cents=22125 heat=1 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=tie player_total=1 banker_total=1 natural=false return_cents=5000 bankroll_cents=22125 heat=1 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=17125 heat=1 opponent_profit_cents=0 reveal_count=0
stage_result stage=2 clear=true profit_cents=0 opponent_profit_cents=0 tolerance_cents=25000 bankroll_cents=17125 heat=1 chips=5
stage_reward_rewards=Chip Runner
shop_modifiers=player.side-step
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=17125 heat=1 chips=4 boss=none active_mods=core.player-surge;player.side-step
hand stage=3 hand=1 bet=tie bet_cents=7500 winner=tie player_total=8 banker_total=8 natural=true return_cents=82500 bankroll_cents=92125 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=3 hand=2 bet=tie bet_cents=22500 winner=banker player_total=0 banker_total=7 natural=false return_cents=0 bankroll_cents=69625 heat=1 opponent_profit_cents=-7500 reveal_count=0
hand stage=3 hand=3 bet=tie bet_cents=15000 winner=tie player_total=9 banker_total=9 natural=true return_cents=165000 bankroll_cents=219625 heat=1 opponent_profit_cents=-7500 reveal_count=0
hand stage=3 hand=4 bet=tie bet_cents=25000 winner=player player_total=5 banker_total=3 natural=false return_cents=0 bankroll_cents=194625 heat=1 opponent_profit_cents=-15000 reveal_count=0
hand stage=3 hand=5 bet=tie bet_cents=25000 winner=tie player_total=1 banker_total=1 natural=false return_cents=275000 bankroll_cents=444625 heat=1 opponent_profit_cents=-15000 reveal_count=0
hand stage=3 hand=6 bet=tie bet_cents=25000 winner=tie player_total=5 banker_total=5 natural=false return_cents=275000 bankroll_cents=694625 heat=1 opponent_profit_cents=-15000 reveal_count=0
hand stage=3 hand=7 bet=tie bet_cents=25000 winner=banker player_total=6 banker_total=8 natural=false return_cents=0 bankroll_cents=669625 heat=1 opponent_profit_cents=-7875 reveal_count=0
stage_result stage=3 clear=true profit_cents=652500 opponent_profit_cents=-7875 tolerance_cents=37500 bankroll_cents=669625 heat=1 chips=6
stage_reward_rewards=Table Comp
shop_modifiers=player.player-tempo
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=692125 heat=1 chips=2 boss=none active_mods=core.player-surge;player.side-step;player.player-tempo
hand stage=4 hand=1 bet=banker bet_cents=40000 winner=banker player_total=2 banker_total=5 natural=false return_cents=78000 bankroll_cents=730125 heat=1 opponent_profit_cents=19000 reveal_count=0
hand stage=4 hand=2 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=2 natural=false return_cents=0 bankroll_cents=690125 heat=1 opponent_profit_cents=-1000 reveal_count=0
hand stage=4 hand=3 bet=banker bet_cents=40000 winner=tie player_total=4 banker_total=4 natural=false return_cents=40000 bankroll_cents=690125 heat=1 opponent_profit_cents=-1000 reveal_count=0
hand stage=4 hand=4 bet=banker bet_cents=40000 winner=player player_total=8 banker_total=6 natural=true return_cents=0 bankroll_cents=650125 heat=1 opponent_profit_cents=-11000 reveal_count=0
hand stage=4 hand=5 bet=banker bet_cents=40000 winner=tie player_total=6 banker_total=6 natural=false return_cents=40000 bankroll_cents=650125 heat=1 opponent_profit_cents=-11000 reveal_count=0
hand stage=4 hand=6 bet=banker bet_cents=40000 winner=banker player_total=4 banker_total=6 natural=false return_cents=78000 bankroll_cents=688125 heat=1 opponent_profit_cents=8000 reveal_count=0
hand stage=4 hand=7 bet=banker bet_cents=40000 winner=banker player_total=3 banker_total=8 natural=true return_cents=78000 bankroll_cents=726125 heat=1 opponent_profit_cents=27000 reveal_count=0
hand stage=4 hand=8 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=686125 heat=1 opponent_profit_cents=17000 reveal_count=0
stage_result stage=4 clear=true profit_cents=-6000 opponent_profit_cents=17000 tolerance_cents=80000 bankroll_cents=686125 heat=2 chips=5
stage_reward_rewards=Ante Kickback
shop_modifiers=heat.soft-footsteps
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=706125 heat=2 chips=2 boss=Pit Boss active_mods=core.player-surge;player.side-step;player.player-tempo;heat.soft-footsteps
hand stage=5 hand=1 bet=banker bet_cents=60000 winner=banker player_total=1 banker_total=8 natural=true return_cents=117000 bankroll_cents=763125 heat=1 opponent_profit_cents=-15000 reveal_count=0
hand stage=5 hand=2 bet=banker bet_cents=60000 winner=player player_total=8 banker_total=2 natural=true return_cents=0 bankroll_cents=703125 heat=1 opponent_profit_cents=-30000 reveal_count=0
hand stage=5 hand=3 bet=banker bet_cents=60000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=643125 heat=1 opponent_profit_cents=-12000 reveal_count=0
hand stage=5 hand=4 bet=banker bet_cents=60000 winner=player player_total=9 banker_total=3 natural=false return_cents=0 bankroll_cents=583125 heat=2 opponent_profit_cents=6000 reveal_count=0
hand stage=5 hand=5 bet=banker bet_cents=60000 winner=banker player_total=7 banker_total=9 natural=false return_cents=117000 bankroll_cents=640125 heat=3 opponent_profit_cents=-21000 reveal_count=0
hand stage=5 hand=6 bet=banker bet_cents=60000 winner=banker player_total=1 banker_total=6 natural=false return_cents=117000 bankroll_cents=697125 heat=4 opponent_profit_cents=-3750 reveal_count=0
hand stage=5 hand=7 bet=banker bet_cents=60000 winner=banker player_total=6 banker_total=7 natural=false return_cents=117000 bankroll_cents=754125 heat=5 opponent_profit_cents=13500 reveal_count=0
hand stage=5 hand=8 bet=banker bet_cents=60000 winner=tie player_total=8 banker_total=8 natural=true return_cents=60000 bankroll_cents=754125 heat=6 opponent_profit_cents=16500 reveal_count=0
stage_result stage=5 clear=true profit_cents=48000 opponent_profit_cents=16500 tolerance_cents=105000 bankroll_cents=754125 heat=6 chips=8
boss_reward_rewards=Capstone Invitation
shop_modifiers=banker.commission-dodge
stage_start stage=6 hands=8 ante_cents=20000 min_bet_cents=20000 bankroll_cents=754125 heat=6 chips=5 boss=none active_mods=core.player-surge;player.side-step;player.player-tempo;heat.soft-footsteps;player.break-pattern
hand stage=6 hand=1 bet=banker bet_cents=80000 winner=player player_total=6 banker_total=4 natural=false return_cents=0 bankroll_cents=674125 heat=6 opponent_profit_cents=-20000 reveal_count=0
hand stage=6 hand=2 bet=banker bet_cents=80000 winner=player player_total=1 banker_total=0 natural=false return_cents=0 bankroll_cents=594125 heat=6 opponent_profit_cents=-40000 reveal_count=0
hand stage=6 hand=3 bet=banker bet_cents=80000 winner=banker player_total=1 banker_total=4 natural=false return_cents=156000 bankroll_cents=670125 heat=6 opponent_profit_cents=-21000 reveal_count=0
hand stage=6 hand=4 bet=banker bet_cents=80000 winner=banker player_total=1 banker_total=8 natural=true return_cents=156000 bankroll_cents=746125 heat=6 opponent_profit_cents=-41000 reveal_count=0
hand stage=6 hand=5 bet=banker bet_cents=80000 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=666125 heat=6 opponent_profit_cents=-1000 reveal_count=0
hand stage=6 hand=6 bet=banker bet_cents=80000 winner=banker player_total=2 banker_total=7 natural=false return_cents=156000 bankroll_cents=742125 heat=6 opponent_profit_cents=18000 reveal_count=0
hand stage=6 hand=7 bet=banker bet_cents=80000 winner=banker player_total=3 banker_total=8 natural=true return_cents=156000 bankroll_cents=818125 heat=6 opponent_profit_cents=-2000 reveal_count=0
hand stage=6 hand=8 bet=banker bet_cents=80000 winner=player player_total=9 banker_total=0 natural=true return_cents=0 bankroll_cents=738125 heat=6 opponent_profit_cents=18000 reveal_count=0
stage_result stage=6 clear=true profit_cents=-16000 opponent_profit_cents=18000 tolerance_cents=140000 bankroll_cents=738125 heat=7 chips=9
stage_reward_rewards=Ante Kickback
shop_modifiers=player.punto-insurance
stage_start stage=7 hands=9 ante_cents=30000 min_bet_cents=30000 bankroll_cents=778125 heat=7 chips=6 boss=none active_mods=core.player-surge;player.side-step;player.player-tempo;heat.soft-footsteps;player.break-pattern
hand stage=7 hand=1 bet=banker bet_cents=120000 winner=tie player_total=6 banker_total=6 natural=false return_cents=120000 bankroll_cents=778125 heat=7 opponent_profit_cents=0 reveal_count=0
hand stage=7 hand=2 bet=banker bet_cents=120000 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=658125 heat=7 opponent_profit_cents=-30000 reveal_count=0
hand stage=7 hand=3 bet=banker bet_cents=120000 winner=player player_total=2 banker_total=0 natural=false return_cents=0 bankroll_cents=538125 heat=7 opponent_profit_cents=60000 reveal_count=0
hand stage=7 hand=4 bet=banker bet_cents=120000 winner=banker player_total=3 banker_total=8 natural=false return_cents=234000 bankroll_cents=652125 heat=7 opponent_profit_cents=88500 reveal_count=0
hand stage=7 hand=5 bet=banker bet_cents=120000 winner=banker player_total=4 banker_total=5 natural=false return_cents=234000 bankroll_cents=766125 heat=7 opponent_profit_cents=117000 reveal_count=0
hand stage=7 hand=6 bet=banker bet_cents=120000 winner=banker player_total=4 banker_total=6 natural=false return_cents=234000 bankroll_cents=880125 heat=7 opponent_profit_cents=202500 reveal_count=0
hand stage=7 hand=7 bet=banker bet_cents=120000 winner=banker player_total=0 banker_total=9 natural=true return_cents=234000 bankroll_cents=994125 heat=7 opponent_profit_cents=231000 reveal_count=0
hand stage=7 hand=8 bet=banker bet_cents=120000 winner=tie player_total=8 banker_total=8 natural=true return_cents=120000 bankroll_cents=994125 heat=7 opponent_profit_cents=231000 reveal_count=0
hand stage=7 hand=9 bet=banker bet_cents=120000 winner=banker player_total=4 banker_total=6 natural=false return_cents=234000 bankroll_cents=1108125 heat=7 opponent_profit_cents=316500 reveal_count=0
stage_result stage=7 clear=true profit_cents=330000 opponent_profit_cents=316500 tolerance_cents=360000 bankroll_cents=1108125 heat=7 chips=15
stage_reward_rewards=Table Comp
shop_modifiers=player.punto-insurance
stage_start stage=8 hands=10 ante_cents=40000 min_bet_cents=40000 bankroll_cents=1198125 heat=7 chips=12 boss=The Inspector active_mods=core.player-surge;player.side-step;player.player-tempo;heat.soft-footsteps;player.break-pattern
hand stage=8 hand=1 bet=banker bet_cents=175000 winner=banker player_total=1 banker_total=5 natural=false return_cents=341250 bankroll_cents=1364375 heat=7 opponent_profit_cents=38000 reveal_count=0
hand stage=8 hand=2 bet=banker bet_cents=175000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=1189375 heat=7 opponent_profit_cents=78000 reveal_count=0
hand stage=8 hand=3 bet=banker bet_cents=175000 winner=player player_total=8 banker_total=4 natural=true return_cents=0 bankroll_cents=1014375 heat=7 opponent_profit_cents=38000 reveal_count=0
hand stage=8 hand=4 bet=banker bet_cents=175000 winner=banker player_total=6 banker_total=7 natural=false return_cents=341250 bankroll_cents=1180625 heat=7 opponent_profit_cents=76000 reveal_count=0
hand stage=8 hand=5 bet=banker bet_cents=175000 winner=banker player_total=6 banker_total=7 natural=false return_cents=341250 bankroll_cents=1346875 heat=7 opponent_profit_cents=114000 reveal_count=0
hand stage=8 hand=6 bet=banker bet_cents=175000 winner=banker player_total=1 banker_total=4 natural=false return_cents=341250 bankroll_cents=1513125 heat=7 opponent_profit_cents=74000 reveal_count=0
hand stage=8 hand=7 bet=banker bet_cents=175000 winner=tie player_total=9 banker_total=9 natural=false return_cents=175000 bankroll_cents=1513125 heat=7 opponent_profit_cents=74000 reveal_count=0
hand stage=8 hand=8 bet=banker bet_cents=175000 winner=player player_total=9 banker_total=0 natural=true return_cents=0 bankroll_cents=1338125 heat=7 opponent_profit_cents=34000 reveal_count=0
hand stage=8 hand=9 bet=banker bet_cents=175000 winner=player player_total=5 banker_total=4 natural=false return_cents=0 bankroll_cents=1163125 heat=7 opponent_profit_cents=-6000 reveal_count=0
hand stage=8 hand=10 bet=banker bet_cents=175000 winner=player player_total=5 banker_total=2 natural=false return_cents=0 bankroll_cents=988125 heat=7 opponent_profit_cents=34000 reveal_count=0
stage_result stage=8 clear=true profit_cents=-210000 opponent_profit_cents=34000 tolerance_cents=400000 bankroll_cents=988125 heat=9 chips=18
boss_reward_rewards=Capstone Invitation
shop_modifiers=heat.soft-footsteps
stage_start stage=9 hands=10 ante_cents=60000 min_bet_cents=60000 bankroll_cents=988125 heat=9 chips=15 boss=none active_mods=core.player-surge;player.side-step;player.player-tempo;heat.soft-footsteps;player.break-pattern
hand stage=9 hand=1 bet=banker bet_cents=240000 winner=player player_total=8 banker_total=7 natural=true return_cents=0 bankroll_cents=748125 heat=7 opponent_profit_cents=60000 reveal_count=0
hand stage=9 hand=2 bet=banker bet_cents=180000 winner=player player_total=7 banker_total=5 natural=false return_cents=0 bankroll_cents=568125 heat=7 opponent_profit_cents=0 reveal_count=0
hand stage=9 hand=3 bet=banker bet_cents=120000 winner=banker player_total=3 banker_total=6 natural=false return_cents=234000 bankroll_cents=682125 heat=7 opponent_profit_cents=57000 reveal_count=0
hand stage=9 hand=4 bet=banker bet_cents=120000 winner=player player_total=9 banker_total=6 natural=true return_cents=0 bankroll_cents=562125 heat=7 opponent_profit_cents=-3000 reveal_count=0
hand stage=9 hand=5 bet=banker bet_cents=120000 winner=tie player_total=9 banker_total=9 natural=false return_cents=120000 bankroll_cents=562125 heat=7 opponent_profit_cents=-3000 reveal_count=0
hand stage=9 hand=6 bet=banker bet_cents=120000 winner=player player_total=8 banker_total=7 natural=true return_cents=0 bankroll_cents=442125 heat=7 opponent_profit_cents=-63000 reveal_count=0
hand stage=9 hand=7 bet=banker bet_cents=60000 winner=player player_total=5 banker_total=0 natural=false return_cents=0 bankroll_cents=382125 heat=7 opponent_profit_cents=-123000 reveal_count=0
hand stage=9 hand=8 bet=banker bet_cents=60000 winner=banker player_total=3 banker_total=6 natural=false return_cents=117000 bankroll_cents=439125 heat=7 opponent_profit_cents=-66000 reveal_count=0
hand stage=9 hand=9 bet=banker bet_cents=60000 winner=player player_total=8 banker_total=1 natural=true return_cents=0 bankroll_cents=379125 heat=7 opponent_profit_cents=-126000 reveal_count=0
hand stage=9 hand=10 bet=banker bet_cents=60000 winner=banker player_total=1 banker_total=2 natural=false return_cents=117000 bankroll_cents=436125 heat=7 opponent_profit_cents=-246000 reveal_count=0
stage_result stage=9 clear=true profit_cents=-552000 opponent_profit_cents=-246000 tolerance_cents=600000 bankroll_cents=436125 heat=8 chips=20
stage_reward_rewards=Table Comp
shop_modifiers=player.player-tempo
stage_start stage=10 hands=12 ante_cents=80000 min_bet_cents=80000 bankroll_cents=616125 heat=8 chips=16 boss=The House active_mods=core.player-surge;player.side-step;player.player-tempo;heat.soft-footsteps;player.break-pattern
hand stage=10 hand=1 bet=banker bet_cents=80000 winner=player player_total=8 banker_total=4 natural=true return_cents=0 bankroll_cents=536125 heat=7 opponent_profit_cents=-80000 reveal_count=0
hand stage=10 hand=2 bet=banker bet_cents=80000 winner=banker player_total=4 banker_total=9 natural=false return_cents=156000 bankroll_cents=612125 heat=7 opponent_profit_cents=-4000 reveal_count=0
hand stage=10 hand=3 bet=banker bet_cents=80000 winner=player player_total=6 banker_total=3 natural=false return_cents=0 bankroll_cents=532125 heat=7 opponent_profit_cents=-24000 reveal_count=0
hand stage=10 hand=4 bet=banker bet_cents=80000 winner=banker player_total=5 banker_total=7 natural=false return_cents=156000 bankroll_cents=608125 heat=8 opponent_profit_cents=112000 reveal_count=0
hand stage=10 hand=5 bet=banker bet_cents=80000 winner=player player_total=5 banker_total=4 natural=false return_cents=0 bankroll_cents=528125 heat=8 opponent_profit_cents=332000 reveal_count=0
hand stage=10 hand=6 bet=banker bet_cents=80000 winner=player player_total=9 banker_total=3 natural=true return_cents=0 bankroll_cents=448125 heat=8 opponent_profit_cents=312000 reveal_count=0
hand stage=10 hand=7 bet=banker bet_cents=80000 winner=banker player_total=2 banker_total=6 natural=false return_cents=156000 bankroll_cents=524125 heat=9 opponent_profit_cents=448000 reveal_count=0
hand stage=10 hand=8 bet=banker bet_cents=80000 winner=banker player_total=3 banker_total=5 natural=false return_cents=156000 bankroll_cents=600125 heat=10 opponent_profit_cents=584000 reveal_count=0
stage_result stage=10 clear=false profit_cents=-16000 opponent_profit_cents=584000 tolerance_cents=800000 bankroll_cents=600125 heat=10 chips=16
finish completed=false final_stage=10 failure=stage_10_heat ending_bankroll_cents=600125 highest_bankroll_cents=1513125 heat=10 owned_mods=core.player-surge;player.side-step;player.player-tempo;heat.soft-footsteps;player.break-pattern
```

## representative / risk_aware / 14021648824970372475

- Completed: no; final stage: 7; failure: `stage_7_opponent_loss`.
- Ending bankroll: $5,460; heat: 2; hands: 51; build: `core.clean-hands|player.player-tempo|player.punto-insurance|tie.mirror-bet|vision.soft-peek`.
- Rewards: Cool Down, Rare Modifier Voucher, Cool Down, Table Comp, Casino Inside Contact, Ante Kickback.
- Modifiers picked: tie.mirror-bet, player.punto-insurance, player.player-tempo, vision.soft-peek, tie.equalizer, heat.low-profile.

```text
start seed=14021648824970372475 policy=risk_aware contact=contact.clean-hands bankroll_cents=25000 chips=3 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25000 heat=0 chips=3 boss=none active_mods=core.clean-hands
hand stage=1 hand=1 bet=banker bet_cents=5000 winner=player player_total=6 banker_total=5 natural=false return_cents=0 bankroll_cents=20000 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=5 natural=true return_cents=0 bankroll_cents=15000 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=12500 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=banker player_total=4 banker_total=8 natural=true return_cents=4875 bankroll_cents=14875 heat=0 opponent_profit_cents=-125 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=banker player_total=1 banker_total=2 natural=false return_cents=4875 bankroll_cents=17250 heat=0 opponent_profit_cents=-5125 reveal_count=0
stage_result stage=1 clear=true profit_cents=-7750 opponent_profit_cents=-5125 tolerance_cents=22500 bankroll_cents=17250 heat=1 chips=5
stage_reward_rewards=Cool Down
shop_modifiers=tie.mirror-bet
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=17250 heat=0 chips=2 boss=none active_mods=core.clean-hands;tie.mirror-bet
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=player player_total=4 banker_total=1 natural=false return_cents=0 bankroll_cents=12250 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=player player_total=5 banker_total=2 natural=false return_cents=0 bankroll_cents=7250 heat=0 opponent_profit_cents=-10000 reveal_count=0
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=banker player_total=0 banker_total=3 natural=false return_cents=10000 bankroll_cents=12250 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=8 banker_total=9 natural=true return_cents=10000 bankroll_cents=17250 heat=0 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=banker player_total=2 banker_total=6 natural=false return_cents=10000 bankroll_cents=22250 heat=0 opponent_profit_cents=-10000 reveal_count=0
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=17250 heat=0 opponent_profit_cents=-15000 reveal_count=0
stage_result stage=2 clear=true profit_cents=0 opponent_profit_cents=-15000 tolerance_cents=25000 bankroll_cents=17250 heat=0 chips=4
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=player.punto-insurance
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=17250 heat=0 chips=2 boss=none active_mods=core.clean-hands;tie.mirror-bet;player.punto-insurance
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=banker player_total=1 banker_total=8 natural=true return_cents=14625 bankroll_cents=24375 heat=0 opponent_profit_cents=7125 reveal_count=0
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=banker player_total=1 banker_total=8 natural=true return_cents=14625 bankroll_cents=31500 heat=0 opponent_profit_cents=-375 reveal_count=0
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=player player_total=9 banker_total=3 natural=true return_cents=0 bankroll_cents=24000 heat=0 opponent_profit_cents=-7875 reveal_count=0
hand stage=3 hand=4 bet=banker bet_cents=7500 winner=banker player_total=7 banker_total=8 natural=true return_cents=14625 bankroll_cents=31125 heat=0 opponent_profit_cents=-750 reveal_count=0
hand stage=3 hand=5 bet=banker bet_cents=7500 winner=banker player_total=5 banker_total=9 natural=true return_cents=14625 bankroll_cents=38250 heat=0 opponent_profit_cents=6375 reveal_count=0
hand stage=3 hand=6 bet=banker bet_cents=7500 winner=player player_total=8 banker_total=5 natural=false return_cents=0 bankroll_cents=30750 heat=0 opponent_profit_cents=13875 reveal_count=0
hand stage=3 hand=7 bet=banker bet_cents=7500 winner=player player_total=9 banker_total=4 natural=false return_cents=0 bankroll_cents=23250 heat=0 opponent_profit_cents=6375 reveal_count=0
stage_result stage=3 clear=true profit_cents=6000 opponent_profit_cents=6375 tolerance_cents=37500 bankroll_cents=23250 heat=0 chips=4
stage_reward_rewards=Cool Down
shop_modifiers=player.player-tempo
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=23250 heat=0 chips=0 boss=none active_mods=core.clean-hands;tie.mirror-bet;player.punto-insurance;player.player-tempo
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=tie player_total=5 banker_total=5 natural=false return_cents=10000 bankroll_cents=23250 heat=0 opponent_profit_cents=0 reveal_count=0
hand stage=4 hand=2 bet=banker bet_cents=10000 winner=tie player_total=5 banker_total=5 natural=false return_cents=10000 bankroll_cents=23250 heat=0 opponent_profit_cents=0 reveal_count=0
hand stage=4 hand=3 bet=banker bet_cents=10000 winner=banker player_total=0 banker_total=6 natural=false return_cents=19500 bankroll_cents=32750 heat=0 opponent_profit_cents=19000 reveal_count=0
hand stage=4 hand=4 bet=banker bet_cents=10000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=22750 heat=0 opponent_profit_cents=9000 reveal_count=0
hand stage=4 hand=5 bet=banker bet_cents=10000 winner=banker player_total=1 banker_total=8 natural=true return_cents=19500 bankroll_cents=32250 heat=0 opponent_profit_cents=28000 reveal_count=0
hand stage=4 hand=6 bet=banker bet_cents=10000 winner=banker player_total=6 banker_total=7 natural=false return_cents=19500 bankroll_cents=41750 heat=0 opponent_profit_cents=47000 reveal_count=0
hand stage=4 hand=7 bet=banker bet_cents=10000 winner=banker player_total=1 banker_total=8 natural=true return_cents=19500 bankroll_cents=51250 heat=0 opponent_profit_cents=66000 reveal_count=0
hand stage=4 hand=8 bet=banker bet_cents=10000 winner=banker player_total=2 banker_total=7 natural=false return_cents=19500 bankroll_cents=60750 heat=0 opponent_profit_cents=56000 reveal_count=0
stage_result stage=4 clear=true profit_cents=37500 opponent_profit_cents=56000 tolerance_cents=80000 bankroll_cents=60750 heat=0 chips=3
stage_reward_rewards=Table Comp
shop_modifiers=vision.soft-peek
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=87750 heat=0 chips=0 boss=Pit Boss active_mods=core.clean-hands;tie.mirror-bet;player.punto-insurance;player.player-tempo;vision.soft-peek
hand stage=5 hand=1 bet=banker bet_cents=15000 winner=banker player_total=3 banker_total=8 natural=true return_cents=29250 bankroll_cents=102000 heat=0 opponent_profit_cents=14250 reveal_count=2
hand stage=5 hand=2 bet=banker bet_cents=15000 winner=player player_total=9 banker_total=4 natural=true return_cents=0 bankroll_cents=87000 heat=0 opponent_profit_cents=-750 reveal_count=2
hand stage=5 hand=3 bet=banker bet_cents=15000 winner=banker player_total=5 banker_total=9 natural=true return_cents=29250 bankroll_cents=101250 heat=0 opponent_profit_cents=-12750 reveal_count=2
hand stage=5 hand=4 bet=banker bet_cents=15000 winner=banker player_total=3 banker_total=7 natural=false return_cents=29250 bankroll_cents=115500 heat=1 opponent_profit_cents=4500 reveal_count=2
hand stage=5 hand=5 bet=banker bet_cents=15000 winner=banker player_total=4 banker_total=7 natural=false return_cents=29250 bankroll_cents=129750 heat=1 opponent_profit_cents=36000 reveal_count=2
hand stage=5 hand=6 bet=banker bet_cents=30000 winner=player player_total=5 banker_total=4 natural=false return_cents=0 bankroll_cents=99750 heat=1 opponent_profit_cents=24000 reveal_count=2
hand stage=5 hand=7 bet=banker bet_cents=15000 winner=banker player_total=4 banker_total=7 natural=false return_cents=29250 bankroll_cents=114000 heat=1 opponent_profit_cents=12000 reveal_count=2
hand stage=5 hand=8 bet=banker bet_cents=15000 winner=tie player_total=7 banker_total=7 natural=false return_cents=15000 bankroll_cents=114000 heat=2 opponent_profit_cents=15000 reveal_count=2
stage_result stage=5 clear=true profit_cents=26250 opponent_profit_cents=15000 tolerance_cents=105000 bankroll_cents=114000 heat=2 chips=6
boss_reward_rewards=Casino Inside Contact
shop_modifiers=tie.equalizer
stage_start stage=6 hands=8 ante_cents=20000 min_bet_cents=20000 bankroll_cents=114000 heat=2 chips=1 boss=none active_mods=core.clean-hands;tie.mirror-bet;player.punto-insurance;player.player-tempo;vision.soft-peek
hand stage=6 hand=1 bet=banker bet_cents=20000 winner=banker player_total=1 banker_total=6 natural=false return_cents=39000 bankroll_cents=133000 heat=2 opponent_profit_cents=19000 reveal_count=2
hand stage=6 hand=2 bet=banker bet_cents=20000 winner=tie player_total=0 banker_total=0 natural=false return_cents=20000 bankroll_cents=133000 heat=2 opponent_profit_cents=19000 reveal_count=2
hand stage=6 hand=3 bet=banker bet_cents=20000 winner=banker player_total=1 banker_total=6 natural=false return_cents=39000 bankroll_cents=152000 heat=2 opponent_profit_cents=38000 reveal_count=2
hand stage=6 hand=4 bet=banker bet_cents=20000 winner=banker player_total=3 banker_total=9 natural=false return_cents=39000 bankroll_cents=171000 heat=2 opponent_profit_cents=18000 reveal_count=2
hand stage=6 hand=5 bet=banker bet_cents=40000 winner=tie player_total=7 banker_total=7 natural=false return_cents=40000 bankroll_cents=171000 heat=2 opponent_profit_cents=18000 reveal_count=2
hand stage=6 hand=6 bet=banker bet_cents=40000 winner=banker player_total=2 banker_total=8 natural=true return_cents=78000 bankroll_cents=209000 heat=2 opponent_profit_cents=37000 reveal_count=2
hand stage=6 hand=7 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=5 natural=false return_cents=78000 bankroll_cents=247000 heat=2 opponent_profit_cents=17000 reveal_count=2
hand stage=6 hand=8 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=3 natural=false return_cents=78000 bankroll_cents=285000 heat=2 opponent_profit_cents=-3000 reveal_count=2
stage_result stage=6 clear=true profit_cents=171000 opponent_profit_cents=-3000 tolerance_cents=140000 bankroll_cents=285000 heat=2 chips=5
stage_reward_rewards=Ante Kickback
shop_modifiers=heat.low-profile
stage_start stage=7 hands=9 ante_cents=30000 min_bet_cents=30000 bankroll_cents=321000 heat=2 chips=2 boss=none active_mods=core.clean-hands;tie.mirror-bet;player.punto-insurance;player.player-tempo;vision.soft-peek
hand stage=7 hand=1 bet=banker bet_cents=60000 winner=player player_total=7 banker_total=4 natural=false return_cents=0 bankroll_cents=261000 heat=2 opponent_profit_cents=-30000 reveal_count=2
hand stage=7 hand=2 bet=banker bet_cents=60000 winner=banker player_total=6 banker_total=9 natural=false return_cents=117000 bankroll_cents=318000 heat=2 opponent_profit_cents=-1500 reveal_count=2
hand stage=7 hand=3 bet=banker bet_cents=60000 winner=banker player_total=2 banker_total=7 natural=false return_cents=117000 bankroll_cents=375000 heat=2 opponent_profit_cents=84000 reveal_count=2
hand stage=7 hand=4 bet=banker bet_cents=60000 winner=banker player_total=4 banker_total=7 natural=false return_cents=117000 bankroll_cents=432000 heat=2 opponent_profit_cents=112500 reveal_count=2
hand stage=7 hand=5 bet=banker bet_cents=60000 winner=tie player_total=6 banker_total=6 natural=false return_cents=60000 bankroll_cents=432000 heat=2 opponent_profit_cents=112500 reveal_count=2
hand stage=7 hand=6 bet=banker bet_cents=60000 winner=tie player_total=9 banker_total=9 natural=true return_cents=60000 bankroll_cents=432000 heat=2 opponent_profit_cents=832500 reveal_count=2
hand stage=7 hand=7 bet=banker bet_cents=60000 winner=banker player_total=2 banker_total=7 natural=false return_cents=117000 bankroll_cents=489000 heat=2 opponent_profit_cents=861000 reveal_count=2
hand stage=7 hand=8 bet=banker bet_cents=60000 winner=tie player_total=6 banker_total=6 natural=false return_cents=60000 bankroll_cents=489000 heat=2 opponent_profit_cents=861000 reveal_count=2
hand stage=7 hand=9 bet=banker bet_cents=60000 winner=banker player_total=7 banker_total=9 natural=true return_cents=117000 bankroll_cents=546000 heat=2 opponent_profit_cents=946500 reveal_count=2
stage_result stage=7 clear=false profit_cents=225000 opponent_profit_cents=946500 tolerance_cents=360000 bankroll_cents=546000 heat=2 chips=2
finish completed=false final_stage=7 failure=stage_7_opponent_loss ending_bankroll_cents=546000 highest_bankroll_cents=546000 heat=2 owned_mods=core.clean-hands;tie.mirror-bet;player.punto-insurance;player.player-tempo;vision.soft-peek
```

## representative / optimized / 6875500689133562470

- Completed: no; final stage: 4; failure: `stage_4_opponent_loss`.
- Ending bankroll: $1,622.5; heat: 3; hands: 26; build: `core.lucky-chip|debt.emergency-marker|economy.interest-ledger|tie.tie-whisperer|vision.pattern-memory`.
- Rewards: High Table Cut, Rare Modifier Voucher, Table Comp.
- Modifiers picked: tie.tie-whisperer, debt.emergency-marker, economy.interest-ledger, tie.tie-whisperer, vision.pattern-memory.

```text
start seed=6875500689133562470 policy=optimized contact=contact.lucky-chip bankroll_cents=25000 chips=4 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25000 heat=0 chips=4 boss=none active_mods=core.lucky-chip
hand stage=1 hand=1 bet=banker bet_cents=2500 winner=tie player_total=9 banker_total=9 natural=true return_cents=2500 bankroll_cents=25000 heat=0 opponent_profit_cents=0 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=2500 winner=banker player_total=4 banker_total=7 natural=false return_cents=4875 bankroll_cents=27375 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=banker player_total=6 banker_total=8 natural=false return_cents=4875 bankroll_cents=29750 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=27250 heat=0 opponent_profit_cents=-7500 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=banker player_total=5 banker_total=6 natural=false return_cents=4875 bankroll_cents=29625 heat=0 opponent_profit_cents=-12500 reveal_count=0
stage_result stage=1 clear=true profit_cents=4625 opponent_profit_cents=-12500 tolerance_cents=22500 bankroll_cents=29625 heat=0 chips=8
stage_reward_rewards=High Table Cut
shop_modifiers=tie.tie-whisperer;debt.emergency-marker
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=42125 heat=1 chips=2 boss=none active_mods=core.lucky-chip;tie.tie-whisperer;debt.emergency-marker
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=37125 heat=1 opponent_profit_cents=-5000 reveal_count=0
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=8 natural=true return_cents=10000 bankroll_cents=42125 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=0 natural=true return_cents=0 bankroll_cents=37125 heat=1 opponent_profit_cents=-5000 reveal_count=0
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=2 banker_total=5 natural=false return_cents=10000 bankroll_cents=42125 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=3 natural=true return_cents=0 bankroll_cents=37125 heat=1 opponent_profit_cents=10000 reveal_count=0
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=banker player_total=0 banker_total=2 natural=false return_cents=10000 bankroll_cents=42125 heat=1 opponent_profit_cents=15000 reveal_count=0
stage_result stage=2 clear=true profit_cents=2500 opponent_profit_cents=15000 tolerance_cents=25000 bankroll_cents=42125 heat=1 chips=6
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=economy.interest-ledger;tie.tie-whisperer
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=48500 heat=2 chips=1 boss=none active_mods=core.lucky-chip;tie.tie-whisperer;debt.emergency-marker;economy.interest-ledger
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=banker player_total=2 banker_total=4 natural=false return_cents=14625 bankroll_cents=55625 heat=2 opponent_profit_cents=7125 reveal_count=0
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=banker player_total=8 banker_total=9 natural=true return_cents=14625 bankroll_cents=62750 heat=2 opponent_profit_cents=-375 reveal_count=0
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=7 natural=false return_cents=14625 bankroll_cents=69875 heat=2 opponent_profit_cents=6750 reveal_count=0
hand stage=3 hand=4 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=8 natural=true return_cents=14625 bankroll_cents=77000 heat=2 opponent_profit_cents=13875 reveal_count=0
hand stage=3 hand=5 bet=banker bet_cents=7500 winner=player player_total=6 banker_total=3 natural=false return_cents=0 bankroll_cents=69500 heat=2 opponent_profit_cents=6375 reveal_count=0
hand stage=3 hand=6 bet=banker bet_cents=7500 winner=banker player_total=0 banker_total=8 natural=true return_cents=14625 bankroll_cents=76625 heat=2 opponent_profit_cents=-1125 reveal_count=0
hand stage=3 hand=7 bet=banker bet_cents=7500 winner=banker player_total=5 banker_total=8 natural=true return_cents=14625 bankroll_cents=83750 heat=2 opponent_profit_cents=6000 reveal_count=0
stage_result stage=3 clear=true profit_cents=41625 opponent_profit_cents=6000 tolerance_cents=37500 bankroll_cents=83750 heat=2 chips=5
stage_reward_rewards=Table Comp
shop_modifiers=vision.pattern-memory
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=114750 heat=3 chips=1 boss=none active_mods=core.lucky-chip;tie.tie-whisperer;debt.emergency-marker;economy.interest-ledger;vision.pattern-memory
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=banker player_total=3 banker_total=8 natural=true return_cents=19500 bankroll_cents=126250 heat=3 opponent_profit_cents=19000 reveal_count=1
hand stage=4 hand=2 bet=banker bet_cents=10000 winner=tie player_total=0 banker_total=0 natural=false return_cents=10000 bankroll_cents=126250 heat=3 opponent_profit_cents=19000 reveal_count=1
hand stage=4 hand=3 bet=banker bet_cents=10000 winner=banker player_total=2 banker_total=9 natural=false return_cents=19500 bankroll_cents=137750 heat=3 opponent_profit_cents=38000 reveal_count=1
hand stage=4 hand=4 bet=banker bet_cents=10000 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=127750 heat=3 opponent_profit_cents=28000 reveal_count=1
hand stage=4 hand=5 bet=banker bet_cents=10000 winner=banker player_total=3 banker_total=9 natural=true return_cents=19500 bankroll_cents=139250 heat=3 opponent_profit_cents=47000 reveal_count=1
hand stage=4 hand=6 bet=banker bet_cents=10000 winner=banker player_total=0 banker_total=7 natural=false return_cents=19500 bankroll_cents=150750 heat=3 opponent_profit_cents=66000 reveal_count=1
hand stage=4 hand=7 bet=banker bet_cents=10000 winner=banker player_total=6 banker_total=9 natural=true return_cents=19500 bankroll_cents=162250 heat=3 opponent_profit_cents=85000 reveal_count=1
hand stage=4 hand=8 bet=banker bet_cents=10000 winner=tie player_total=9 banker_total=9 natural=true return_cents=10000 bankroll_cents=162250 heat=3 opponent_profit_cents=165000 reveal_count=1
stage_result stage=4 clear=false profit_cents=56000 opponent_profit_cents=165000 tolerance_cents=80000 bankroll_cents=162250 heat=3 chips=2
finish completed=false final_stage=4 failure=stage_4_opponent_loss ending_bankroll_cents=162250 highest_bankroll_cents=162250 heat=3 owned_mods=core.lucky-chip;tie.tie-whisperer;debt.emergency-marker;economy.interest-ledger;vision.pattern-memory
```

## anomaly_high_bankroll / optimized / 2182477019275242731

- Completed: yes; final stage: 10; failure: `run_complete`.
- Ending bankroll: $21,928.25; heat: 4; hands: 83; build: `banker.banco-press|banker.commission-dodge|core.lucky-chip|economy.interest-ledger|heat.soft-footsteps`.
- Rewards: Chip Runner, Chip Runner, High Table Cut, Table Comp, Pit Boss Nod, Ante Kickback, High Table Cut, Casino Inside Contact, Table Comp.
- Modifiers picked: banker.commission-dodge, banker.commission-dodge, banker.commission-dodge, economy.interest-ledger, banker.banco-press, heat.soft-footsteps, economy.comp-points, tie.equalizer, economy.interest-ledger, tie.equalizer, economy.comp-points, tie.equalizer, economy.comp-points.

```text
start seed=2182477019275242731 policy=optimized contact=contact.lucky-chip bankroll_cents=25000 chips=4 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25000 heat=0 chips=4 boss=none active_mods=core.lucky-chip
hand stage=1 hand=1 bet=banker bet_cents=2500 winner=banker player_total=3 banker_total=9 natural=true return_cents=4875 bankroll_cents=27375 heat=0 opponent_profit_cents=2375 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=2500 winner=banker player_total=4 banker_total=9 natural=true return_cents=4875 bankroll_cents=29750 heat=0 opponent_profit_cents=-125 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=banker player_total=3 banker_total=7 natural=false return_cents=4875 bankroll_cents=32125 heat=0 opponent_profit_cents=-2625 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=29625 heat=0 opponent_profit_cents=-5125 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=player player_total=6 banker_total=3 natural=false return_cents=0 bankroll_cents=27125 heat=0 opponent_profit_cents=-10125 reveal_count=0
stage_result stage=1 clear=true profit_cents=2125 opponent_profit_cents=-10125 tolerance_cents=22500 bankroll_cents=27125 heat=0 chips=8
stage_reward_rewards=Chip Runner
shop_modifiers=banker.commission-dodge;banker.commission-dodge
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=27125 heat=0 chips=4 boss=none active_mods=core.lucky-chip;banker.commission-dodge
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=banker player_total=6 banker_total=7 natural=false return_cents=10000 bankroll_cents=32575 heat=0 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=tie player_total=0 banker_total=0 natural=false return_cents=5000 bankroll_cents=32575 heat=0 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=27575 heat=0 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=8 natural=false return_cents=10000 bankroll_cents=33025 heat=0 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=player player_total=7 banker_total=1 natural=false return_cents=0 bankroll_cents=28025 heat=0 opponent_profit_cents=15000 reveal_count=0
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=23025 heat=0 opponent_profit_cents=10000 reveal_count=0
stage_result stage=2 clear=true profit_cents=-4100 opponent_profit_cents=10000 tolerance_cents=25000 bankroll_cents=23025 heat=1 chips=7
stage_reward_rewards=Chip Runner
shop_modifiers=banker.commission-dodge;economy.interest-ledger
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=25650 heat=1 chips=3 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=banker player_total=4 banker_total=9 natural=false return_cents=14625 bankroll_cents=33825 heat=1 opponent_profit_cents=7125 reveal_count=0
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=player player_total=8 banker_total=3 natural=true return_cents=0 bankroll_cents=26325 heat=1 opponent_profit_cents=14625 reveal_count=0
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=7 natural=false return_cents=14625 bankroll_cents=34500 heat=1 opponent_profit_cents=21750 reveal_count=0
hand stage=3 hand=4 bet=banker bet_cents=7500 winner=banker player_total=0 banker_total=5 natural=false return_cents=14625 bankroll_cents=42675 heat=1 opponent_profit_cents=28875 reveal_count=0
hand stage=3 hand=5 bet=banker bet_cents=7500 winner=banker player_total=6 banker_total=7 natural=false return_cents=14625 bankroll_cents=50850 heat=1 opponent_profit_cents=36000 reveal_count=0
hand stage=3 hand=6 bet=banker bet_cents=7500 winner=banker player_total=4 banker_total=9 natural=true return_cents=14625 bankroll_cents=59025 heat=1 opponent_profit_cents=28500 reveal_count=0
hand stage=3 hand=7 bet=banker bet_cents=7500 winner=player player_total=5 banker_total=4 natural=false return_cents=0 bankroll_cents=51525 heat=1 opponent_profit_cents=21000 reveal_count=0
stage_result stage=3 clear=true profit_cents=28500 opponent_profit_cents=21000 tolerance_cents=37500 bankroll_cents=51525 heat=1 chips=7
stage_reward_rewards=High Table Cut
shop_modifiers=banker.banco-press
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=85025 heat=1 chips=2 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;banker.banco-press
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=tie player_total=6 banker_total=6 natural=false return_cents=10000 bankroll_cents=85025 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=4 hand=2 bet=banker bet_cents=10000 winner=player player_total=9 banker_total=5 natural=true return_cents=0 bankroll_cents=75025 heat=1 opponent_profit_cents=-20000 reveal_count=0
hand stage=4 hand=3 bet=banker bet_cents=10000 winner=player player_total=5 banker_total=4 natural=false return_cents=0 bankroll_cents=65025 heat=1 opponent_profit_cents=-40000 reveal_count=0
hand stage=4 hand=4 bet=banker bet_cents=10000 winner=player player_total=9 banker_total=7 natural=true return_cents=0 bankroll_cents=55025 heat=1 opponent_profit_cents=-50000 reveal_count=0
hand stage=4 hand=5 bet=banker bet_cents=10000 winner=banker player_total=0 banker_total=6 natural=false return_cents=19500 bankroll_cents=70925 heat=1 opponent_profit_cents=-31000 reveal_count=0
hand stage=4 hand=6 bet=banker bet_cents=10000 winner=banker player_total=3 banker_total=6 natural=false return_cents=19500 bankroll_cents=86825 heat=1 opponent_profit_cents=-12000 reveal_count=0
hand stage=4 hand=7 bet=banker bet_cents=10000 winner=banker player_total=2 banker_total=7 natural=false return_cents=19500 bankroll_cents=102725 heat=1 opponent_profit_cents=7000 reveal_count=0
hand stage=4 hand=8 bet=banker bet_cents=10000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=92725 heat=1 opponent_profit_cents=-3000 reveal_count=0
stage_result stage=4 clear=true profit_cents=11200 opponent_profit_cents=-3000 tolerance_cents=80000 bankroll_cents=92725 heat=1 chips=6
stage_reward_rewards=Table Comp
shop_modifiers=heat.soft-footsteps;economy.comp-points
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=127975 heat=1 chips=0 boss=Pit Boss active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;banker.banco-press;heat.soft-footsteps
hand stage=5 hand=1 bet=banker bet_cents=15000 winner=banker player_total=6 banker_total=8 natural=true return_cents=29250 bankroll_cents=151825 heat=1 opponent_profit_cents=-15000 reveal_count=0
hand stage=5 hand=2 bet=banker bet_cents=15000 winner=banker player_total=2 banker_total=5 natural=false return_cents=29250 bankroll_cents=175675 heat=1 opponent_profit_cents=-750 reveal_count=0
hand stage=5 hand=3 bet=banker bet_cents=15000 winner=banker player_total=3 banker_total=4 natural=false return_cents=29250 bankroll_cents=199525 heat=1 opponent_profit_cents=16500 reveal_count=0
hand stage=5 hand=4 bet=banker bet_cents=15000 winner=player player_total=8 banker_total=0 natural=true return_cents=0 bankroll_cents=184525 heat=0 opponent_profit_cents=4500 reveal_count=0
hand stage=5 hand=5 bet=banker bet_cents=15000 winner=tie player_total=7 banker_total=7 natural=false return_cents=15000 bankroll_cents=184525 heat=0 opponent_profit_cents=7500 reveal_count=0
hand stage=5 hand=6 bet=banker bet_cents=15000 winner=banker player_total=4 banker_total=7 natural=false return_cents=29250 bankroll_cents=208375 heat=0 opponent_profit_cents=-4500 reveal_count=0
hand stage=5 hand=7 bet=banker bet_cents=15000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=193375 heat=0 opponent_profit_cents=-16500 reveal_count=0
hand stage=5 hand=8 bet=banker bet_cents=15000 winner=banker player_total=0 banker_total=6 natural=false return_cents=29250 bankroll_cents=217225 heat=1 opponent_profit_cents=-28500 reveal_count=0
stage_result stage=5 clear=true profit_cents=94500 opponent_profit_cents=-28500 tolerance_cents=105000 bankroll_cents=217225 heat=1 chips=7
boss_reward_rewards=Pit Boss Nod
shop_modifiers=tie.equalizer;economy.interest-ledger
stage_start stage=6 hands=8 ante_cents=20000 min_bet_cents=20000 bankroll_cents=229225 heat=1 chips=1 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;banker.banco-press;heat.soft-footsteps
hand stage=6 hand=1 bet=banker bet_cents=20000 winner=banker player_total=0 banker_total=5 natural=false return_cents=39000 bankroll_cents=261025 heat=1 opponent_profit_cents=-20000 reveal_count=0
hand stage=6 hand=2 bet=banker bet_cents=20000 winner=player player_total=8 banker_total=2 natural=true return_cents=0 bankroll_cents=241025 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=6 hand=3 bet=banker bet_cents=20000 winner=tie player_total=6 banker_total=6 natural=false return_cents=20000 bankroll_cents=241025 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=6 hand=4 bet=banker bet_cents=20000 winner=banker player_total=3 banker_total=5 natural=false return_cents=39000 bankroll_cents=272825 heat=1 opponent_profit_cents=19000 reveal_count=0
hand stage=6 hand=5 bet=banker bet_cents=20000 winner=player player_total=8 banker_total=6 natural=false return_cents=0 bankroll_cents=252825 heat=1 opponent_profit_cents=59000 reveal_count=0
hand stage=6 hand=6 bet=banker bet_cents=20000 winner=banker player_total=8 banker_total=9 natural=true return_cents=39000 bankroll_cents=284625 heat=1 opponent_profit_cents=78000 reveal_count=0
hand stage=6 hand=7 bet=banker bet_cents=20000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=264625 heat=1 opponent_profit_cents=98000 reveal_count=0
hand stage=6 hand=8 bet=banker bet_cents=20000 winner=banker player_total=6 banker_total=8 natural=false return_cents=39000 bankroll_cents=296425 heat=1 opponent_profit_cents=117000 reveal_count=0
stage_result stage=6 clear=true profit_cents=79200 opponent_profit_cents=117000 tolerance_cents=140000 bankroll_cents=296425 heat=1 chips=6
stage_reward_rewards=Ante Kickback
shop_modifiers=tie.equalizer
stage_start stage=7 hands=9 ante_cents=30000 min_bet_cents=30000 bankroll_cents=354425 heat=1 chips=1 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;banker.banco-press;heat.soft-footsteps
hand stage=7 hand=1 bet=banker bet_cents=30000 winner=tie player_total=5 banker_total=5 natural=false return_cents=30000 bankroll_cents=354425 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=7 hand=2 bet=banker bet_cents=30000 winner=banker player_total=5 banker_total=9 natural=true return_cents=58500 bankroll_cents=402125 heat=1 opponent_profit_cents=28500 reveal_count=0
hand stage=7 hand=3 bet=banker bet_cents=30000 winner=banker player_total=2 banker_total=6 natural=false return_cents=58500 bankroll_cents=449825 heat=1 opponent_profit_cents=114000 reveal_count=0
hand stage=7 hand=4 bet=banker bet_cents=30000 winner=tie player_total=7 banker_total=7 natural=false return_cents=30000 bankroll_cents=449825 heat=1 opponent_profit_cents=114000 reveal_count=0
hand stage=7 hand=5 bet=banker bet_cents=30000 winner=player player_total=9 banker_total=7 natural=true return_cents=0 bankroll_cents=419825 heat=1 opponent_profit_cents=84000 reveal_count=0
hand stage=7 hand=6 bet=banker bet_cents=30000 winner=player player_total=8 banker_total=6 natural=true return_cents=0 bankroll_cents=389825 heat=1 opponent_profit_cents=174000 reveal_count=0
hand stage=7 hand=7 bet=banker bet_cents=60000 winner=banker player_total=1 banker_total=6 natural=false return_cents=117000 bankroll_cents=473225 heat=1 opponent_profit_cents=202500 reveal_count=0
hand stage=7 hand=8 bet=banker bet_cents=30000 winner=banker player_total=2 banker_total=5 natural=false return_cents=58500 bankroll_cents=520925 heat=1 opponent_profit_cents=231000 reveal_count=0
hand stage=7 hand=9 bet=banker bet_cents=30000 winner=banker player_total=5 banker_total=9 natural=true return_cents=58500 bankroll_cents=568625 heat=1 opponent_profit_cents=316500 reveal_count=0
stage_result stage=7 clear=true profit_cents=232200 opponent_profit_cents=316500 tolerance_cents=360000 bankroll_cents=568625 heat=1 chips=6
stage_reward_rewards=High Table Cut
shop_modifiers=economy.comp-points
stage_start stage=8 hands=10 ante_cents=40000 min_bet_cents=40000 bankroll_cents=712625 heat=1 chips=3 boss=The Inspector active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;banker.banco-press;heat.soft-footsteps
hand stage=8 hand=1 bet=banker bet_cents=40000 winner=player player_total=8 banker_total=7 natural=false return_cents=0 bankroll_cents=672625 heat=1 opponent_profit_cents=-40000 reveal_count=0
hand stage=8 hand=2 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=632625 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=8 hand=3 bet=banker bet_cents=40000 winner=player player_total=6 banker_total=4 natural=false return_cents=0 bankroll_cents=592625 heat=1 opponent_profit_cents=-40000 reveal_count=0
hand stage=8 hand=4 bet=banker bet_cents=40000 winner=banker player_total=3 banker_total=8 natural=true return_cents=78000 bankroll_cents=656225 heat=1 opponent_profit_cents=-2000 reveal_count=0
hand stage=8 hand=5 bet=banker bet_cents=40000 winner=banker player_total=2 banker_total=4 natural=false return_cents=78000 bankroll_cents=719825 heat=1 opponent_profit_cents=36000 reveal_count=0
hand stage=8 hand=6 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=5 natural=false return_cents=78000 bankroll_cents=783425 heat=1 opponent_profit_cents=-4000 reveal_count=0
hand stage=8 hand=7 bet=banker bet_cents=40000 winner=banker player_total=3 banker_total=7 natural=false return_cents=78000 bankroll_cents=847025 heat=1 opponent_profit_cents=34000 reveal_count=0
hand stage=8 hand=8 bet=banker bet_cents=40000 winner=tie player_total=6 banker_total=6 natural=false return_cents=40000 bankroll_cents=847025 heat=1 opponent_profit_cents=34000 reveal_count=0
hand stage=8 hand=9 bet=banker bet_cents=40000 winner=banker player_total=6 banker_total=8 natural=true return_cents=78000 bankroll_cents=910625 heat=1 opponent_profit_cents=72000 reveal_count=0
hand stage=8 hand=10 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=6 natural=false return_cents=0 bankroll_cents=870625 heat=1 opponent_profit_cents=112000 reveal_count=0
stage_result stage=8 clear=true profit_cents=182000 opponent_profit_cents=112000 tolerance_cents=400000 bankroll_cents=870625 heat=1 chips=10
boss_reward_rewards=Casino Inside Contact
stage_start stage=9 hands=10 ante_cents=60000 min_bet_cents=60000 bankroll_cents=906625 heat=1 chips=9 boss=none active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;banker.banco-press;heat.soft-footsteps
hand stage=9 hand=1 bet=banker bet_cents=60000 winner=banker player_total=0 banker_total=8 natural=true return_cents=117000 bankroll_cents=1002025 heat=1 opponent_profit_cents=57000 reveal_count=0
hand stage=9 hand=2 bet=banker bet_cents=60000 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=942025 heat=0 opponent_profit_cents=117000 reveal_count=0
hand stage=9 hand=3 bet=banker bet_cents=60000 winner=player player_total=9 banker_total=2 natural=true return_cents=0 bankroll_cents=882025 heat=0 opponent_profit_cents=57000 reveal_count=0
hand stage=9 hand=4 bet=banker bet_cents=60000 winner=banker player_total=6 banker_total=7 natural=false return_cents=117000 bankroll_cents=977425 heat=0 opponent_profit_cents=114000 reveal_count=0
hand stage=9 hand=5 bet=banker bet_cents=60000 winner=banker player_total=5 banker_total=9 natural=true return_cents=117000 bankroll_cents=1072825 heat=0 opponent_profit_cents=-6000 reveal_count=0
hand stage=9 hand=6 bet=banker bet_cents=60000 winner=banker player_total=3 banker_total=8 natural=true return_cents=117000 bankroll_cents=1168225 heat=0 opponent_profit_cents=51000 reveal_count=0
hand stage=9 hand=7 bet=banker bet_cents=60000 winner=banker player_total=4 banker_total=9 natural=true return_cents=117000 bankroll_cents=1263625 heat=0 opponent_profit_cents=108000 reveal_count=0
hand stage=9 hand=8 bet=banker bet_cents=60000 winner=banker player_total=2 banker_total=8 natural=true return_cents=117000 bankroll_cents=1359025 heat=0 opponent_profit_cents=165000 reveal_count=0
hand stage=9 hand=9 bet=banker bet_cents=60000 winner=player player_total=6 banker_total=5 natural=false return_cents=0 bankroll_cents=1299025 heat=0 opponent_profit_cents=105000 reveal_count=0
hand stage=9 hand=10 bet=banker bet_cents=60000 winner=banker player_total=2 banker_total=7 natural=false return_cents=117000 bankroll_cents=1394425 heat=0 opponent_profit_cents=-15000 reveal_count=0
stage_result stage=9 clear=true profit_cents=523800 opponent_profit_cents=-15000 tolerance_cents=600000 bankroll_cents=1394425 heat=0 chips=15
stage_reward_rewards=Table Comp
shop_modifiers=tie.equalizer;economy.comp-points
stage_start stage=10 hands=12 ante_cents=80000 min_bet_cents=80000 bankroll_cents=1622425 heat=0 chips=7 boss=The House active_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;banker.banco-press;heat.soft-footsteps
hand stage=10 hand=1 bet=banker bet_cents=80000 winner=player player_total=9 banker_total=1 natural=true return_cents=0 bankroll_cents=1542425 heat=0 opponent_profit_cents=-80000 reveal_count=0
hand stage=10 hand=2 bet=banker bet_cents=80000 winner=banker player_total=0 banker_total=7 natural=false return_cents=156000 bankroll_cents=1669625 heat=0 opponent_profit_cents=-4000 reveal_count=0
hand stage=10 hand=3 bet=banker bet_cents=80000 winner=banker player_total=5 banker_total=8 natural=true return_cents=156000 bankroll_cents=1796825 heat=0 opponent_profit_cents=132000 reveal_count=0
hand stage=10 hand=4 bet=banker bet_cents=80000 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=1716825 heat=1 opponent_profit_cents=112000 reveal_count=0
hand stage=10 hand=5 bet=banker bet_cents=80000 winner=banker player_total=2 banker_total=9 natural=true return_cents=156000 bankroll_cents=1844025 heat=1 opponent_profit_cents=12000 reveal_count=0
hand stage=10 hand=6 bet=banker bet_cents=80000 winner=banker player_total=0 banker_total=3 natural=false return_cents=156000 bankroll_cents=1971225 heat=1 opponent_profit_cents=148000 reveal_count=0
hand stage=10 hand=7 bet=banker bet_cents=80000 winner=player player_total=9 banker_total=6 natural=true return_cents=0 bankroll_cents=1891225 heat=2 opponent_profit_cents=128000 reveal_count=0
hand stage=10 hand=8 bet=banker bet_cents=80000 winner=player player_total=9 banker_total=4 natural=true return_cents=0 bankroll_cents=1811225 heat=3 opponent_profit_cents=108000 reveal_count=0
hand stage=10 hand=9 bet=banker bet_cents=80000 winner=tie player_total=2 banker_total=2 natural=false return_cents=80000 bankroll_cents=1811225 heat=3 opponent_profit_cents=168000 reveal_count=0
hand stage=10 hand=10 bet=banker bet_cents=80000 winner=banker player_total=0 banker_total=4 natural=false return_cents=156000 bankroll_cents=1938425 heat=3 opponent_profit_cents=68000 reveal_count=0
hand stage=10 hand=11 bet=banker bet_cents=80000 winner=banker player_total=0 banker_total=8 natural=false return_cents=156000 bankroll_cents=2065625 heat=3 opponent_profit_cents=204000 reveal_count=0
hand stage=10 hand=12 bet=banker bet_cents=80000 winner=banker player_total=1 banker_total=8 natural=true return_cents=156000 bankroll_cents=2192825 heat=4 opponent_profit_cents=340000 reveal_count=0
stage_result stage=10 clear=true profit_cents=618400 opponent_profit_cents=340000 tolerance_cents=800000 bankroll_cents=2192825 heat=4 chips=17
finish completed=true final_stage=10 failure=run_complete ending_bankroll_cents=2192825 highest_bankroll_cents=2192825 heat=4 owned_mods=core.lucky-chip;banker.commission-dodge;economy.interest-ledger;banker.banco-press;heat.soft-footsteps
```

## anomaly_early_failure / optimized / 7565164398174258285

- Completed: no; final stage: 1; failure: `stage_1_opponent_loss`.
- Ending bankroll: $150; heat: 0; hands: 5; build: `core.lucky-chip`.
- Rewards: none.
- Modifiers picked: none.

```text
start seed=7565164398174258285 policy=optimized contact=contact.lucky-chip bankroll_cents=25000 chips=4 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25000 heat=0 chips=4 boss=none active_mods=core.lucky-chip
hand stage=1 hand=1 bet=banker bet_cents=2500 winner=player player_total=9 banker_total=2 natural=false return_cents=0 bankroll_cents=22500 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=2500 winner=player player_total=8 banker_total=0 natural=true return_cents=0 bankroll_cents=20000 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=player player_total=9 banker_total=8 natural=true return_cents=0 bankroll_cents=17500 heat=0 opponent_profit_cents=-2500 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=player player_total=5 banker_total=4 natural=false return_cents=0 bankroll_cents=15000 heat=0 opponent_profit_cents=-5000 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=tie player_total=5 banker_total=5 natural=false return_cents=2500 bankroll_cents=15000 heat=0 opponent_profit_cents=35000 reveal_count=0
stage_result stage=1 clear=false profit_cents=-10000 opponent_profit_cents=35000 tolerance_cents=22500 bankroll_cents=15000 heat=0 chips=4
finish completed=false final_stage=1 failure=stage_1_opponent_loss ending_bankroll_cents=15000 highest_bankroll_cents=22500 heat=0 owned_mods=core.lucky-chip
```

## anomaly_heat_failure / optimized / 12369800293157618446

- Completed: no; final stage: 10; failure: `stage_10_heat`.
- Ending bankroll: $9,618.75; heat: 10; hands: 72; build: `core.lucky-chip|debt.emergency-marker|economy.comp-points|economy.interest-ledger|heat.soft-footsteps`.
- Rewards: Rare Modifier Voucher, Rare Modifier Voucher, Ante Kickback, Table Comp, Capstone Invitation, Table Comp, High Table Cut, Vault Key, High Table Cut.
- Modifiers picked: economy.interest-ledger, debt.emergency-marker, economy.interest-ledger, heat.soft-footsteps, debt.emergency-marker, debt.emergency-marker, economy.comp-points, debt.last-dollar, economy.interest-ledger, heat.soft-footsteps, debt.last-dollar.

```text
start seed=12369800293157618446 policy=optimized contact=contact.lucky-chip bankroll_cents=25000 chips=4 heat=0
stage_start stage=1 hands=5 ante_cents=2500 min_bet_cents=2500 bankroll_cents=25000 heat=0 chips=4 boss=none active_mods=core.lucky-chip
hand stage=1 hand=1 bet=banker bet_cents=2500 winner=banker player_total=2 banker_total=6 natural=false return_cents=4875 bankroll_cents=27375 heat=0 opponent_profit_cents=2375 reveal_count=0
hand stage=1 hand=2 bet=banker bet_cents=2500 winner=banker player_total=1 banker_total=7 natural=false return_cents=4875 bankroll_cents=29750 heat=0 opponent_profit_cents=-125 reveal_count=0
hand stage=1 hand=3 bet=banker bet_cents=2500 winner=banker player_total=1 banker_total=8 natural=true return_cents=4875 bankroll_cents=32125 heat=0 opponent_profit_cents=-2625 reveal_count=0
hand stage=1 hand=4 bet=banker bet_cents=2500 winner=banker player_total=0 banker_total=4 natural=false return_cents=4875 bankroll_cents=34500 heat=0 opponent_profit_cents=-250 reveal_count=0
hand stage=1 hand=5 bet=banker bet_cents=2500 winner=banker player_total=0 banker_total=8 natural=true return_cents=4875 bankroll_cents=36875 heat=0 opponent_profit_cents=-5250 reveal_count=0
stage_result stage=1 clear=true profit_cents=11875 opponent_profit_cents=-5250 tolerance_cents=22500 bankroll_cents=36875 heat=0 chips=8
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=economy.interest-ledger;debt.emergency-marker
stage_start stage=2 hands=6 ante_cents=5000 min_bet_cents=5000 bankroll_cents=41125 heat=1 chips=3 boss=none active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker
hand stage=2 hand=1 bet=banker bet_cents=5000 winner=banker player_total=0 banker_total=8 natural=true return_cents=10000 bankroll_cents=46125 heat=1 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=2 bet=banker bet_cents=5000 winner=banker player_total=4 banker_total=9 natural=true return_cents=10000 bankroll_cents=51125 heat=1 opponent_profit_cents=10000 reveal_count=0
hand stage=2 hand=3 bet=banker bet_cents=5000 winner=player player_total=8 banker_total=5 natural=false return_cents=0 bankroll_cents=46125 heat=1 opponent_profit_cents=5000 reveal_count=0
hand stage=2 hand=4 bet=banker bet_cents=5000 winner=banker player_total=1 banker_total=9 natural=true return_cents=10000 bankroll_cents=51125 heat=1 opponent_profit_cents=10000 reveal_count=0
hand stage=2 hand=5 bet=banker bet_cents=5000 winner=banker player_total=0 banker_total=4 natural=false return_cents=10000 bankroll_cents=56125 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=2 hand=6 bet=banker bet_cents=5000 winner=banker player_total=1 banker_total=6 natural=false return_cents=10000 bankroll_cents=61125 heat=1 opponent_profit_cents=5000 reveal_count=0
stage_result stage=2 clear=true profit_cents=24250 opponent_profit_cents=5000 tolerance_cents=25000 bankroll_cents=61125 heat=1 chips=7
stage_reward_rewards=Rare Modifier Voucher
shop_modifiers=economy.interest-ledger;heat.soft-footsteps
stage_start stage=3 hands=7 ante_cents=7500 min_bet_cents=7500 bankroll_cents=69375 heat=1 chips=2 boss=none active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps
hand stage=3 hand=1 bet=banker bet_cents=7500 winner=banker player_total=2 banker_total=9 natural=true return_cents=14625 bankroll_cents=76500 heat=1 opponent_profit_cents=7125 reveal_count=0
hand stage=3 hand=2 bet=banker bet_cents=7500 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=69000 heat=1 opponent_profit_cents=14625 reveal_count=0
hand stage=3 hand=3 bet=banker bet_cents=7500 winner=banker player_total=2 banker_total=8 natural=true return_cents=14625 bankroll_cents=76125 heat=1 opponent_profit_cents=21750 reveal_count=0
hand stage=3 hand=4 bet=banker bet_cents=7500 winner=banker player_total=0 banker_total=6 natural=false return_cents=14625 bankroll_cents=83250 heat=1 opponent_profit_cents=28875 reveal_count=0
hand stage=3 hand=5 bet=banker bet_cents=7500 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=75750 heat=1 opponent_profit_cents=21375 reveal_count=0
hand stage=3 hand=6 bet=banker bet_cents=7500 winner=player player_total=9 banker_total=6 natural=true return_cents=0 bankroll_cents=68250 heat=1 opponent_profit_cents=28875 reveal_count=0
hand stage=3 hand=7 bet=banker bet_cents=7500 winner=banker player_total=3 banker_total=9 natural=true return_cents=14625 bankroll_cents=75375 heat=1 opponent_profit_cents=36000 reveal_count=0
stage_result stage=3 clear=true profit_cents=14250 opponent_profit_cents=36000 tolerance_cents=37500 bankroll_cents=75375 heat=1 chips=6
stage_reward_rewards=Ante Kickback
shop_modifiers=debt.emergency-marker;debt.emergency-marker
stage_start stage=4 hands=8 ante_cents=10000 min_bet_cents=10000 bankroll_cents=101375 heat=1 chips=0 boss=none active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps
hand stage=4 hand=1 bet=banker bet_cents=10000 winner=banker player_total=3 banker_total=5 natural=false return_cents=19500 bankroll_cents=110875 heat=1 opponent_profit_cents=19000 reveal_count=0
hand stage=4 hand=2 bet=banker bet_cents=10000 winner=player player_total=9 banker_total=3 natural=false return_cents=0 bankroll_cents=100875 heat=1 opponent_profit_cents=-1000 reveal_count=0
hand stage=4 hand=3 bet=banker bet_cents=10000 winner=banker player_total=8 banker_total=9 natural=true return_cents=19500 bankroll_cents=110375 heat=1 opponent_profit_cents=18000 reveal_count=0
hand stage=4 hand=4 bet=banker bet_cents=10000 winner=player player_total=9 banker_total=4 natural=false return_cents=0 bankroll_cents=100375 heat=1 opponent_profit_cents=8000 reveal_count=0
hand stage=4 hand=5 bet=banker bet_cents=10000 winner=banker player_total=1 banker_total=8 natural=false return_cents=19500 bankroll_cents=109875 heat=1 opponent_profit_cents=27000 reveal_count=0
hand stage=4 hand=6 bet=banker bet_cents=10000 winner=player player_total=9 banker_total=1 natural=false return_cents=0 bankroll_cents=99875 heat=1 opponent_profit_cents=7000 reveal_count=0
hand stage=4 hand=7 bet=banker bet_cents=10000 winner=banker player_total=3 banker_total=6 natural=false return_cents=19500 bankroll_cents=109375 heat=1 opponent_profit_cents=26000 reveal_count=0
hand stage=4 hand=8 bet=banker bet_cents=10000 winner=banker player_total=5 banker_total=9 natural=true return_cents=19500 bankroll_cents=118875 heat=1 opponent_profit_cents=16000 reveal_count=0
stage_result stage=4 clear=true profit_cents=28500 opponent_profit_cents=16000 tolerance_cents=80000 bankroll_cents=118875 heat=1 chips=4
stage_reward_rewards=Table Comp
shop_modifiers=economy.comp-points
stage_start stage=5 hands=8 ante_cents=15000 min_bet_cents=15000 bankroll_cents=165375 heat=1 chips=0 boss=Pit Boss active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps;economy.comp-points
hand stage=5 hand=1 bet=banker bet_cents=15000 winner=tie player_total=8 banker_total=8 natural=false return_cents=15000 bankroll_cents=165375 heat=1 opponent_profit_cents=0 reveal_count=0
hand stage=5 hand=2 bet=banker bet_cents=15000 winner=player player_total=8 banker_total=4 natural=false return_cents=0 bankroll_cents=150375 heat=1 opponent_profit_cents=-15000 reveal_count=0
hand stage=5 hand=3 bet=banker bet_cents=15000 winner=player player_total=6 banker_total=5 natural=false return_cents=0 bankroll_cents=135375 heat=1 opponent_profit_cents=3000 reveal_count=0
hand stage=5 hand=4 bet=banker bet_cents=15000 winner=banker player_total=0 banker_total=9 natural=true return_cents=29250 bankroll_cents=154125 heat=2 opponent_profit_cents=-9000 reveal_count=0
hand stage=5 hand=5 bet=banker bet_cents=15000 winner=player player_total=7 banker_total=3 natural=false return_cents=0 bankroll_cents=139125 heat=2 opponent_profit_cents=-36000 reveal_count=0
hand stage=5 hand=6 bet=banker bet_cents=15000 winner=banker player_total=0 banker_total=2 natural=false return_cents=29250 bankroll_cents=153375 heat=2 opponent_profit_cents=-48000 reveal_count=0
hand stage=5 hand=7 bet=banker bet_cents=15000 winner=player player_total=9 banker_total=3 natural=false return_cents=0 bankroll_cents=138375 heat=2 opponent_profit_cents=-60000 reveal_count=0
hand stage=5 hand=8 bet=banker bet_cents=15000 winner=tie player_total=7 banker_total=7 natural=false return_cents=15000 bankroll_cents=138375 heat=3 opponent_profit_cents=-57000 reveal_count=0
stage_result stage=5 clear=true profit_cents=-10500 opponent_profit_cents=-57000 tolerance_cents=105000 bankroll_cents=138375 heat=5 chips=7
boss_reward_rewards=Capstone Invitation
shop_modifiers=debt.last-dollar
stage_start stage=6 hands=8 ante_cents=20000 min_bet_cents=20000 bankroll_cents=160375 heat=5 chips=3 boss=none active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps;economy.comp-points
hand stage=6 hand=1 bet=banker bet_cents=20000 winner=tie player_total=4 banker_total=4 natural=false return_cents=20000 bankroll_cents=160375 heat=5 opponent_profit_cents=0 reveal_count=0
hand stage=6 hand=2 bet=banker bet_cents=20000 winner=player player_total=7 banker_total=2 natural=false return_cents=0 bankroll_cents=140375 heat=5 opponent_profit_cents=-20000 reveal_count=0
hand stage=6 hand=3 bet=banker bet_cents=20000 winner=banker player_total=0 banker_total=9 natural=true return_cents=39000 bankroll_cents=165375 heat=5 opponent_profit_cents=-1000 reveal_count=0
hand stage=6 hand=4 bet=banker bet_cents=20000 winner=banker player_total=5 banker_total=6 natural=false return_cents=39000 bankroll_cents=184375 heat=5 opponent_profit_cents=-21000 reveal_count=0
hand stage=6 hand=5 bet=banker bet_cents=20000 winner=banker player_total=1 banker_total=9 natural=true return_cents=39000 bankroll_cents=203375 heat=5 opponent_profit_cents=-61000 reveal_count=0
hand stage=6 hand=6 bet=banker bet_cents=20000 winner=banker player_total=0 banker_total=6 natural=false return_cents=39000 bankroll_cents=222375 heat=5 opponent_profit_cents=-81000 reveal_count=0
hand stage=6 hand=7 bet=banker bet_cents=20000 winner=banker player_total=1 banker_total=5 natural=false return_cents=39000 bankroll_cents=241375 heat=5 opponent_profit_cents=-101000 reveal_count=0
hand stage=6 hand=8 bet=banker bet_cents=20000 winner=banker player_total=0 banker_total=7 natural=false return_cents=39000 bankroll_cents=260375 heat=5 opponent_profit_cents=-121000 reveal_count=0
stage_result stage=6 clear=true profit_cents=122000 opponent_profit_cents=-121000 tolerance_cents=140000 bankroll_cents=260375 heat=5 chips=8
stage_reward_rewards=Table Comp
shop_modifiers=economy.interest-ledger
stage_start stage=7 hands=9 ante_cents=30000 min_bet_cents=30000 bankroll_cents=365375 heat=5 chips=4 boss=none active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps;economy.comp-points
hand stage=7 hand=1 bet=banker bet_cents=30000 winner=player player_total=8 banker_total=2 natural=false return_cents=0 bankroll_cents=335375 heat=5 opponent_profit_cents=-30000 reveal_count=0
hand stage=7 hand=2 bet=banker bet_cents=30000 winner=player player_total=8 banker_total=0 natural=true return_cents=0 bankroll_cents=305375 heat=5 opponent_profit_cents=-60000 reveal_count=0
hand stage=7 hand=3 bet=banker bet_cents=30000 winner=player player_total=8 banker_total=6 natural=false return_cents=0 bankroll_cents=275375 heat=5 opponent_profit_cents=30000 reveal_count=0
hand stage=7 hand=4 bet=banker bet_cents=30000 winner=tie player_total=2 banker_total=2 natural=false return_cents=30000 bankroll_cents=275375 heat=5 opponent_profit_cents=30000 reveal_count=0
hand stage=7 hand=5 bet=banker bet_cents=30000 winner=tie player_total=7 banker_total=7 natural=false return_cents=30000 bankroll_cents=275375 heat=5 opponent_profit_cents=30000 reveal_count=0
hand stage=7 hand=6 bet=banker bet_cents=30000 winner=player player_total=8 banker_total=6 natural=false return_cents=0 bankroll_cents=245375 heat=5 opponent_profit_cents=120000 reveal_count=0
hand stage=7 hand=7 bet=banker bet_cents=30000 winner=player player_total=9 banker_total=7 natural=false return_cents=0 bankroll_cents=215375 heat=5 opponent_profit_cents=90000 reveal_count=0
hand stage=7 hand=8 bet=banker bet_cents=30000 winner=player player_total=8 banker_total=1 natural=true return_cents=0 bankroll_cents=185375 heat=5 opponent_profit_cents=60000 reveal_count=0
hand stage=7 hand=9 bet=banker bet_cents=30000 winner=banker player_total=3 banker_total=8 natural=true return_cents=58500 bankroll_cents=222875 heat=5 opponent_profit_cents=145500 reveal_count=0
stage_result stage=7 clear=true profit_cents=-97500 opponent_profit_cents=145500 tolerance_cents=360000 bankroll_cents=222875 heat=6 chips=8
stage_reward_rewards=High Table Cut
shop_modifiers=heat.soft-footsteps
stage_start stage=8 hands=10 ante_cents=40000 min_bet_cents=40000 bankroll_cents=402875 heat=6 chips=5 boss=The Inspector active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps;economy.comp-points
hand stage=8 hand=1 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=2 natural=false return_cents=0 bankroll_cents=362875 heat=6 opponent_profit_cents=-40000 reveal_count=0
hand stage=8 hand=2 bet=banker bet_cents=40000 winner=banker player_total=2 banker_total=7 natural=false return_cents=78000 bankroll_cents=412875 heat=6 opponent_profit_cents=-80000 reveal_count=0
hand stage=8 hand=3 bet=banker bet_cents=40000 winner=tie player_total=5 banker_total=5 natural=false return_cents=40000 bankroll_cents=412875 heat=6 opponent_profit_cents=-80000 reveal_count=0
hand stage=8 hand=4 bet=banker bet_cents=40000 winner=banker player_total=4 banker_total=9 natural=true return_cents=78000 bankroll_cents=450875 heat=6 opponent_profit_cents=-42000 reveal_count=0
hand stage=8 hand=5 bet=banker bet_cents=40000 winner=banker player_total=5 banker_total=6 natural=false return_cents=78000 bankroll_cents=488875 heat=6 opponent_profit_cents=-4000 reveal_count=0
hand stage=8 hand=6 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=5 natural=false return_cents=78000 bankroll_cents=526875 heat=6 opponent_profit_cents=-44000 reveal_count=0
hand stage=8 hand=7 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=4 natural=false return_cents=78000 bankroll_cents=564875 heat=6 opponent_profit_cents=-6000 reveal_count=0
hand stage=8 hand=8 bet=banker bet_cents=40000 winner=banker player_total=0 banker_total=3 natural=false return_cents=78000 bankroll_cents=602875 heat=6 opponent_profit_cents=32000 reveal_count=0
hand stage=8 hand=9 bet=banker bet_cents=40000 winner=player player_total=7 banker_total=0 natural=false return_cents=0 bankroll_cents=562875 heat=6 opponent_profit_cents=-8000 reveal_count=0
hand stage=8 hand=10 bet=banker bet_cents=40000 winner=player player_total=9 banker_total=1 natural=true return_cents=0 bankroll_cents=522875 heat=6 opponent_profit_cents=32000 reveal_count=0
stage_result stage=8 clear=true profit_cents=180000 opponent_profit_cents=32000 tolerance_cents=400000 bankroll_cents=522875 heat=6 chips=12
boss_reward_rewards=Vault Key
stage_start stage=9 hands=10 ante_cents=60000 min_bet_cents=60000 bankroll_cents=612875 heat=6 chips=13 boss=none active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps;economy.comp-points
hand stage=9 hand=1 bet=banker bet_cents=60000 winner=player player_total=9 banker_total=0 natural=true return_cents=0 bankroll_cents=552875 heat=8 opponent_profit_cents=60000 reveal_count=0
hand stage=9 hand=2 bet=banker bet_cents=60000 winner=banker player_total=7 banker_total=8 natural=true return_cents=117000 bankroll_cents=627875 heat=8 opponent_profit_cents=117000 reveal_count=0
hand stage=9 hand=3 bet=banker bet_cents=60000 winner=player player_total=8 banker_total=3 natural=true return_cents=0 bankroll_cents=567875 heat=8 opponent_profit_cents=57000 reveal_count=0
hand stage=9 hand=4 bet=banker bet_cents=60000 winner=player player_total=7 banker_total=5 natural=false return_cents=0 bankroll_cents=507875 heat=8 opponent_profit_cents=-3000 reveal_count=0
hand stage=9 hand=5 bet=banker bet_cents=60000 winner=tie player_total=6 banker_total=6 natural=false return_cents=60000 bankroll_cents=507875 heat=8 opponent_profit_cents=-3000 reveal_count=0
hand stage=9 hand=6 bet=banker bet_cents=60000 winner=player player_total=8 banker_total=5 natural=false return_cents=0 bankroll_cents=447875 heat=8 opponent_profit_cents=-63000 reveal_count=0
hand stage=9 hand=7 bet=banker bet_cents=60000 winner=player player_total=9 banker_total=6 natural=false return_cents=0 bankroll_cents=387875 heat=8 opponent_profit_cents=-123000 reveal_count=0
hand stage=9 hand=8 bet=banker bet_cents=60000 winner=banker player_total=2 banker_total=6 natural=false return_cents=117000 bankroll_cents=444875 heat=8 opponent_profit_cents=-66000 reveal_count=0
hand stage=9 hand=9 bet=banker bet_cents=60000 winner=tie player_total=4 banker_total=4 natural=false return_cents=60000 bankroll_cents=444875 heat=8 opponent_profit_cents=-66000 reveal_count=0
hand stage=9 hand=10 bet=banker bet_cents=60000 winner=banker player_total=6 banker_total=9 natural=true return_cents=117000 bankroll_cents=501875 heat=8 opponent_profit_cents=-186000 reveal_count=0
stage_result stage=9 clear=true profit_cents=-21000 opponent_profit_cents=-186000 tolerance_cents=600000 bankroll_cents=501875 heat=9 chips=19
stage_reward_rewards=High Table Cut
shop_modifiers=debt.last-dollar
stage_start stage=10 hands=12 ante_cents=80000 min_bet_cents=80000 bankroll_cents=861875 heat=9 chips=15 boss=The House active_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps;economy.comp-points
hand stage=10 hand=1 bet=banker bet_cents=80000 winner=banker player_total=7 banker_total=8 natural=true return_cents=156000 bankroll_cents=961875 heat=10 opponent_profit_cents=76000 reveal_count=0
stage_result stage=10 clear=false profit_cents=220000 opponent_profit_cents=76000 tolerance_cents=800000 bankroll_cents=961875 heat=10 chips=16
finish completed=false final_stage=10 failure=stage_10_heat ending_bankroll_cents=961875 highest_bankroll_cents=961875 heat=10 owned_mods=core.lucky-chip;economy.interest-ledger;debt.emergency-marker;heat.soft-footsteps;economy.comp-points
```

