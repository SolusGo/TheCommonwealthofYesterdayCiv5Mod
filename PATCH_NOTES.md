# Patch Notes

## Version 1 — Initial playable release

### Added

- Playable Commonwealth of Yesterday civilization and The Child We Were leader.
- Sunset-orange and midnight-blue player colours, grassland bias, city list, diplomacy personality, and cultural AI flavors.
- Memories resource with a 100-point cap and game-speed-scaled Reminiscence/Melancholy durations.
- Memory rewards for era transitions, cities owned at transition, normal and Old Friend upgrades, Great Person expenditure, World Wonders, Keepsakes, and surviving Old Friends.
- Three player-selectable Reminiscences, escalating same-era prices, activation restrictions, and AI selection.
- Old Friend Warrior replacement, persistent Since the Beginning promotion, six Years Together levels, era healing, and Old Friend adjacency strength.
- Tribute names and gamertags for Trent, Gabriel, Dion, Harrison, Lachlan, and Ben.
- Childhood Bedroom Monument replacement with local Happiness, Keepsake aging, Culture scaling, and Memory generation.
- Compact Memories panel and living Old Friends Ledger.
- Persistent save data and load restoration.
- A complete ModBuddy `.civ5proj` with database actions, UI add-ins, source-file entries, and VFS settings.

### Current implementation differences

- The Boys Are Online uses a general city Production modifier rather than a military-unit-only Production modifier. Its adjacency combat component is implemented.
- One More World Before Bed currently implements the Worker movement and work-rate components. Internal trade-route yields and newly founded city Food are reserved for a later compatibility pass.
- The Summer That Never Ended implements Culture, Happiness, and Bedroom Food. Great Person rate and Golden Age Point multipliers are reserved for a later compatibility pass.
- Melancholy is tracked, displayed, and blocks activation. Category-specific negative yield modifiers are not applied in this release because negative dummy-building counts are unsafe in Civ V.
- Keepsake Tourism uses the Vox Populi city tourism setter when exposed. On DLL builds that omit it, Culture aging still works and Tourism is skipped safely.
- The Ledger currently lists living Old Friends and their core history. Offline profiles, detailed combat telemetry, relationship timelines, renaming, reunion notices, epithets, and achievements remain narrative/UI expansion work.
- Base-game art is used as placeholder art in version 1.

### Compatibility

- Target: Civilization V Brave New World with Community Patch / Vox Populi.
- Single-player only.
- A new game is required after database changes.
