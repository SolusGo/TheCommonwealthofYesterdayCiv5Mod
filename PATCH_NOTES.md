# Patch Notes

## Repository version 1.0.66 - Current-form profile badge

### Interface fix

- Restored the small current-form portrait in the upper-left Ledger profile. An upgraded Old Friend now shows the portrait of its actual form—such as Musketman—over the persistent Old Friend portrait.
- Switched the badge from an unavailable 32px standard-unit atlas size to Civ V's native 45px unit portraits.
- Replaced the unreliable `IconHookup` success check with an explicit `IconLookup`; if a modded unit does not provide a compatible 45px portrait, the badge now visibly falls back to the Old Friend icon instead of remaining blank.
- Enlarged and repositioned the framed badge and moved the profile headings clear of it, preserving the existing warm Ledger layout without changing the Friend cards.

### Verification and compatibility

- Confirmed Musketman uses portrait index 38 in `UNIT_ATLAS_1`, and that the atlas supplies a valid 45px sheet but no 32px sheet.
- Parsed the modified interface XML, checked its Lua control references, and verified both the native Musketman lookup and Commonwealth fallback atlas have valid 45px entries.
- This is an interface-only update. Friend identity, upgrades, lineage, conversations, gameplay, save data, art assets, Dawn of Man assets, and the in-game ModBuddy version remain unchanged at `1`.
- Rebuild and deploy manually; no files are copied into the live Mods directory by this update.

## Repository version 1.0.65 - Distinct Friend conversations

### Fixed

- Bypassed Civ V's numeric-`ID`-oriented `GameInfo` cache for the text-keyed `Commonwealth_Conversations` table. Lua now reads the dialogue rows directly from SQLite in their authored order, preventing every cached entry from resolving to the first `river` exchange.
- Added a uniqueness gate while loading dialogue. Duplicate or empty text IDs cannot enter the random-selection pool, and `Lua.log` now reports the number of unique exchanges actually available rather than only the number of iterator steps.
- Kept the existing text IDs unchanged, preserving campaign-wide use counts, 120-turn line cooldowns, per-pair history, event queues, and the rolling conversation archive in existing saves.

### Verification and compatibility

- Confirmed the live database contains 96 distinct text IDs, including 28 general exchanges, and that only `river` had been recorded because the old cached loader repeatedly exposed the first row.
- Revalidated the least-used shuffle path against the distinct dialogue pool: an existing `river` use now excludes it while any eligible zero-use exchange remains.
- This is a Lua loader correction only. Conversation wording, odds, cooldowns, gameplay, art, Dawn of Man assets, database rows, and the in-game ModBuddy version remain unchanged at `1`.
- Rebuild and deploy manually; no files are copied into the live Mods directory by this update.

## Repository version 1.0.64 - Refined Ledger cards

### Interface

- Rebuilt each Friend card into separate real-name, gamertag, and current-form/status lines so long identities no longer compete with the unit details for one narrow label.
- Removed the inconsistent secondary unit icon, which duplicated the Old Friend portrait for some forms and appeared empty for others.
- Replaced that icon with six compact Years Together pips plus the exact numeric level and strength bonus in the card tooltip.
- Kept the selected Friend and scroll position stable when the open Ledger receives live profile updates.

### Verification and compatibility

- Parsed the modified interface XML, checked every Lua `Controls` reference against the XML, and confirmed the scroll getter is part of Civilization V's shipped UI API.
- This is an interface-only update. It does not alter gameplay, Friend identities or persistence, database rows, art, Dawn of Man assets, conversation behavior, or the in-game ModBuddy version.
- Rebuild and deploy manually; no files are copied into the live Mods directory by this update.

## Repository version 1.0.63 - Upgrade-transition profile fix

### Friend lifecycle

- Restricted new Friend-profile creation to stable player-roster scans. `UnitCreated`, movement, combat, and conversion-time callbacks can reconnect a known archive but cannot mint a profile from Civ V's briefly unconverted upgrade replacement.
- Reserved both numeric unit IDs for the duration of an upgrade tick, preventing an old or replacement object that remains observable during conversion from being treated as a newly trained Old Friend.
- Captured and retired a provisional same-turn profile during the authoritative `UnitUpgraded` handoff if an earlier build already created one.
- Added an exact existing-save cleanup for the reported extra entries. It only suppresses a zero-upgrade Old Friend archive born on the same turn and numeric unit ID as a recorded upgrade, and it preserves any real Old Friend that is still alive and mapped to that profile.
- Reconciled live replacements before finalizing pending deaths, preferred the pre-kill archive for same-ID ruins upgrades, and cleared recovered pending state immediately.
- Made combat telemetry tolerate a deliberately deferred new profile without indexing a missing archive ID.

### Verification and compatibility

- Checked paid upgrades, same-ID ruins upgrades, true deaths, same-turn ID reuse, event callbacks before and after `UnitUpgraded`, repeated callbacks, deferred genuine Friend creation, Ledger filtering, and combat telemetry against the new registration boundary.
- Parsed both modified Lua files, revalidated all 96 conversation rows and the single authoritative `UnitUpgraded` listener, and parsed every XML/project/manifest file.
- Ran ModBuddy's `Build` target into an isolated temporary folder and verified the 46-file manifest, both modified Lua payloads, and in-game version `1`. Nothing was deployed to the live Mods directory.
- No gameplay values, conversation odds or dialogue, database rows, art, Dawn of Man assets, project version, or checked-in `.modinfo` version changed. Rebuild and deploy manually.

## Repository version 1.0.62 - Stable campaigns and recycled IDs

### Campaign and conversation persistence

- Replaced the mutable `COY3` world fingerprint with a `COY4` identifier based on map dimensions, game speed, the serialized map/synchronization seeds exposed by Civ V, and the fixed major-civilization setup.
- Removed generated terrain and assigned starting plots from the active identifier. True Start and other map scripts can now finish their setup without making one campaign appear to be a new one after reload.
- Excluded the synchronization seed when Civ V's **New Random Seed** option can reroll it on load; a diagnostic warning is written if no stable seed is exposed.
- Added read-through compatibility for the matching `COY3` namespace when an existing save first adopts `COY4`. New campaigns do not import legacy state from a previous game.
- Preserved global dialogue-use counts, per-pair used lines, cooldowns, event queues, and the rolling conversation archive through that migration. A previously heard `river` exchange therefore remains outside the least-used pool after an ordinary reload.

### Friend lifecycle

- Stopped newly created Old Friends from restoring names, gamertags, age, or Years Together from `FRIEND_*` cache entries left behind when Civ V recycles a numeric unit ID.
- Tagged each compatibility cache with its owning archive profile. Cached Years Together can only be read when that tag matches the live profile; otherwise the authoritative archive value is used.
- Added a narrow existing-save correction for exact duplicate live identities. The older profile is preserved, the later real unit receives an unused identity, and neither unit nor archive profile is deleted or merged.
- Let the authoritative upgrade handoff recover a same-turn pending profile when the Community Patch has already removed the original unit object, covering paid and ruins callback orderings.
- Made repeated delivery of the same upgrade callback idempotent and cleared pending-death state as part of a successful handoff, preventing duplicate Memories, timelines, or later false Offline transitions.

### Verification and compatibility

- Parsed all five Lua files independently, validated all 96 unique conversation rows and event categories, and modeled namespace stability, legacy read-through, paid/ruins handoffs, unit-ID reuse, stale Years Together caches, and duplicate-profile recovery.
- Ran ModBuddy's `Build` target with an isolated temporary output and verified the generated 46-file manifest, both UI entry points, database actions, and in-game version `1`. Nothing was deployed to the live Mods directory.
- Confirmed there is one `UnitUpgraded` listener and that the second `UnitCreated` listener remains idempotent through the shared archive mapping.
- No database rows, gameplay values, art, Dawn of Man assets, project version, or checked-in `.modinfo` version changed. An already split `COY3` campaign adopts the namespace matching the loaded save; unrelated abandoned namespaces are not merged automatically.
- Ordinary save/load is covered. Because Civ V's `Modding.OpenSaveData` is external to individual save snapshots, intentionally loading a much earlier turn can still retain later custom-state writes.
- Rebuild and deploy manually; this update does not copy files into the live Mods directory.

## Repository version 1.0.61 - Archive and interface refactor

### Friend lifecycle

- Centralized Friend registration, Years Together, era advancement, and exact old/new unit upgrade transfer in one authoritative archive API.
- Removed the duplicate Core-side profile restoration and transfer implementation and the second `UnitUpgraded` listener.
- Kept unit-keyed Friend fields as a synchronized compatibility cache without using name, tile, or broad save-repair matching.
- Made archive years, promotions, lineage, current form, status, custom name, and the 4-Memory Friend-upgrade reward update in the same atomic handoff.
- Preserved the delayed true-death confirmation and exact same-ID ruins-upgrade safeguard.

### Performance and maintainability

- Moved Memories, Reminiscence, Melancholy, conversation, queue, cooldown, reunion, and archive limits into shared database Defines.
- Added a data-driven Reminiscence table used by the interface, preventing active and Melancholy names or descriptions from drifting out of order.
- Avoided rewriting unchanged dummy-building counts, aura promotions, Years Together promotions, and unit compatibility-cache fields.
- Restricted movement-triggered empire aura scans to combat-unit movement and unit removal; civilian movement no longer rescans the roster.
- Batched era-transition Memory income into one state update while preserving the exact total, cap, healing, Keepsake, and Years Together mechanics.
- Added explicit timeline event kinds while retaining a narrow icon fallback for timeline entries saved by earlier builds.

### Interface

- Expanded the Memories panel with a glowing reserve meter, cost marker, era activation count, next-era reset notice, and illustrated Reminiscence cards with active and Melancholy details.
- Added city-to-city Childhood Bedroom navigation, Keepsake progress text, four pips, and live Culture/Tourism output.
- Added native current-unit icons and compact Years Together values to the Friend list and profile.
- Added Name, Years Together, Recent, and Current Form sorting without changing the selected Ledger filter.
- Added responsive Ledger sizing and separate Profile and Conversations tabs.
- Added a rolling archive of the latest 20 complete conversations, including event context, speakers, lines, turn, and location.
- Kept an open Ledger live-updated when Commonwealth state changes or a new active-player turn begins.
- Preserved the warm Commonwealth city-banner palette and reused existing/native atlases rather than adding memory-heavy textures.

### Verification and compatibility

- Validated all Lua files with a Lua 5.1 parser, parsed every XML file, checked every Lua `Controls` reference against the interface XML, and executed the new configuration schema in SQLite.
- Confirmed there is exactly one Old Friend upgrade listener and that the checked-in `.modinfo` still uses in-game version `1`.
- No `Units` or `UnitPromotions` rows were added, deleted, or reordered. Existing 1.0.57+ campaign state remains readable; the new conversation archive fills prospectively.
- Rebuild and deploy manually; this update does not copy files into the live Mods directory.

## Repository version 1.0.60 - Livelier varied conversations

### Fixed

- Confirmed from the live campaign database that `river` played for one pair on turn 90 and became eligible for a different pair on turn 212 because its 120-turn Commonwealth-wide reuse timer had expired.
- Added a campaign-wide least-used shuffle bag within the currently eligible dialogue pool. Every suitable exchange now receives a turn before a previously heard line can be selected again.
- Preserved existing dialogue history when loading an earlier save: future line timestamps are clamped to the loaded turn instead of erasing the fact that the exchange was heard.
- Retained permanent per-pair used-line history, so the same pair still cannot repeat an exchange.

### Frequency

- Raised ordinary dialogue from 8% to 15% base, with +10% during a Reminiscence and +7% near a Childhood Bedroom.
- Raised the per-pair miss bonus from 4 to 10 percentage points and guaranteed a conversation after four consecutive eligible misses instead of seven.
- Raised queued event dialogue from 60% to 75%, with 8 points added per miss.
- Reduced the global cooldown from eight to five turns and the same-pair cooldown from fifteen to nine turns.

### Compatibility

- Existing campaign dialogue timestamps seed the shuffle bag automatically; no repair scan or save-data deletion is used.
- This changes Lua and interface text only. The 96-line XML library and in-game ModBuddy version remain unchanged at `1`.
- Rebuild and deploy manually; no files are copied into the live Mods directory by this update.

## Repository version 1.0.59 - Authoritative upgrade handoff

### Fixed

- Corrected the Old Friend upgrade handlers to follow the Community Patch DLL's actual callback order: `UnitUpgraded` fires before `CvUnit::convert()` copies promotions and identity to the replacement unit.
- Authenticate paid and ancient-ruins upgrades from the still-live original unit and its exact archive mapping instead of checking the not-yet-converted replacement for `Since the Beginning`.
- Transfer the Ledger profile, name, gamertag, lineage, Years Together, current form, and timeline to the replacement during the authoritative upgrade event.
- Centralized the Old Friend's 4-Memory upgrade reward in the archive handoff so it is awarded exactly once; ordinary unit upgrades retain their existing 2-Memory reward.
- Kept true deaths on the existing delayed confirmation path and retained the exact pending-ID safeguard used by unit replacement ordering. No name, tile, or broad save-repair matching was added.

### Verification and compatibility

- Audited paid upgrades, ruins upgrades, ordinary-unit upgrades, true deaths, callback ordering, duplicate Memory awards, timeline idempotency, and later unit-ID reuse.
- This is a Lua-only lifecycle correction. Database rows, unit and promotion ordering, the conversation system, and the in-game ModBuddy version remain unchanged at `1`.
- Rebuild and deploy manually, then load the save made before Rhys was promoted and repeat the promotion.

## Repository version 1.0.58 - Reliable Friend dialogue

### Fixed

- Confirmed from Civ V's live campaign data that Friend registration and adjacency tracking were working, but every eligible conversation roll had failed.
- Added a persistent per-pair miss counter: ordinary dialogue starts at 8% and gains 4 percentage points after each eligible miss.
- Guaranteed an exchange after seven consecutive eligible misses, preventing an unlimited random drought.
- Event dialogue still begins at 60% and now gains 5 percentage points after each eligible miss.
- Reset only the selected pair's miss counter after a conversation; other adjacent pairs retain their accumulated chance.

### Diagnostics and compatibility

- `Lua.log` now reports whenever the number of registered lineages, adjacent eligible pairs, or dialogue-enabled state changes, making registration and positioning failures visible without noisy per-turn logging.
- The existing eight-turn global cooldown, 15-turn pair cooldown, 96-line library, contextual selection, non-repetition history, and Ledger timeline recording are unchanged.
- This Lua/text-only update does not alter database row ordering or the in-game ModBuddy version, which remains `1`. Rebuild and deploy manually.

## Repository version 1.0.57 - Clean campaign baseline

### Persistence

- Namespaced Commonwealth save data by a stable fingerprint of the generated world, game speed, civilizations, leaders, and starting plots.
- Prevented an abandoned campaign's Memories, Friend identities, Keepsakes, cooldowns, and Ledger records from bleeding into a fresh generated game.
- Removed the broad existing-save repair passes for duplicate profiles, duplicate join events, orphaned upgrades, old one-slot event migration, and global dialogue-history migration.
- Retained only deterministic runtime safeguards required in normal play: exact archive mappings, native old/new unit upgrade handoffs, goody-hut pending handoffs, delayed death confirmation, promotion synchronization, and future-turn cooldown clamps.

### Friend lifecycle edge cases

- Upgraded descendants no longer create provisional Friend profiles while waiting for the native upgrade callback.
- Ledger refreshes are now read-only: opening or filtering the Ledger no longer advances adjacency time or relationship counters.
- Ordinary and ruins upgrades continue to preserve identity, Years Together, lineage, timeline events, and Memory awards through exact mappings rather than tile, name, or generation guesses.

### Interface polish

- Added a soft glow and quarter markers to the Memories meter, plus a clear ready-state message when a Reminiscence is affordable.
- Added a Memories icon to the compact HUD button and selected-state markers to the Ledger filters.
- Added a warm `VIEWING` indicator to the Ledger without introducing new textures, atlases, animations, or base-game UI replacements.

### Compatibility

- This release is a deliberate fresh-campaign baseline. Earlier Commonwealth saves do not migrate their custom Lua state into the new namespace.
- Database rows, unit and promotion order, gameplay values, and the in-game ModBuddy version remain unchanged at `1`.
- Rebuild and deploy manually before starting the new campaign. Keep the enabled mod list and database files fixed for that campaign.

## Repository version 1.0.56 - Ruins upgrade identity repair

### Fixed

- Made goody-hut upgrades prefer the Old Friend profile captured before the original unit was replaced, including the Community Patch path that reuses the same unit ID.
- Prevented `UnitCreated` from registering a second Friend profile when a ruins upgrade already has a pending identity transfer.
- Added save-safe Ledger cleanup that retains the earliest genuine “joined the Commonwealth” event and removes later duplicate join entries created by earlier ruins upgrades.
- Kept normal paid upgrades, lineage updates, Years Together, Memories, names, gamertags, and promotion inheritance unchanged.

### Deployment

- Rebuild the ModBuddy project and deploy it manually. Loading an affected save will clean duplicate join entries on the next Commonwealth turn.
- The ModBuddy/in-game version remains `1`.

## Repository version 1.0.55 - Save-rollback conversation recovery

### Fixed

- Conversation timestamps stored by Civ V's persistent mod save data no longer block dialogue after loading an earlier game save whose turn is lower than the recorded global, pair, adjacency, event, or line-history turn.
- Future cooldown timestamps now self-clear, and future queued events are discarded instead of remaining eligible indefinitely.
- A queued special event whose 60% roll fails no longer suppresses a successful ordinary conversation roll for the same turn.
- Successful special-event conversations still take priority over ordinary chatter.

### Diagnostics

- Successful exchanges now write the dialogue ID, both Friend names, and the turn to `Lua.log`.
- Automatic recovery from a future global cooldown is also reported in `Lua.log`.

### Compatibility

- Existing dialogue history remains intact; only timestamps impossible in the currently loaded save are reset.
- Conversation chances and cooldown lengths are unchanged: 8% ordinary, 60% event, eight-turn global cooldown, and fifteen-turn pair cooldown.
- Existing saves are compatible after rebuilding. The ModBuddy project and `.modinfo` version remain `1`; deployment remains manual.

## Repository version 1.0.54 - Reliable upgrade timelines

### Fixed

- A living Old Friend whose identity transfers before the Ledger receives `UnitUpgraded` now records the missing form change during normal archive reconciliation.
- Upgrade recording is idempotent across creation, movement, turn, recovery, and native upgrade callbacks, preventing duplicate Lineage forms, upgrade counts, Friend Memory telemetry, and timeline entries.
- Existing saves with the correct current form and Lineage but a missing matching timeline entry repair automatically when the Ledger updates.
- Timelines now retain the newest 30 events by dropping the oldest entry when full; previously, every event after the first 30 was silently discarded.

### Compatibility

- Old Friend identities, promotions, unit forms, Years Together, and combat mechanics are unchanged.
- Existing saves are compatible after rebuilding. The ModBuddy project and `.modinfo` version remain `1`; deployment remains manual.

## Repository version 1.0.53 - Newest-first Friend timelines

### Fixed

- Ledger timelines now open with the newest event first, so a recent upgrade such as Jack becoming a Musketman is immediately visible.
- Timeline spacing is more compact, and opening or switching profiles resets the timeline viewport to the newest entry.
- Added a subtle `NEWEST FIRST` label to make the ordering explicit.

### Compatibility

- This is a presentation-only change; unit forms, upgrades, promotions, identities, and saved timeline data are unchanged.
- Existing saves are compatible after rebuilding. The ModBuddy project and `.modinfo` version remain `1`; deployment remains manual.

## Repository version 1.0.52 - Reload-safe Friend identities

### Fixed

- Upgraded Old Friend descendants no longer receive a fresh identity when Civ V reloads them before the advanced Ledger has restored their archive mapping.
- Core registration now restores a uniquely matching archived profile by mapping, unit ID, or persistent custom name before it can generate a new identity.
- Archive reconciliation now verifies that a unit ID genuinely belongs to a profile instead of treating any living unit that reused the ID as proof that the original Friend is still represented.
- Missed upgrades can recover from the recorded upgrade tile even when the temporary replacement profile was created on a later reload turn.

### Existing-save recovery

- A living replacement profile such as Trent in place of Ben is merged into Ben's original history when the Commonwealth next updates or the Ledger opens, provided the replacement occupies Ben's recorded upgrade tile.
- Ben's name, gamertag, lineage, Years Together, timeline, and other archived statistics are restored to the living upgraded unit; the temporary Trent profile is hidden as merged.
- Properly mapped living Friends are explicitly excluded from recovery candidates, preventing one Friend from taking another living Friend's archive.
- The ModBuddy project and `.modinfo` version remain `1`; deployment remains manual.

## Repository version 1.0.51 - Commonwealth presentation pass

### Added

- Added a live Memories meter with a next-Reminiscence cost marker and clearer active-state text.
- Added four city-aware Keepsake pips, current Culture and Tourism contributions, and a safe capital fallback outside city view.
- Added Old Friend portraits to Ledger rows and profiles, plus a six-pip Years Together display with the exact combat bonus.
- Added native event icons to Ledger timelines and portrait-led conversation cards with contextual event presentation.
- Added a styled Civilopedia quick reference and visual section labels for the leader, Old Friend, and Childhood Bedroom articles.

### Compatibility

- All additions are read-only presentation logic; Memories, Keepsakes, promotions, conversations, yields, and save-data keys are unchanged.
- Existing city, top-panel, production, and Civilopedia screens are not replaced. The interface remains contained in the Commonwealth add-in and uses existing 32/45/64px art.
- Existing saves are compatible after rebuilding. The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.50 - Safe Keepsake Tourism

### Fixed

- Replaced the unavailable `SetBaseTourism` Lua path with Community Patch's dedicated technology-enhanced building yields.
- The second Keepsake now adds +1 Tourism after Archaeology, and the fourth adds another +1, exactly matching the documented `floor(Keepsakes / 2)` mechanic and +2 maximum.
- Keepsake Tourism no longer attempts to set a city's total base Tourism, so Great Works, Wonders, beliefs, and every other Tourism source remain untouched.

### Compatibility

- Existing saves receive the correct Keepsake Tourism after rebuilding; no new game is required.
- The civilization descriptions and balance values are unchanged.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.49 - Conversation queue availability

### Fixed

- A queued event whose dialogue lines are temporarily protected by the Commonwealth-wide repeat cooldown no longer suppresses every ordinary conversation.
- The unavailable event remains queued while eligible pairs can continue producing contextual or general exchanges at their normal chances.
- Event conversations still take priority whenever at least one appropriate event exchange is actually available.

### Compatibility

- Existing saves require no migration; blocked queues resume normal conversation checks immediately after rebuilding.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.48 - Years Together synchronization

### Fixed

- Synchronized each living Old Friend's profile-level Years Together value with the replacement unit-ID cache that applies the combat promotion.
- Core promotion refreshes now use the higher valid value from the Ledger profile and legacy cache, automatically restoring missing +2% to +12% Years Together promotions in existing saves.
- Normal upgrades, recovered upgrades, and duplicate-profile consolidation now all copy Years Together, upgrade count, lineage, and identity data back to the live unit record.

### Compatibility

- Existing affected units repair automatically on the next Commonwealth turn, movement update, Reminiscence refresh, or Ledger refresh after rebuilding.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.47 - Commonwealth-wide conversation memory

### Fixed

- Conversation history now tracks each exchange across the whole Commonwealth as well as per pair, preventing different pairs from immediately replaying the same dialogue.
- Existing per-pair history is migrated automatically, so exchanges already heard in the current save enter the global cooldown immediately.
- A dialogue line must remain unused Commonwealth-wide for 120 turns before another pair can hear it; event dialogue waits for an unused line instead of discarding its queued context.

### Compatibility

- Existing saves migrate their conversation history when the Commonwealth next updates or the Ledger opens.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.46 - Transition-safe Old Friend upgrades

### Fixed

- Prevented adjacency refreshes from raising a Lua error while an upgraded unit temporarily has no map plot.
- Reapplied the stored Old Friend name and gamertag whenever the legacy identity cache is restored, preventing replacement units from retaining generated names such as Leo.
- Upgrade recovery now matches the replacement against the original profile's captured pre-upgrade tile and turn rather than potentially stale movement coordinates.
- Added recovery hooks when the replacement unit is created or first placed, allowing already-affected saves to reunite a uniquely matching replacement with its original profile.

### Compatibility

- Existing saves with a recently split Jack/replacement profile are repaired when the replacement is updated or the Ledger opens, provided the archived and replacement records share their upgrade turn.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.45 - Spy roster

### Fixed

- Added a complete Commonwealth spy-name roster, resolving the Community Patch assertion that every playable civilization must provide at least one spy name.

### Added

- Added twelve themed spy codenames: The Nightlight, Player Two, Porchlight, Old Save, Quiet Login, The Spare Key, After Midnight, Last Online, Paper Star, Home Signal, Second Controller, and Forgotten Password.

### Compatibility

- Rebuild the mod and fully restart Civilization V so the database reloads the new roster. Existing saves do not require a new game.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.44 - Upgrade duplicate cleanup

### Fixed

- The upgrade callback now detects and retires any temporary Ledger profile Civ V creates for the replacement unit before transferring the original Old Friend profile.
- Duplicate-identity consolidation now checks continuously instead of being limited to a one-time save migration, allowing existing and future upgrade collisions such as the extra Ben profile to clean themselves up.
- The legitimate profile, lineage, unit link, statistics, and timeline remain intact; only the provisional duplicate is hidden.

### Compatibility

- Existing duplicate profiles are consolidated automatically when the Commonwealth updates or the Ledger opens after rebuilding.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.43 - Tribute gamertags

### Added

- Added **Vigilanty101** and **Jemboy911** to Lachlan's tribute gamertags.
- Added **Jemkid911** to Harrison's tribute gamertags.

### Improved

- Existing Harrison and Lachlan profiles refresh their alias lists when the Ledger opens, so the added gamertags also appear in current saves.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.42 - Upgrade lineage recovery

### Fixed

- Explicitly enabled the Community Patch `EVENTS_UNIT_UPGRADES` option required by the Old Friend profile-transfer callback. It was disabled in the active database, so upgraded Swordsmen were not appending their new form to Lineage.
- Enabled `EVENTS_UNIT_PREKILL` and deferred Offline archival until the following turn, allowing an upgrade callback to claim the old profile before the replaced unit is treated as dead.
- Limited immediate Friend registration to newly created Old Friends; upgraded descendants are now attached through the upgrade transfer instead of briefly creating a second profile.
- Added a save repair for recently upgraded descendants whose callback was missed. When the original profile and descendant occupy the same recorded tile, the repair restores the original identity, appends the new form, recovers the upgrade record and 4 Memories, and hides the temporary profile.
- Added a lineage fallback that appends the current form whenever an already-linked descendant is missing it.

### Compatibility

- Restart Civilization V after rebuilding so the newly enabled Community Patch events are active.
- Existing affected saves can be repaired; a new game is not required.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.41 - Living profile consolidation

### Fixed

- Changed the existing-save identity repair so an Offline duplicate is consolidated into the matching living Old Friend instead of being left behind under the original name.
- A duplicated identity now appears only once in the Ledger. If any matching record still has a live unit, the consolidated profile is Online and points to that unit.
- Combined combat, travel, survival, upgrade, Memory, conversation, lineage, queued-event, and timeline records from the hidden duplicate entries.
- Hidden merged records are excluded from Ledger counts, filters, and closest-friend searches.

### Compatibility

- The corrected consolidation uses a new migration key and runs automatically on existing saves after rebuilding.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.40 - Ledger identity and scrolling repair

### Fixed

- Prevented newly created Old Friends from inheriting a dead Friend's identity when Civilization V reuses the dead unit's numeric ID.
- Added a one-time existing-save repair that gives later duplicate profiles a fresh unused identity while preserving the original profile and both Friends' histories.
- Synchronized the identity cache across upgrades so the upgraded unit keeps the same person rather than consuming a new identity internally.
- Added the missing Ledger scroll-panel recalculation and reset, allowing Online, Offline, and All lists longer than the visible area to scroll correctly.

### Compatibility

- Existing saves are repaired automatically the first time the Commonwealth systems update after rebuilding.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.39 - Old Friend upgrade path

### Fixed

- Added the missing `Unit_ClassUpgrades` entry for the Old Friend, allowing it to upgrade normally once the required technology and resources are available.
- The upgrade target is copied from the active Warrior definition rather than hard-coded, preserving compatibility with Brave New World, Community Patch, and Vox Populi upgrade trees.
- Since the Beginning remains retained through the upgrade, so the Friend's identity, Years Together, Ledger history, and lineage continue on the upgraded unit.

### Compatibility

- Existing Old Friends gain their upgrade action after rebuilding and loading the mod; starting a new game is not required solely for this fix.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.38 - Reliable conversation queues

### Fixed

- Replaced each Old Friend's single overwritable event slot with a persistent six-entry queue that preserves different era, upgrade, close-call, victory, and Reminiscence events.
- Migrated pending events from existing saves into the new queue automatically.
- Extended event lifetime from 15 to 40 turns so queued dialogue cannot expire behind the pair cooldown.
- Prevented normal chatter from consuming the global cooldown while an eligible queued event is waiting.
- Gave Bedroom, scarred, veteran, away-from-Home, and Reminiscence dialogue their correct contextual headings instead of always showing **A Quiet Moment**.
- Recycled a pair's dedicated event category only after every line in that category has been heard, preventing an exhausted category from blocking its queue.

### Improved

- Increased ordinary adjacent conversation chance from 4% to 8%.
- Increased queued event conversation chance from 35% to 60%.
- Increased the Reminiscence chance bonus from 4% to 6% and the nearby Bedroom bonus from 2% to 4%.
- Reduced the global cooldown from 12 to 8 turns and the per-pair cooldown from 25 to 15 turns.
- Added a permanent Lua-log summary reporting how many conversation exchanges loaded.

### Compatibility

- Existing dialogue history, Friend identities, timelines, and pending events are preserved.
- This changes only Lua, UI text, Civilopedia text, and save-data keys; unit and promotion database order is unchanged.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.37 - City-banner interface theme

### Improved

- Unified the Memories panel, Old Friends Ledger, profile cards, friend rows, and conversation popup around the city banner's slate-teal, Commonwealth-orange, and antique-gold palette.
- Added inset teal enamel headers, darker teal interiors, warm cream body copy, and orange emphasis throughout the complete custom interface.
- Retained Civ V's standard green-and-gold buttons so the custom interface remains visually integrated with the base game.
- Preserved the corner-safe insets and relocated remembrance quote from repository version 1.0.36.

### Compatibility

- This is a UI-only change with no effect on database order, saves, or gameplay.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.36 - Cozy corner-safe Ledger

### Improved

- Shifted the full Ledger toward warm ivory text, amber headings, muted copper accents, and dark brown-slate panels.
- Inset the custom header and background treatment so square color blocks no longer clip through the ornate rounded corners.
- Removed the redundant lower divider and moved remembrance quotes into the profile panel above the outer frame.
- Applied the warmer text palette to summaries, records, lineage, relationships, and timelines for a more cohesive presentation.

### Compatibility

- This remains a UI-only change with no effect on database order, saves, or gameplay.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.35 - Softer Ledger colors

### Improved

- Replaced the saturated navy and orange Ledger treatment with softer slate-blue panels, muted copper accents, warm cream headings, and gentler secondary text.
- Removed the bright-green profile-name override so selected names follow the unified Ledger palette.
- Narrowed the remembrance quote area so its text no longer runs beneath the Locate button.

### Compatibility

- This remains a UI-only change with no effect on database order, saves, or gameplay.
- The ModBuddy project and `.modinfo` version remain `1`.

## Repository version 1.0.34 - Commonwealth Ledger palette

### Improved

- Restyled the Old Friends Ledger with deep navy panels, sunset-orange dividers and accents, warm-gold headings, and softer blue-grey secondary text.
- Preserved Civ V's familiar gold framing, standard controls, layout, and readability.

### Compatibility

- This is a UI-only change and does not alter units, promotions, database order, saved state, or gameplay.
- The ModBuddy project and `.modinfo` version remain `1`.

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
