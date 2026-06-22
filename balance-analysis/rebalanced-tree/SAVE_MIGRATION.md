# Save Migration Notes

Date: 2026-06-22

## Version

- `RunPersistenceManager.currentVersion` increased from 5 to 6.
- Saves with version 6 no longer persist `acquiredUpgradeNames` or `pendingUpgradeNames`.
- Restoring an older save converts legacy `UpgradeCard` records into deterministic Chips.

## Legacy Upgrade Conversion

Old acquired or pending upgrade names are not restored as gameplay effects.

Chip compensation:

| Legacy rarity | Chips |
| --- | ---: |
| Common | 1 |
| Rare | 3 |
| Legendary | 5 |

Unknown names receive no compensation.

## Runtime Rules

- `state.acquiredUpgrades` restores as an empty array.
- `state.pendingUpgradeChoices` restores as an empty array.
- Pending stage rewards restore only from `StageReward.productionRewards`.
- Pending boss rewards restore only from `BossReward.productionRewards`.
- Active and bench modifier instances restore only if their IDs are in `ActiveModifierCatalog`.
- Restored modifier levels are clamped to the active definition's max level.
- Restored shop offers are filtered through `ActiveModifierCatalog.productionShopOfferAllowed`.
- Boss upgrade-disabling state is restored with no legacy upgrade targets.

## Debug Paths

- Debug upgrade grants now convert to Chips instead of appending `UpgradeCard`.
- Legacy upgrade picker selection converts to Chips and clears the picker.
- The stress-layout debug helper now seeds active modifiers instead of legacy upgrades.

