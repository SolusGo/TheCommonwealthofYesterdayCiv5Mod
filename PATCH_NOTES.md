# Patch Notes

## Repository version 1.0.33 - Stable Old Friend definitions

### Removed

- Removed the entire Kid Kiyotaka conversion and White Room promotion-cleanup system.
- Removed all runtime deletion of non-Commonwealth promotions from Old Friends.

### Improved

- Restored normal Old Friend handling so **Since the Beginning** and all six **Years Together** tiers remain untouched.
- Added an optional ModBuddy reference to Kid Kiyotaka White Room so the Commonwealth loads after it whenever both mods are enabled.
- Marked the Commonwealth `Units` and `UnitPromotions` definitions as append-only and documented when a new game is required.

### Compatibility

- This correction is intended for a new game; saves already remapped by a changed database order cannot be repaired reliably.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.32 - Complete White Room cleanup

### Fixed

- Expanded restored Old Friend cleanup from selected Kiyotaka promotions to every White Room-owned `PROMOTION_WR_*` effect.
- Removed Controlled Environment and any White Room city-loss, training, operative, or adaptation promotion that may have crossed the save remapping.
- Continued preserving ordinary Civilization V promotions and all Commonwealth-specific promotions.

### Compatibility

- Cleanup applies to Old Friends already restored and saved by repository versions 1.0.30 or 1.0.31.
- Preserved all IDs and ModBuddy/.modinfo version `1`.

## Repository version 1.0.31 - Restored promotion cleanup

### Fixed

- Removed White Room Training, Perfect Adaptation, and every Kiyotaka-only adaptation promotion from restored Old Friends.
- Added cleanup for Old Friends that were already restored and saved by repository version 1.0.30.
- Preserved ordinary promotions, including any promotion that an Old Friend could have legitimately earned.

### Compatibility

- Cleanup runs at load and at the Commonwealth turn check, so an already-repaired save does not need to repeat the unit conversion.
- Preserved all IDs and ModBuddy/.modinfo version `1`.

## Repository version 1.0.30 - Old Friend save recovery

### Fixed

- Added a targeted repair for saved Commonwealth Old Friends that resolve as Kid Kiyotaka after the active mod database order changes.
- Restored affected units to the Old Friend type while preserving identity, experience, damage, promotions, position, and Ledger records.
- Suppressed creation, movement, and death handlers during conversion so the repair cannot generate a new identity or mark the original record Offline.
- Ran the repair when the load screen closes, with a second safety check at the start of the Commonwealth turn.

### Safety

- Only Commonwealth-owned Kiyotaka units with **Since the Beginning**, a legacy Old Friend identity, or an existing advanced Ledger mapping qualify for conversion.
- Legitimate Kiyotaka units and all units belonging to other civilizations are left unchanged.
- Preserved all IDs and ModBuddy/.modinfo version `1`.

## Repository version 1.0.29 - Free Bedroom Keepsakes

### Fixed

- Made Keepsake aging recognize policy-granted free Childhood Bedrooms as well as normally constructed copies.
- Made The Summer That Never Ended and Bedroom-adjacent Old Friend conversations recognize free Bedrooms.
- Free Bedrooms now initialize their acquisition era normally and receive their first Keepsake only at the next era transition; no retroactive Keepsake is granted.

### Compatibility

- Preserved all IDs and ModBuddy/.modinfo version `1`.

## Repository version 1.0.28 - Melancholy debuffs

### Added

- Implemented the original four-turn Melancholy penalties: -10% military-unit Production, -10% Science, or -10% Culture and -2 Happiness.
- Added four dedicated hidden penalty buildings whose real-building counts are strictly toggled between `0` and `1`.
- Used Vox Populi's signed `Unhappiness` field for September Morning, applying one capital-only source of 2 Unhappiness instead of an unsupported negative Happiness building.
- Displayed the active penalty in the Memories status label and expanded all three Reminiscence tooltips.
- Updated the Civilopedia and README with the implemented penalties.

### Safety

- Empire refreshes explicitly clear every inactive penalty building, preventing effects from stacking or remaining after Melancholy ends.
- No negative building counts or permanent player-yield mutations are used.

## Repository version 1.0.27 - Reminiscence status names

### Fixed

- Fixed an off-by-one Lua table index that displayed the previous Reminiscence name despite activating the correct gameplay effect.
- Corrected each corresponding Melancholy name, so One More World Before Bed now leads to The Sun Is Coming Up instead of Everyone Logged Off.
- Prefixed cooldown status text with `Melancholy:` to distinguish it clearly from an active Reminiscence.

## Repository version 1.0.26 - Expanded city names

### Added

- Expanded the Commonwealth city list from 6 to 36 names.
- Added names themed around home, childhood spaces, late nights, weekends, shared screens, and old online meeting places.
- Expanded the Cities of Yesterday Civilopedia section to explain the new names as part of the civilization's emotional geography.
- Kept Home, New Home, The Old Server, Summer's End, After School, and Last Light at the front of the founding order.

## Repository version 1.0.25 - Detailed Civilopedia

### Added

- Added nine headed Civilopedia sections for The Commonwealth of Yesterday, covering its lore, Memory economy, Reminiscences, unique components, Ledger, strategy, cities, and symbolism.
- Added six headed sections for The Child We Were, including the leader's identity, philosophy, founding story, diplomatic character, legacy, and Dawn of Man passage.
- Expanded the Old Friend and Childhood Bedroom articles with complete mechanics, progression, historical flavour, and strategic guidance.
- Documented the exact implemented Reminiscence bonuses, game-speed scaling, escalating same-era costs, 100-Memory cap, and current Melancholy behaviour.
- Expanded promotion, trait, unit, and building help text while keeping the ModBuddy project version at `1`.

## Repository version 1.0.24 — Old Friend unit flag

### Added

- Added a custom tintable overhead flag for the Old Friend, replacing the Warrior's inherited axe symbol.
- Adapted the supplied two-friends artwork into a compact linked-shoulders, shield, and axe silhouette readable at `32px`.
- Added a dedicated `COMMONWEALTH_OLD_FRIEND_FLAG_ATLAS` and connected it to the Old Friend database row.

## Repository version 1.0.23 — DirectX 9 component atlases

### Fixed

- Re-encoded every Old Friend and Childhood Bedroom atlas size as uncompressed A8R8G8B8 DDS artwork.
- Matched the texture layout and header used by Vox Populi's own gameplay UI assets.
- Removed reliance on BC3 blocks produced by an encoder that Civ V's gameplay renderer rejected.
- Covered both the `45px` production-list icons and the `128px` selected-production portraits.

## Repository version 1.0.22 — Gameplay texture compatibility

### Fixed

- Removed the conflicting 32-bit RGB declaration from every FourCC-compressed custom DDS header.
- Matched the production-list textures to the pixel-format metadata used by known-working Civilization V DXT5 unit and building atlases.
- Fixed the gameplay UI rejecting the Old Friend and Childhood Bedroom `45px` textures even though the front-end UI could display their larger atlas variants.

## Repository version 1.0.21 — City-view icons

### Fixed

- Corrected the DDS linear-size and mip-count metadata used by the Old Friend and Childhood Bedroom production-list icons.
- Normalized the same metadata across every compressed custom texture so all Civ V interface loaders receive valid DXT headers.
- Preserved the existing artwork, atlas dimensions, transparent corners, and ModBuddy version.

## Repository version 1.0.20 — Refined icon framing

### Improved

- Reduced the visible scale of the Old Friend and Childhood Bedroom icons so they align more naturally with the civilization emblem in civilization selection.
- Rebuilt both unique-component atlases with a consistent antique-gold and midnight-blue layered border.
- Reduced the leader portrait and refined its gold border so it sits cleanly inside Civilization V's setup-screen frame.
- Regenerated every 256, 128, 80, 64, 45, and 32 pixel icon atlas as transparent-corner DXT5 artwork.

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
- The original release tracked and displayed Melancholy without applying its negative modifiers. Repository version 1.0.28 now implements them with dedicated one-copy penalty buildings.
- Keepsake Tourism uses the Vox Populi city tourism setter when exposed. On DLL builds that omit it, Culture aging still works and Tourism is skipped safely.
- The Ledger currently lists living Old Friends and their core history. Offline profiles, detailed combat telemetry, relationship timelines, renaming, reunion notices, epithets, and achievements remain narrative/UI expansion work.
- Base-game art is used as placeholder art in version 1.

### Compatibility

- Target: Civilization V Brave New World with Community Patch / Vox Populi.
- Single-player only.
- A new game is required after database changes.
