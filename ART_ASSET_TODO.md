# Rigged Shoe Art Asset TODO

Target style: Crooked Casino Doodle Cartoon. Drop PNGs into `RiggedShoe/Assets.xcassets` using the asset names below without the `.png` suffix.

## 2026-06-23 RC Status

- Current vertical-slice build is safe to ship with SwiftUI fallback art for code QA.
- First real art pass should prioritize gameplay readability over decoration.
- Highest-impact missing assets: `card_frame_common_crooked`, `card_frame_rare_crooked`, `card_back_red_crooked`, `dealer_shoe_idle`, `chip_5`, `panel_felt_dark`, contact portraits, table-rule stamps, and heat pressure icons.
- Add Pit Boss Skim and Crackdown icon/stamp assets before a wider TestFlight pass so visible heat responses read instantly.
- Keep all functional labels in SwiftUI text; art should support the crooked casino tone without replacing essential rules copy.

## Required First Pack

## card_frame_common_crooked.png
- Used in: `CardView`, `CrookedCasinoCard`, common upgrade/reward fallback frames.
- Suggested size: 512x768 PNG.
- Transparency: Yes.
- Description: Faded cream card frame with wobbly thick black outline, inner border, tiny red star doodles, scuffs, and uneven marker texture.
- Priority: Required for first real art pass.
- Fallback: SwiftUI-drawn crooked cream card with ink outline, paper grain, inner accent border, and doodle marks.

## card_frame_rare_crooked.png
- Used in: rare upgrade cards, attachment/shop cards, high-value reward cards.
- Suggested size: 512x768 PNG.
- Transparency: Yes.
- Description: Cream card with dirty gold accent strip, uneven black outline, worn corners, and suspicious casino doodles.
- Priority: Required for first real art pass.
- Fallback: SwiftUI card frame with dirty gold accent and paper scuffs.

## card_back_red_crooked.png
- Used in: face-down playing cards, shoe preview hidden cards, flying deal cards.
- Suggested size: 512x768 PNG.
- Transparency: Yes.
- Description: Muted red card back, crooked black border, rough RS/Shoe mark, dirty gold details, imperfect printed pattern.
- Priority: Required for first real art pass.
- Fallback: SwiftUI red card back with rough border, doodles, and RS/Shoe text.

## dealer_shoe_idle.png
- Used in: `DealerShoeView`, `ShoeView`, `ShoePreviewView`, `RoundResultView`.
- Suggested size: 768x512 PNG.
- Transparency: Yes.
- Description: Squat red-brown dealer shoe with red-backed cards, uneven black outline, suspicious mismatched eyes, crooked grin, HOUSE plate, scratches, chipped corner, and white-gloved hand.
- Priority: Required for first real art pass.
- Fallback: SwiftUI-drawn cartoon shoe with cards, eyes, grin, HOUSE plate, scratches, and glove.

## dealer_shoe_laughing.png
- Used in: `DealerShoeView` state support for future win/loss feedback.
- Suggested size: 768x512 PNG.
- Transparency: Yes.
- Description: Same shoe mascot laughing or bouncing, mouth wider, eyes expressive, slightly more chaotic cards.
- Priority: Optional next.
- Fallback: SwiftUI shoe fallback uses the same mascot with a different mouth state when that state is requested.

## chip_1.png
- Used in: `CrookedChipView` asset system and future low-value currency badges.
- Suggested size: 256x256 PNG.
- Transparency: Yes.
- Description: Wobbly white poker chip with uneven edge marks, off-center handwritten 1, tiny nervous face, black scuffs.
- Priority: Optional next.
- Fallback: SwiftUI-drawn uneven chip.

## chip_5.png
- Used in: bet buttons, currency strips, chip/cost/reward visuals.
- Suggested size: 256x256 PNG.
- Transparency: Yes.
- Description: Wobbly red chip with uneven white edge marks, off-center handwritten 5, tiny nervous face, black rim scuffs.
- Priority: Required for first real art pass.
- Fallback: SwiftUI-drawn red chip.

## chip_25.png
- Used in: higher-value bet/currency visuals and future reward badges.
- Suggested size: 256x256 PNG.
- Transparency: Yes.
- Description: Wobbly green chip with rough white edge marks, handwritten 25, scuffs, and slightly cursed expression.
- Priority: Optional next.
- Fallback: SwiftUI-drawn chip color selected by value.

## button_red_wobbly.png
- Used in: `CrookedCasinoButtonStyle` red tone, warning/boss actions.
- Suggested size: 512x192 PNG or stretch-safe 9-slice style.
- Transparency: Yes.
- Description: Muted red crooked sticker button with thick uneven black outline, marker shading, tiny stars/scratches.
- Priority: Optional next.
- Fallback: SwiftUI crooked sticker button.

## button_black_wobbly.png
- Used in: disabled/secondary button states and blocked Deal button tone.
- Suggested size: 512x192 PNG or stretch-safe 9-slice style.
- Transparency: Yes.
- Description: Dusty black worn placard with uneven outline, paper scratches, muted highlights.
- Priority: Optional next.
- Fallback: SwiftUI crooked sticker button.

## panel_paper_torn.png
- Used in: generic paper panels and future modal/card-stock surfaces.
- Suggested size: 1024x768 PNG or stretch-safe panel.
- Transparency: Yes.
- Description: Torn stained paper panel, thick uneven ink outline, subtle coffee stain, scuffs, and tiny casino doodles.
- Priority: Optional next.
- Fallback: SwiftUI paper gradient panel with grain and doodles.

## panel_felt_dark.png
- Used in: main gameplay panels, HUD, bet dock, shop wrapper, result panels.
- Suggested size: 1024x768 PNG or stretch-safe panel.
- Transparency: Yes.
- Description: Dark worn felt plaque with rough black outline, faded table grain, small scratches and suit-symbol marks.
- Priority: Required for first real art pass.
- Fallback: SwiftUI dark felt panel with crooked outline and doodle marks.

## icon_eye_tell.png
- Used in: reveal/eye/read upgrade icons through `CrookedDoodleIconView`.
- Suggested size: 256x256 PNG.
- Transparency: Yes.
- Description: Hand-drawn suspicious eye, uneven outline, cheap marker fill, tiny sweat or tell marks.
- Priority: Optional next.
- Fallback: SF Symbol eye wrapped in crooked paper icon window.

## icon_loaded_shoe.png
- Used in: shoe/control/card-sculpting upgrade icons.
- Suggested size: 256x256 PNG.
- Transparency: Yes.
- Description: Mini loaded dealer shoe or card stack with crooked grin and rough red cards.
- Priority: Optional next.
- Fallback: SF Symbol stack wrapped in crooked paper icon window.

## icon_house_edge.png
- Used in: dealer exploit / house edge upgrade icons.
- Suggested size: 256x256 PNG.
- Transparency: Yes.
- Description: Crooked casino facade, sneaky eye, or HOUSE stamp with suspicious arrows.
- Priority: Optional next.
- Fallback: SF Symbol building wrapped in crooked paper icon window.

## icon_cold_streak.png
- Used in: cold/suppression/reveal-lock style icon support.
- Suggested size: 256x256 PNG.
- Transparency: Yes.
- Description: Faded blue cold streak mark, cracked card, icy scribble, or shivering chip.
- Priority: Optional next.
- Fallback: SF Symbol snowflake wrapped in crooked paper icon window.

## Additional Supported Names

- `card_frame_uncommon_crooked.png`: 512x768 transparent. Green-accent card frame for uncommon/shop modifier cards. Fallback: SwiftUI green-accent frame.
- `card_frame_legendary_crooked.png`: 512x768 transparent. Heavy dirty gold/red legendary frame. Fallback: SwiftUI gold frame with stronger doodle accent.
- `card_frame_cursed_crooked.png`: 512x768 transparent. Dark paper, smoke, red marks. Fallback: SwiftUI cursed dark frame.
- `card_frame_boss_crooked.png`: 512x768 transparent. Boss poster red/black/gold frame. Fallback: SwiftUI boss frame.
- `dealer_shoe_peeking.png`, `dealer_shoe_angry.png`, `dealer_shoe_rigged.png`, `dealer_shoe_busted.png`, `dealer_shoe_shuffling.png`, `dealer_shoe_reward.png`: 768x512 transparent. Future state art for shoe feedback. Fallback: SwiftUI shoe state variations.
- `chip_1_white.png`, `chip_5_red.png`, `chip_10_blue.png`, `chip_25_green.png`, `chip_50_black.png`, `chip_100_gold.png`: 256x256 transparent. Full denomination set. Fallback: SwiftUI chip by value/tone.
- `chip_stack_small.png`, `chip_stack_medium.png`, `chip_stack_large.png`, `chip_cost_badge.png`, `chip_reward_badge.png`: 256-512 transparent. Future shop/reward stacks and badges. Fallback: SwiftUI chip icons and sticker panels.
- `button_green_wobbly.png`, `button_gold_wobbly.png`, `button_disabled_wobbly.png`: 512x192 transparent or stretch-safe. Fallback: SwiftUI crooked sticker buttons.
- `panel_casino_red.png`, `panel_shop_paper.png`, `panel_reward_paper.png`, `panel_warning_black.png`, `panel_boss_red.png`: 1024x768 transparent or stretch-safe. Fallback: SwiftUI crooked panels by type.
