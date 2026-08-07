# Patch Notes

## Repository version 1.0.19 — Expanded conversations

### Added

- Expanded the Old Friends conversation library from 36 to 96 exchanges.
- Added more general banter plus new Bedroom, Reminiscence, wounded, veteran, away-from-Home, era, upgrade, close-call, victory, and reunion dialogue.
- Added dynamic `{SELF}`, `{OTHER}`, `{LOCATION}`, `{ERA}`, `{FORM}`, and `{OTHER_FORM}` dialogue tokens.

### Improved

- Made exchanges refer directly to the participating friends, their current unit forms, the current era, and their location where appropriate.
- Preserved per-pair no-repeat history, allowing substantially longer campaigns before a pair exhausts its available dialogue.

## Repository version 1.0.18 — Event conversation data

### Added

- Added dedicated conversations for new eras, unit upgrades, near-death survival, enemy defeats, Reminiscence activations, and reunions after at least 15 turns apart.
- Added a 35% event-conversation chance while preserving the global and per-pair cooldowns.
- Added event labels to the conversation panel so the cause of each exchange is clear.
- Added `Data/CommonwealthConversations.xml` with 36 total exchanges in a custom Civ V `GameInfo` table.

### Changed

- Moved all conversation text and categories out of Lua and into the external database XML file.
- Kept Lua responsible only for event detection, probability, persistence, cooldowns, and UI delivery.

## Repository version 1.0.17 — Old Friends conversations

### Added

- Added a 4% per-turn conversation chance for each adjacent Old Friend pair.
- Added 21 conversation exchanges covering general memories, Reminiscences, Childhood Bedrooms, veteran friends, near-death survivors, and journeys away from Home.
- Added a compact non-blocking conversation panel showing both friends' names, gamertags, dialogue, turn, and location.
- Added conversation counts and conversation events to persistent Ledger profiles and timelines.
- Added a Ledger control that enables or disables spontaneous conversations per player.

### Balance

- Limited conversations to one every 12 turns globally and one every 25 turns for the same pair.
- Prevented each dialogue exchange from repeating for the same pair.
- Increased the conversation chance during a Reminiscence and near a Childhood Bedroom.

## Repository version 1.0.16 — Silent Dawn of Man

### Changed

- Removed the American Dawn of Man audio previously inherited by the Commonwealth.
- Preserved the custom Dawn of Man artwork, introduction text, and normal gameplay soundtrack.

## Version 1 hotfix — Random Old Friend identities

### Added

- Added 54 generated Old Friend names and 72 generated gamertags, selected independently for much greater variety.
- Added alternate tribute gamertags to the advanced Ledger's profile display.

### Improved

- Randomized Old Friend identities while weighting Trent, Gabriel, Dion, Harrison, Lachlan, and Ben eight times higher than generated names.
- Prevented generated names and gamertags from repeating until their available pools are exhausted.

### Fixed

- Replaced the unsupported `TwCenMT15` Ledger font with Civ V's `TwCenMT16`, preventing the font XML load dialog.

## Version 1 hotfix — Advanced Old Friends Ledger

### Added

- Added permanent Friend IDs and archive records that persist through saves, upgrades, and death.
- Added Online, Offline, and All Ledger filters with selectable profile cards.
- Added profile fields for gamertag, epithet, status, form, creation era/turn, Years Together, level, XP, location, eras survived, and Memories generated.
- Added movement, battle, kill, lowest-HP, upgrade, lineage, and adjacent-turn friendship tracking through Vox Populi gameplay and combat events.
- Added chronological creation, era-transition, upgrade, near-death, kill, and death timeline entries.
- Added derived epithets, closest-friend records, Locate for living units, and a narrative Remember action.
- Added migration from the original lightweight living-unit records when a game first loads the advanced archive.

### Improved

- Inset the civilization map by eight pixels on every side so its artwork stays beneath the Dawn of Man frame.
- Re-encoded the map as DXT5 to preserve the transparent frame-safe margin.

## Version 1 hotfix — Civilization map artwork

### Added

- Added the supplied crossroads artwork as the Commonwealth's civilization map image.
- Downsampled the source directly from 720×824 to Civ V's required 360×412 dimensions without cropping or stretching.
- Exported the map as DXT1 DDS and enabled VFS import in the ModBuddy project and checked-in manifest.

## Version 1 hotfix — Full-name civilization selection

### Improved

- Added a front-end civilization-selection override with separate lines for the full leader/civilization heading, full trait name, and trait description.
- Increased selection rows from 100 to 128 pixels so long names and multi-line descriptions no longer overlap adjacent civilizations.
- Restored `The Commonwealth of Yesterday` in compact civilization contexts now that the selection screen can display the full name safely.
- Preserved scenario selection, random civilization selection, sorting, unique-component icons, and tooltips from the stock screen.

### Compatibility

- This VFS override affects the civilization-selection screen while the mod is enabled and may conflict with another enabled mod that replaces `UI/FrontEnd/GameSetup/SelectCivilization`.

## Version 1 hotfix — Icon framing and scale

### Improved

- Scaled The Child We Were's leader portrait inward so it has breathing room inside Civ V's leader-selection frame.
- Added matching layered gold borders to the Old Friend and Childhood Bedroom icons.
- Inset the Old Friend and Bedroom artwork within transparent margins so their borders remain visible at every atlas size.
- Regenerated all three DXT5 atlases at 256, 128, 80, 64, 45, and 32 pixels.

## Version 1 hotfix — Restore trait name

### Changed

- Restored the full in-game trait name, `We Didn't Know We Were Making Memories`, at the player's request. The compact civilization name and shortened trait summary remain in place.

## Version 1 hotfix — Leader-selection layout

### Fixed

- Shortened the compact civilization name to `The Commonwealth` so Civ V's leader-selection title does not run beneath the unique-component icons.
- Temporarily shortened the selection-screen trait label; this was subsequently reverted so the full official trait name appears in game.
- Rewrote the trait summary to fit the fixed-height selection row without colliding with the next leader.

## Version 1 hotfix — Civilization and unique component icons

### Added

- Added the supplied sunset-house image as the civilization icon, including a separate tintable house alpha emblem for map and setup contexts.
- Added the supplied warrior portrait as the Old Friend unit icon.
- Added the supplied room artwork as the Childhood Bedroom building icon.
- Generated transparent DXT5 textures at 256, 128, 80, 64, 45, and 32 pixels for all three colour atlases, plus the required 128, 80, 64, 45, and 32-pixel civilization alpha atlas.
- Registered all atlases before the core SQL and enabled VFS import for every texture.

## Version 1 hotfix — Leader icon

### Added

- Added the supplied portrait as The Child We Were's leader icon.
- Generated transparent DXT5 atlas textures at Civ V's required 256, 128, 80, 64, 45, and 32-pixel sizes.
- Registered the new leader atlas before the core civilization database action and enabled VFS import for every DDS texture.

## Version 1 hotfix — Dawn of Man artwork

### Added

- Added the supplied childhood-bedroom artwork as the Commonwealth's Dawn of Man image.
- Center-cropped the source to 4:3, resized it to Civ V's 1024×768 Dawn of Man dimensions, and exported it as a DXT1 DDS texture.
- Registered the texture in the database, checked-in mod manifest, and ModBuddy project with VFS import enabled.

## Version 1 hotfix — Ledger control style

### Fixed

- Replaced the invalid `Grid9DetailTwo` Old Friend row style with Civ V's supported `GridBlackIndent8` style. Opening the Ledger no longer raises a Control Definition Error.

## Version 1 hotfix — Starting roster and interface

### Fixed

- Removed the explicitly granted Warrior. Civ V's handicap rules already supply a starting defender, which becomes the Old Friend through the civilization override; granting another produced two Old Friends.
- Replaced the always-visible top-right Memories bar with a compact button below the standard interface controls.
- Moved Reminiscence and Ledger controls into styled popups so they no longer overlap the turn counter, help, menu, or notification area.
- Normalized punctuation in the panel's dynamic text.

## Version 1 hotfix — Starting units

### Fixed

- Added the Commonwealth's starting Settler and Old Friend. Previously the civilization began with neither a city nor a Settler, causing Civ V to eliminate the player as soon as the game started.

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
