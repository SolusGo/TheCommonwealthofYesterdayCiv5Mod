# The Commonwealth of Yesterday

A ModBuddy project and single-player Civilization V mod for Brave New World with the Community Patch / Vox Populi, led by **The Child We Were**.

The Commonwealth turns nostalgia into a long-game resource. Its strongest pieces are not disposable: old units, old cities, and the buildings that witnessed earlier eras become more valuable when preserved.

## Civilization

- **Leader:** The Child We Were
- **Capital:** Home
- **Start bias:** Grassland
- **Preferred victory:** Culture
- **Colours:** Sunset orange and faded midnight blue
- **Trait — We Didn't Know We Were Making Memories:** Earn up to 100 Memories from era changes, upgrades, Great People, Wonders, Old Friends, and Keepsakes. Spend them on an eight-turn Reminiscence, followed by four turns of Melancholy. The first activation each era costs 25 Memories; later activations cost 35, 45, and so on.

### Reminiscences

- **The Boys Are Online:** a military timing window with stronger formations.
- **One More World Before Bed:** a development window that gives Workers +1 Movement and +25% work rate.
- **The Summer That Never Ended:** a cultural window with +15% Culture, +2 Happiness per city, and +1 Food in each Childhood Bedroom city.

Durations scale with game speed. Only one effect can be active, and a new Reminiscence cannot begin during Melancholy. The AI chooses effects automatically.

### Old Friend

The Old Friend replaces the Warrior at the same base strength and 40 Production. Its **Since the Beginning** promotion survives upgrades. At every new era, each surviving Old Friend:

- heals 25 HP;
- produces 1 Memory;
- gains a level of **Years Together**, up to +12% Combat Strength;
- receives +10% Combat Strength while beside another Old Friend.

The first six Old Friends are named Trent, Gabriel, Dion, Harrison, Lachlan, and Ben with their tribute gamertags. The in-game **Friends** button opens a lightweight Old Friends Ledger showing their current form, age, level, and status.

### Childhood Bedroom

The Childhood Bedroom replaces the Monument. It costs 40 Production, has no maintenance, and provides +2 Culture and +1 local Happiness. A Bedroom gains one Keepsake at each era transition after the era in which it was built, up to four. Each Keepsake adds +1 Culture and generates 2 Memories.

## Installation

1. Install and enable Vox Populi / the Community Patch.
2. Place this folder in `Documents/My Games/Sid Meier's Civilization 5/MODS`.
3. Clear the Civ V mod cache after replacing an older build.
4. Enable **The Commonwealth of Yesterday (v 1)** in the Mods menu and start a new game.

The mod includes a custom 1024×768 DXT1 Dawn of Man scene and complete DXT5 atlases for the leader, civilization, Old Friend, and Childhood Bedroom. A separate tintable house emblem is supplied for the civilization alpha atlas.

## ModBuddy development

Open `CommonwealthOfYesterday.civ5proj` in the Civilization V SDK's ModBuddy. The project contains the database activation actions, both in-game UI add-ins, VFS settings, metadata, and all source files required to build or deploy the mod.

The project and checked-in `.modinfo` intentionally share the same mod GUID. ModBuddy's default output path is the project directory, matching the existing repository layout.

## Technical notes

State is stored with `Modding.OpenSaveData`, so Memories, era counters, Bedroom construction eras, and living Old Friend records survive saves. Multiplayer and hotseat are intentionally disabled because the interface and persistence layer target single-player.

Some requested bonuses do not have a safe category-specific modifier in the exposed database/API. The current implementation keeps their intended timing and theme while using close city-level equivalents. Exact implementation differences are recorded in [PATCH_NOTES.md](PATCH_NOTES.md).
