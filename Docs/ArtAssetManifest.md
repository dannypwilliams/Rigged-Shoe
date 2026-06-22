# Rigged Shoe Art Asset Manifest

This manifest tracks the visual assets needed to make the early run readable and shippable. Use `Status` values of `Needed`, `Placeholder`, `In Progress`, or `Final`.

## A. App Identity

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| App icon | Home screen and store identity | iOS app icon set | Needed | Logo should read as rigged casino shoe plus playing card edge. |
| Wordmark | Title, splash, and menu use | Vector or high-res PNG | Needed | Keep legible at compact mobile sizes. |
| Small mark | Toolbar/profile use | 128px transparent PNG | Needed | Simplified from app icon. |

## B. Casino Floor And Room Backdrops

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Casino floor backdrop | Main floor background | 2732x2732 PNG/WebP | Needed | Real table signals, not abstract gradients. |
| Baccarat room backdrop | Battle first screen | 2732x1536 PNG/WebP | Needed | Must leave table controls readable. |
| Shop counter backdrop | Shop phase | 2732x1536 PNG/WebP | Needed | Quiet enough behind offer cards. |
| Boss room backdrop | Boss stage preview/battle | 2732x1536 PNG/WebP | Needed | Higher pressure, distinct from normal rooms. |

## C. Baccarat Table And Felt

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Felt surface texture | Table panel material | Tileable PNG/WebP | Placeholder | Needs subtle wear and card-table grain. |
| Bet zones | Player/Banker/Tie board areas | Vector or 2x PNG | Placeholder | Must clearly separate tap targets. |
| Shoe tray | Visible shoe/X-Ray area | 2x PNG | Needed | Needs covered and revealed states. |
| Discard tray | Past hand readback | 2x PNG | Needed | Secondary detail only. |

## D. Cards And Shoe Reads

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Card front set | Player/Banker hands | 2x/3x PNG or vector | Placeholder | Needs clear ranks at small sizes. |
| Card back | Hidden cards and deck | 2x/3x PNG | Placeholder | Should match casino brand. |
| Obstructed card | Smudged/unknown read | 2x/3x PNG | Needed | Used when reads are partial. |
| X-Ray highlight | Charged reveal state | 2x/3x PNG or shader | Needed | Should feel actionable, not decorative. |

## E. Chips, Bankroll, And Heat

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Chip stack icons | Run chips and shop prices | 2x/3x PNG | Needed | Different from permanent profile chips if profile currency remains. |
| Bankroll chip | Cash/bankroll metric | 2x/3x PNG | Needed | Green or white chip preferred. |
| Heat icon states | Surveillance pressure | 2x/3x PNG | Needed | Low/mid/high should scan instantly. |
| Reward burst | Stage chips/cash feedback | Sprite or PNG sequence | Needed | Used sparingly after wins/rewards. |

## F. Opponents And Bosses

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Opponent portraits | Stage preview scout report | 1024px square PNG/WebP | Needed | One per early opponent first, then full set. |
| Boss portraits | Boss previews and warnings | 1536px portrait PNG/WebP | Needed | Pit Boss, Inspector, and House are priority. |
| Table tell icons | Opponent lean/pressure point | 2x/3x PNG | Needed | Small icons for banker, player, tie, heat, random. |

## G. Modifiers, Upgrades, Consumables, Relics

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Modifier rarity frames | Shop/current build cards | 2x/3x PNG or vector | Placeholder | Common through legendary plus boss. |
| Modifier icons | Each modifier card | 512px PNG/WebP | Needed | Start with early pool: Lucky Chip, Opening Tell, House Favorite, Countertrend, Punto Insurance. |
| Consumable icons | Shop/use buttons | 512px PNG/WebP | Needed | Must distinguish one-shot items from modifiers. |
| Attachment badges | Attached modifier row | 256px PNG | Needed | Small enough for current-build rows. |
| Boss relic icons | Boss rewards | 512px PNG/WebP | Needed | More premium than normal upgrades. |

## H. Shop And Reward Draft

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Shop offer backing | Offer card texture | 2x/3x PNG | Placeholder | Must not reduce text contrast. |
| Freeze badge | Frozen offer state | 2x/3x PNG | Needed | Should read at small size. |
| Sold-out badge | Bought offer state | 2x/3x PNG | Needed | Muted and clear. |
| Reward draft highlight | Pickable reward state | 2x/3x PNG | Needed | Differentiate build-fit and pivot choices. |

## I. Tutorial And Glossary

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Baccarat hand diagram | Tutorial card values | 2x/3x PNG | Needed | Explains modulo-10 scoring visually. |
| Banker commission diagram | Tutorial payout | 2x/3x PNG | Needed | Include No Commission contrast. |
| Shoe read diagram | Tutorial reveal/X-Ray | 2x/3x PNG | Needed | Show passive read vs charged read. |

## J. Battle Feedback VFX

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Win pulse | Normal winning hand | Sprite/particle texture | Placeholder | Keep subtle for repeated play. |
| Big win burst | Large payout hand | Sprite/particle texture | Placeholder | Used only for higher win tiers. |
| Heat spike flash | Heat gain warning | Sprite/particle texture | Needed | Must be readable without relying on color alone. |
| Modifier trigger sparkle | Battle log/hand feedback | Sprite/particle texture | Placeholder | Should not obscure cards. |

## K. Empty, Locked, And Failure States

| Asset | Purpose | Size / Format | Status | Notes |
| --- | --- | --- | --- | --- |
| Empty build mark | Current Build empty state | 512px PNG/WebP | Needed | Quiet helper art, not a marketing illustration. |
| Locked reveal mark | Boss/no-reveal state | 512px PNG/WebP | Needed | Pairs with X-Ray suppressed copy. |
| Run failure stamp | Run over screen | 1024px PNG/WebP | Needed | Casino paperwork/trespass vibe. |
| Victory stamp | Completed run screen | 1024px PNG/WebP | Needed | Keep grounded in the casino theme. |

## L. Production Rules

| Rule | Requirement |
| --- | --- |
| Naming | Use `category_asset_state@scale.ext`, for example `modifier_lucky_chip_final@3x.png`. |
| Contrast | Any background or card art behind text must pass a quick in-app readability check. |
| Cropping | Primary subject must be visible in compact mobile layouts. Avoid dark, blurred, or purely atmospheric assets. |
| Exports | Prefer WebP/PNG for raster art, vector only for simple marks and frames. |
| Source files | Store editable source files outside the app target and export optimized runtime assets into the asset catalog. |
| Review | Add screenshots to `Docs/PlaytestScreenshots/` whenever replacing placeholder art in battle, shop, or preview screens. |
