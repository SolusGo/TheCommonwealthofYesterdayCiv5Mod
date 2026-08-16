# The Commonwealth of Yesterday

A ModBuddy project and single-player Civilization V mod for Brave New World with the Community Patch / Vox Populi, led by **The Child We Were**.

**Repository version: 1.0.62** — this documentation version is independent of the in-game ModBuddy version, which intentionally remains `1`.

The Commonwealth turns nostalgia into a long-game resource. Its strongest pieces are not disposable: old units, old cities, and the buildings that witnessed earlier eras become more valuable when preserved.

## Civilization

- **Leader:** The Child We Were
- **Capital:** Home
- **Start bias:** Grassland
- **Preferred victory:** Culture
- **Colours:** Sunset orange and faded midnight blue
- **Trait — We Didn't Know We Were Making Memories:** Earn up to 100 Memories from era changes, upgrades, Great People, Wonders, Old Friends, and Keepsakes. Spend them on an eight-turn Reminiscence, followed by four turns of Melancholy. The first activation each era costs 25 Memories; later activations cost 35, 45, and so on.

### Reminiscences

- **The Boys Are Online:** a military timing window with +15% Production in every city and +10% Combat Strength for units beside another friendly military unit.
- **One More World Before Bed:** a development window that gives Workers +1 Movement and +25% work rate.
- **The Summer That Never Ended:** a cultural window with +15% Culture, +2 Happiness per city, and +1 Food in each Childhood Bedroom city.

Durations scale with game speed. Only one effect can be active, and a new Reminiscence cannot begin during Melancholy. The AI chooses effects automatically. Each four-turn Melancholy has its own penalty:

- **Everyone Logged Off:** -10% Production toward military units.
- **The Sun Is Coming Up:** -10% Science.
- **September Morning:** -10% Culture and -2 Happiness.

### Old Friend

The Old Friend replaces the Warrior at the same base strength and 40 Production. Its **Since the Beginning** promotion survives upgrades, and its overhead flag uses a custom linked-friends emblem. At every new era, each surviving Old Friend:

- heals 25 HP;
- produces 1 Memory;
- gains a level of **Years Together**, up to +12% Combat Strength;
- receives +10% Combat Strength while beside another Old Friend.

Old Friend identities are randomly selected from 54 generated names and 72 gamertags. Trent, Gabriel, Dion, Harrison, Lachlan, and Ben retain their tribute gamertags and are each eight times more likely to appear than a generated identity. Names are not repeated until the available pool is exhausted. The in-game **Friends** button opens a persistent archive with Online, Offline, and All views; profiles show form, age, level, combat and survival records, lineage, closest friend, location, timeline, and earned epithet. Records transfer across upgrades and remain after death.

Adjacent Old Friends have a 15% base chance per eligible pair each turn to share a brief conversation, increased to 25% during a Reminiscence, 22% near a Childhood Bedroom, or 32% with both bonuses. Each eligible miss raises that pair's next chance by 10 percentage points, with an exchange guaranteed after four consecutive misses. Queued event conversations begin at 75%, gain 8 points after each miss, persist for 40 turns, and take priority over normal chatter. New eras, upgrades, near-death survival, victories, and Reminiscence activations enter a persistent per-Friend queue rather than overwriting one another; reunions after at least 15 turns apart use a persistent per-pair event. A five-turn global cooldown and nine-turn pair cooldown prevent interruptions. Per-pair history prevents a pair from repeating itself, while a campaign-wide least-used shuffle bag cycles through every currently eligible exchange before allowing a familiar line to return. Conversations are recorded in both Friend timelines and in a rolling 20-exchange Ledger archive, and can be disabled from the Ledger.

The conversation library contains 96 exchanges. Dialogue is stored separately from the Lua logic in `Data/CommonwealthConversations.xml`. The file defines a custom `GameInfo.Commonwealth_Conversations` database table, making it possible to add or revise exchanges without editing the conversation system itself. Lines can use `{SELF}`, `{OTHER}`, `{LOCATION}`, `{ERA}`, `{FORM}`, and `{OTHER_FORM}` tokens for contextual details.

### Childhood Bedroom

The Childhood Bedroom replaces the Monument. It costs 40 Production, has no maintenance, and provides +2 Culture and +1 local Happiness. Constructed Bedrooms and policy-granted free Bedrooms both gain one Keepsake at each era transition after the era in which they were acquired, up to four. Each Keepsake adds +1 Culture and generates 2 Memories. After Archaeology, every two Keepsakes also add +1 Tourism.

### Commonwealth interface

The Memories panel includes a live reserve meter, next-cost marker, current-era activation count, and the next-era cost reset. Each Reminiscence is presented as an illustrated card that shows its exact active bonus and previews the following Melancholy in its tooltip.

The Keepsake strip has four progress pips and can browse every city with a Childhood Bedroom, showing the selected city's current Culture and Tourism contribution and when its next Keepsake will arrive.

The responsive Old Friends Ledger includes native current-form icons, six Years Together pips, sortable profiles, structured timeline event icons, and separate **Profile** and **Conversations** tabs. The conversation archive preserves the latest 20 complete exchanges with speakers, event context, turn, and location. Live conversation cards use the same warm city-banner presentation, while the Civilopedia retains its styled quick-reference section alongside the full lore and strategy articles.

## Installation

1. Install and enable Vox Populi / the Community Patch.
2. Place this folder in `Documents/My Games/Sid Meier's Civilization 5/MODS`.
3. Clear the Civ V mod cache after replacing an older build.
4. Enable **The Commonwealth of Yesterday (v 1)** in the Mods menu and start a new game.

The mod includes a custom 1024×768 DXT1 Dawn of Man scene, a 360×412 inset DXT5 civilization map, and complete DXT5 atlases for the leader, civilization, Old Friend, and Childhood Bedroom. A separate tintable house emblem is supplied for the civilization alpha atlas.

## Repository version history

Repository versions track individual development commits. Each new mod or documentation commit receives the next patch number; these numbers do not change the ModBuddy project or `.modinfo` version displayed by Civilization V.

| Repository version | Commit | Change |
| --- | --- | --- |
| 1.0.0 | `280dc6e` | Added the initial Commonwealth civilization. |
| 1.0.1 | `b241b23` | Added the ModBuddy project. |
| 1.0.2 | `c7c6502` | Fixed the Commonwealth starting units. |
| 1.0.3 | `0e60aac` | Fixed the starting roster and interface. |
| 1.0.4 | `4050495` | Fixed the Old Friends Ledger control style. |
| 1.0.5 | `742d324` | Added the Dawn of Man artwork. |
| 1.0.6 | `c3e7e23` | Added the leader icon atlas. |
| 1.0.7 | `6a4c5c4` | Added civilization and unique-component icons. |
| 1.0.8 | `e28e33c` | Fixed the leader-selection layout. |
| 1.0.9 | `3b1238b` | Restored the full trait name. |
| 1.0.10 | `eab16a6` | Improved unique-icon framing and scale. |
| 1.0.11 | `4482ae8` | Added the full-name civilization-selection layout. |
| 1.0.12 | `2c00ce4` | Added the civilization map artwork. |
| 1.0.13 | `f6892a5` | Added the advanced Old Friends Ledger. |
| 1.0.14 | `68214d8` | Randomized Old Friend identities and fixed the Ledger font. |
| 1.0.15 | `9753950` | Added repository version tracking to this README. |
| 1.0.16 | `490342a` | Removed the inherited Dawn of Man audio. |
| 1.0.17 | `047d7f1` | Added contextual adjacent Old Friend conversations. |
| 1.0.18 | `b34da6b` | Added event conversations and external XML dialogue data. |
| 1.0.19 | `852a6f9` | Expanded the immersive conversation library to 96 exchanges. |
| 1.0.20 | `d792c11` | Refined unique-component and leader icon framing. |
| 1.0.21 | `d7e3098` | Fixed custom DDS linear-size and mip metadata. |
| 1.0.22 | `4b2d903` | Removed conflicting RGB metadata from compressed DDS textures. |
| 1.0.23 | `c5af112` | Re-encoded gameplay component atlases for DirectX 9 compatibility. |
| 1.0.24 | `ef034a5` | Added the custom Old Friend unit flag. |
| 1.0.25 | `d841b03` | Expanded every custom Civilopedia article. |
| 1.0.26 | `d56567a` | Expanded the thematic city-name list. |
| 1.0.27 | `ca20832` | Fixed shifted Reminiscence UI names. |
| 1.0.28 | `8e840dd` | Implemented safe Melancholy debuffs. |
| 1.0.29 | `1834f80` | Fixed Keepsakes for policy-granted free Bedrooms. |
| 1.0.30 | `0c9681e` | Added targeted Old Friend save recovery. |
| 1.0.31 | `6a96f6a` | Removed Kiyotaka-only promotions from restored Old Friends. |
| 1.0.32 | `43b4747` | Removed every remaining White Room promotion from Old Friends. |
| 1.0.33 | `900d225` | Removed unsafe save repair and stabilized cross-mod load order. |
| 1.0.34 | `9f294bf` | Restyled the Old Friends Ledger in Commonwealth colors. |
| 1.0.35 | `0704ae4` | Softened the Ledger palette and corrected quote spacing. |
| 1.0.36 | `5bfcf70` | Added a cozier Ledger palette and inset corner-safe panels. |
| 1.0.37 | `dee4062` | Unified all Commonwealth panels with the city-banner theme. |
| 1.0.38 | `11a534c` | Rebuilt event queues and increased conversation frequency. |
| 1.0.39 | `85364b0` | Restored the Old Friend's missing manual upgrade path. |
| 1.0.40 | `f5f704e` | Prevented reused identities and repaired Ledger scrolling. |
| 1.0.41 | `7193b49` | Consolidated false Offline duplicates into their living profiles. |
| 1.0.42 | `96cb2e4` | Enabled upgrade events and added missed-lineage recovery. |
| 1.0.43 | `6de9d50` | Expanded Harrison and Lachlan's tribute gamertags. |
| 1.0.44 | `9672fdc` | Retired temporary profiles created during upgrades. |
| 1.0.45 | `b77f73b` | Added the Commonwealth spy roster. |
| 1.0.46 | `9af8698` | Made Old Friend upgrade identity transfers transition-safe. |
| 1.0.47 | `a97f4df` | Prevented dialogue repetition across different Old Friend pairs. |
| 1.0.48 | `1dfb113` | Restored Years Together buffs after recovered upgrades. |
| 1.0.49 | `e1e20a3` | Prevented queued events from silencing normal conversations. |
| 1.0.50 | `7ecf7bc` | Safely implemented Keepsake Tourism as dedicated building yields. |
| 1.0.51 | `2e290aa` | Polished the Commonwealth interface and Civilopedia presentation. |
| 1.0.52 | `67894b2` | Preserved Old Friend identities across save reloads and repaired affected profiles. |
| 1.0.53 | `dde1500` | Showed the newest Old Friend timeline events first. |
| 1.0.54 | `3e5a216` | Recovered missed upgrade events and retained recent timeline history. |
| 1.0.55 | `95eee0f` | Restored conversations after loading earlier saves and prevented event-roll starvation. |
| 1.0.56 | `5019eed` | Preserved Friend profiles through ruins upgrades and removed duplicate join events. |
| 1.0.57 | `eb17c72` | Established a clean-campaign persistence baseline, removed old repair passes, hardened Friend upgrades, and polished the archive UI. |
| 1.0.58 | `f9c88b4` | Added escalating conversation odds, a seven-miss guarantee, and runtime eligibility diagnostics. |
| 1.0.59 | `f87b86f` | Aligned Old Friend identity transfers with the Community Patch's pre-conversion upgrade callback. |
| 1.0.60 | `de25d94` | Cycled dialogue through a global shuffle bag and increased conversation frequency. |
| 1.0.61 | `74a8e4e` | Refactored Friend state and expanded the Commonwealth interface. |
| 1.0.62 | Current | Stabilized campaign persistence and isolated Friend identities from recycled unit IDs. |

## ModBuddy development

Open `CommonwealthOfYesterday.civ5proj` in the Civilization V SDK's ModBuddy. The project contains the database activation actions, both in-game UI add-ins, VFS settings, metadata, and all source files required to build or deploy the mod.

The project and checked-in `.modinfo` intentionally share the same mod GUID. ModBuddy's default output path is the project directory, matching the existing repository layout.

### Save compatibility

Civ V saves custom units and promotions by numeric database ID, not only by their text `Type`. Changing the enabled mod list or load order—or adding, deleting, or reordering rows in `Units` or `UnitPromotions`—can therefore turn a saved unit or promotion into one belonging to another mod. There is no reliable Lua repair after that remapping has occurred because the original identity has already been lost.

The Commonwealth has an optional ModBuddy reference to **Kid Kiyotaka White Room**, making the Commonwealth load after it whenever both mods are enabled. Future Commonwealth unit and promotion definitions must be appended after the existing rows. Keep the same enabled mods for an entire campaign, and start a new game after any database-row or mod-loadout change. Lua, UI, text, and art edits that leave database rows unchanged are generally safe for an existing save.

The mod includes a front-end `SelectCivilization` override that places the full trait name on its own line beneath the full leader and civilization names. Because Civ V loads front-end overrides globally while a mod is enabled, another mod that replaces the same screen may conflict with this layout.

## Technical notes

State is stored with `Modding.OpenSaveData` under a campaign-specific identifier derived from immutable setup data and Civ V's serialized random seeds. Terrain and starting locations are deliberately excluded because map scripts can finalize them after the Commonwealth add-in loads. Repository version 1.0.62 uses the `COY4` namespace and provides read-through access to the matching `COY3` state when an existing save is first loaded; fresh games never import a legacy campaign. This keeps Memories, era counters, Bedroom construction eras, conversation history, and Old Friend records stable across ordinary save/load while separating newly generated campaigns. Multiplayer and hotseat are intentionally disabled because the interface and persistence layer target single-player.

Old Friend registration, Years Together, era advancement, and old/new unit upgrade handoffs now use one authoritative archive API. The older unit-keyed fields remain as a synchronized runtime cache for compatibility, but no second upgrade listener can independently create, rename, archive, or retire a profile. Shared Memories, Reminiscence, Melancholy, conversation, and presentation settings live in the Commonwealth database so gameplay and UI labels use the same source.

Some requested bonuses do not have a safe category-specific modifier in the exposed database/API. The current implementation keeps their intended timing and theme while using close city-level equivalents. Exact implementation differences are recorded in [PATCH_NOTES.md](PATCH_NOTES.md).
