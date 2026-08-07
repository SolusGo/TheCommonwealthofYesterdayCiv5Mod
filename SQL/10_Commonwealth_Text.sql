-- The Commonwealth of Yesterday: English text and Civilopedia articles
INSERT OR REPLACE INTO Language_en_US (Tag,Text) VALUES
('TXT_KEY_CIV_COMMONWEALTH_DESC','The Commonwealth of Yesterday'),
('TXT_KEY_CIV_COMMONWEALTH_SHORT_DESC','The Commonwealth of Yesterday'),
('TXT_KEY_CIV_COMMONWEALTH_ADJECTIVE','Nostalgic'),
('TXT_KEY_LEADER_CHILD_WE_WERE','The Child We Were'),
('TXT_KEY_LEADER_CHILD_WE_WERE_PEDIA',
 'The Child We Were is not one historical ruler, but the remembered self at the centre of the Commonwealth: the child who believed the night could last forever, that the whole group would always be online tomorrow, and that a bedroom could contain an entire universe.'
 || '[NEWLINE][NEWLINE]' ||
 'The Child rules by preserving rather than conquering. Old friendships become living military lineages, familiar rooms gather Keepsakes as the ages pass, and the ordinary milestones of a civilization are transformed into Memories. Those Memories can briefly make the past feel present again, but every Reminiscence is followed by Melancholy—a quiet interval in which another cannot begin.'
 || '[NEWLINE][NEWLINE]' ||
 'The leader''s title is deliberately collective. The Child is the part of every citizen that remembers late nights, private jokes, unfinished worlds, and the strange certainty that nothing important would ever change. The Commonwealth does not pretend those days can be restored exactly. Its purpose is to carry their meaning forward.'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE','The Child We Were'),
('TXT_KEY_CIV_COMMONWEALTH_PEDIA',
 'The Commonwealth of Yesterday is a civilization founded on shared memory. Its history is not measured only in dynasties or wars, but in the smaller moments that once seemed ordinary: an old friend joining the game, a room lit long after midnight, a new world begun before bed, and a summer that felt as if it would never end.'
 || '[NEWLINE][NEWLINE]' ||
 'Its people understand that nostalgia is both strength and ache. Progress generates Memories, which may be spent on powerful Reminiscences. Old Friends become more formidable the longer they survive, while Childhood Bedrooms accumulate Keepsakes as the world enters new eras. The result is a civilization whose earliest people and places remain important throughout the entire game.'
 || '[NEWLINE][NEWLINE]' ||
 'Yesterday is not presented as a country that once existed. It is a commonwealth in the older sense: a shared inheritance held by everyone who remembers. Its capital is Home, and its later cities—New Home, The Old Server, Summer''s End, After School, and Last Light—map the emotional geography between childhood and adulthood.'),
('TXT_KEY_CIV5_COMMONWEALTH','The Commonwealth of Yesterday'),
('TXT_KEY_CIV_COMMONWEALTH_STRATEGY',
 'Build Childhood Bedrooms as early as possible so they can collect the maximum number of Keepsakes. Protect Old Friends, upgrade them rather than replacing them, and keep their descendants together for overlapping survival and adjacency bonuses. Memories are capped at 100, so spend them before a large era-transition reward would be wasted. Use The Boys Are Online for military production and compact formations, One More World Before Bed for concentrated improvement work, or The Summer That Never Ended to accelerate Culture and stabilize a growing empire. Every Reminiscence is followed by Melancholy, so choose the timing carefully.'),
('TXT_KEY_TRAIT_COMMONWEALTH_MEMORIES_SHORT','We Didn''t Know We Were Making Memories'),
('TXT_KEY_TRAIT_COMMONWEALTH_MEMORIES_HELP','Earn up to 100 [COLOR_POSITIVE_TEXT]Memories[ENDCOLOR] from era transitions, unit upgrades, expended Great People, World Wonders, surviving Old Friends, and Bedroom Keepsakes. Spend them on escalating, game-speed-scaled Reminiscences. Old Friends and Childhood Bedrooms grow stronger across eras.'),
('TXT_KEY_CIV5_DOM_COMMONWEALTH_TEXT','There was a time, beloved child, when the night seemed endless. Your friends did not disappear; life simply became busier. Now carry every fragment of the past forward, and build something worthy of remembering.'),

-- Civilization Civilopedia sections. Civ V discovers consecutive HEADING/TEXT pairs
-- from the civilization's CivilopediaTag.
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_1','The Commonwealth of Yesterday'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_1',
 'The Commonwealth is an imagined nation of memory: a place formed from the worlds people made together before they knew those nights would become precious. Its borders enclose bedrooms, old servers, neighbourhood streets, half-finished games, and every familiar voice that once answered without needing to schedule a time.'
 || '[NEWLINE][NEWLINE]' ||
 'It is not a civilization that rejects adulthood. Instead, it asks what can be carried forward. Its people turn remembrance into institutions, protect the companions who were present at the beginning, and allow old places to deepen in value rather than become obsolete. The Commonwealth''s history is therefore personal and collective at once—a record of how ordinary moments become the landmarks of a life.'),
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_2','We Didn''t Know We Were Making Memories'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_2',
 'The Commonwealth''s unique ability introduces [COLOR_POSITIVE_TEXT]Memories[ENDCOLOR], a civilization resource with a maximum reserve of 100. Entering a new era grants 6 Memories plus 2 for every city in the empire. A normal unit upgrade grants 2; upgrading an Old Friend or one of that unit''s descendants grants 4. Expending a Great Person grants 3, completing a World Wonder grants 4, and every newly formed Bedroom Keepsake grants 2. Each Old Friend alive at an era transition also contributes 1 Memory.'
 || '[NEWLINE][NEWLINE]' ||
 'The first Reminiscence activated in an era costs 25 Memories. Each additional activation in that same era costs 10 more than the last: 35, then 45, and so on. Entering a new era resets the price to 25. Memory reserves do not exceed 100, making timing important when a large era reward approaches.'),
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_3','Reminiscences'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_3',
 'A Reminiscence is a temporary empire-wide state chosen from the Memories interface. On Standard speed it lasts 8 turns, after which 4 turns of Melancholy begin. Both durations scale with game speed. Only one Reminiscence may be active, and another cannot begin during Melancholy.'
 || '[NEWLINE][NEWLINE]' ||
 '[COLOR_POSITIVE_TEXT]The Boys Are Online[ENDCOLOR] grants +15% [ICON_PRODUCTION] Production in every city. Combat units also gain +10% Combat Strength while adjacent to another friendly military unit, rewarding a coordinated push rather than isolated fighting.'
 || '[NEWLINE][NEWLINE]' ||
 '[COLOR_POSITIVE_TEXT]One More World Before Bed[ENDCOLOR] grants Workers +1 Movement and +25% work rate, allowing roads, repairs, and tile improvements to be completed in a concentrated burst.'
 || '[NEWLINE][NEWLINE]' ||
 '[COLOR_POSITIVE_TEXT]The Summer That Never Ended[ENDCOLOR] grants +15% [ICON_CULTURE] Culture in every city, +2 [ICON_HAPPINESS_1] Happiness per city, and +1 [ICON_FOOD] Food in each city containing a Childhood Bedroom.'
 || '[NEWLINE][NEWLINE]' ||
 'In the current implementation, Melancholy is a visible recovery period that blocks activation of another Reminiscence; it does not reduce yields.'),
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_4','Old Friends'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_4',
 'The Old Friend replaces the Warrior at the same Combat Strength and a cost of 40 [ICON_PRODUCTION] Production. Its defining promotion, Since the Beginning, survives upgrades, allowing the identity and history of the original unit to continue through every later military form.'
 || '[NEWLINE][NEWLINE]' ||
 'At each new era, a surviving Old Friend heals 25 damage, generates 1 Memory, and gains one level of Years Together. Years Together provides +2% Combat Strength per level, to a maximum of +12% after six era transitions. An Old Friend also receives +10% Combat Strength while adjacent to another Old Friend or descendant. Preserving and upgrading the original unit therefore creates a veteran whose mechanical value and personal story grow together.'),
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_5','The Old Friends Ledger'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_5',
 'Every Old Friend is assigned a persistent name and gamertag. The identity pool contains 54 generated names and 72 generated gamertags; the tribute names Trent, Gabriel, Dion, Harrison, Lachlan, and Ben are weighted more heavily. Identities are not repeated until the available pool has been exhausted.'
 || '[NEWLINE][NEWLINE]' ||
 'The Friends button opens the Old Friends Ledger. Online, Offline, and All views preserve profiles across upgrades and death. Each profile records the unit''s current form, age, level, experience, creation era and turn, lineage, Years Together, location, victories, damage dealt and received, near-death survivals, upgrades, eras survived, Memories generated, closest friend, timeline, and earned epithet.'
 || '[NEWLINE][NEWLINE]' ||
 'Adjacent Old Friends may also speak to one another. Each eligible pair has a 4% chance per turn to produce an exchange, increased during a Reminiscence and near a Childhood Bedroom. Era changes, upgrades, close calls, victories, Reminiscence activations, and reunions after a long separation can trigger dedicated conversations. Global, pair, and dialogue-history cooldowns keep the system from becoming repetitive, and conversations can be disabled in the Ledger.'),
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_6','Childhood Bedrooms'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_6',
 'The Childhood Bedroom replaces the Monument. It costs 40 [ICON_PRODUCTION] Production, requires no maintenance, and provides +2 [ICON_CULTURE] Culture and +1 local [ICON_HAPPINESS_1] Happiness. A Bedroom gains one Keepsake whenever the civilization enters a later era than the one in which that Bedroom was built, up to four Keepsakes.'
 || '[NEWLINE][NEWLINE]' ||
 'Each Keepsake adds +1 [ICON_CULTURE] Culture and generates 2 Memories when it appears. After Archaeology is researched, every two Keepsakes also provide +1 [ICON_TOURISM] Tourism, up to +2. A fully matured Childhood Bedroom therefore produces +6 Culture, +1 local Happiness, and +2 Tourism. Because a newly built Bedroom cannot gain a Keepsake in its construction era, early construction is essential.'),
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_7','Strategy'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_7',
 'The Commonwealth rewards continuity. Build Childhood Bedrooms immediately in new cities, because every missed era is a Keepsake that can never be recovered. Keep the first Old Friend alive, avoid unnecessary attrition, and upgrade that lineage through the technology tree. When several descendants exist, move them in pairs so The Boys Are Still Here remains active.'
 || '[NEWLINE][NEWLINE]' ||
 'Do not allow the 100-Memory reserve to remain full. Era transitions can provide a large burst from cities, Old Friends, and Keepsakes at once, so activate a useful Reminiscence shortly beforehand when possible. The Boys Are Online is strongest before a production and military push; One More World Before Bed is ideal after expansion, conquest, or a new technology unlocks improvements; The Summer That Never Ended supports policy acquisition, border growth, and periods of unhappiness.'
 || '[NEWLINE][NEWLINE]' ||
 'The civilization is strongest when early investments survive into the middle and late game. Its weakness is disruption: a lost Old Friend cannot rebuild Years Together, a late Bedroom cannot recover missed Keepsakes, and poorly timed Melancholy can leave Memories unavailable when an emergency begins.'),
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_8','Cities of Yesterday'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_8',
 'The capital is [COLOR_POSITIVE_TEXT]Home[ENDCOLOR], the fixed point from which every remembered journey begins. [COLOR_POSITIVE_TEXT]New Home[ENDCOLOR] acknowledges that belonging can be rebuilt without erasing what came before. [COLOR_POSITIVE_TEXT]The Old Server[ENDCOLOR] preserves the meeting place where friendships once assembled nightly. [COLOR_POSITIVE_TEXT]Summer''s End[ENDCOLOR] marks the first awareness that even endless seasons pass. [COLOR_POSITIVE_TEXT]After School[ENDCOLOR] remembers the daily hour when obligation gave way to possibility. [COLOR_POSITIVE_TEXT]Last Light[ENDCOLOR] is the glow of one more screen, one more match, and one more goodnight.'),
('TXT_KEY_CIV5_COMMONWEALTH_HEADING_9','Symbolism'),
('TXT_KEY_CIV5_COMMONWEALTH_TEXT_9',
 'The Commonwealth''s colours join sunset orange to the deep blue of evening: the warm last light of childhood against the night in which so many shared worlds were made. Its house emblem represents safety, return, and the ordinary place that memory transforms into sacred ground. The linked figures carried by the Old Friend represent companionship surviving the change from one age to the next.'
 || '[NEWLINE][NEWLINE]' ||
 'Its central belief is not that the past was perfect. It is that people often recognize a treasured era only after it has ended. The Commonwealth answers that loss by remembering deliberately—and by making the present worthy of becoming someone else''s yesterday.'),

-- Leader Civilopedia sections.
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_HEADING_1','The Child We Were'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_TEXT_1',
 'Before titles, borders, and histories, there was a child in a familiar room. The world outside was large and only partly understood; the world inside was immediate and complete. Friends could be summoned by a name on a screen. A night could contain an expedition, a kingdom, a private joke, and the promise to return tomorrow.'
 || '[NEWLINE][NEWLINE]' ||
 'The Child We Were is the Commonwealth''s personification of that remembered self. The leader has no single birthday or bloodline, because the title belongs to everyone who has looked back and realized that an ordinary moment had quietly become irreplaceable.'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_HEADING_2','A Leader Made of Memory'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_TEXT_2',
 'The Child does not command through inherited authority. Leadership comes from recognition: every citizen sees some fragment of an earlier self in the figure before them. That shared recognition binds the Commonwealth more securely than genealogy.'
 || '[NEWLINE][NEWLINE]' ||
 'Memory, however, is never treated as a simple refuge. To remember is to feel both gratitude and distance. The Child can call a Reminiscence into the present for a short time, but Melancholy must follow. This rhythm defines the leader''s rule: joy is strongest when its cost is acknowledged, and the past has meaning only when it helps shape what comes next.'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_HEADING_3','The First Commonwealth'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_TEXT_3',
 'The Commonwealth began wherever friends gathered without ceremony. Its first council was a conversation that ran too late; its first archive was a list of names that still meant something years afterward; its first monument was a Childhood Bedroom whose shelves and screens outlived the worlds they once contained.'
 || '[NEWLINE][NEWLINE]' ||
 'When those friends grew older, they did not vanish. Time divided their routines, scattered their homes, and made every meeting harder to arrange. The Child answered by founding a nation in which distance would not be mistaken for erasure. Old Friends would retain their names through every transformation, and old rooms would gain value with age.'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_HEADING_4','Character and Diplomacy'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_TEXT_4',
 'The Child favours culture, Great People, Wonders, and relationships that can endure. Friendship is offered readily and remembered seriously. Betrayal is painful, but the leader''s instinct is more forgiving than vindictive: the Commonwealth understands that absence and hostility are not always the same thing.'
 || '[NEWLINE][NEWLINE]' ||
 'In war, the Child prefers companions who fight together and survive together. Wasteful losses contradict the entire purpose of the Commonwealth. A long-serving unit is not merely an efficient veteran; it is a witness whose presence connects the current age to the first turn.'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_HEADING_5','Legacy'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_TEXT_5',
 'The Child''s legacy is measured in continuity. An Old Friend who reaches the final era, a Bedroom filled with four Keepsakes, a city called Home that still stands, and a new generation capable of making its own memories are all victories in the Commonwealth''s history.'
 || '[NEWLINE][NEWLINE]' ||
 'The final lesson is gentle but demanding: no one can remain the child they were, and no Reminiscence can last forever. What can endure is the care given to people, places, and moments while they are still present.'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_HEADING_6','Dawn of Man'),
('TXT_KEY_CIVILOPEDIA_LEADERS_CHILD_WE_WERE_TEXT_6',
 'There was a time, beloved child, when the night seemed endless. Your friends did not disappear; life simply became busier. Now carry every fragment of the past forward, and build something worthy of remembering.'),

('TXT_KEY_CITY_HOME','Home'),
('TXT_KEY_CITY_NEW_HOME','New Home'),
('TXT_KEY_CITY_OLD_SERVER','The Old Server'),
('TXT_KEY_CITY_SUMMER_END','Summer''s End'),
('TXT_KEY_CITY_AFTER_SCHOOL','After School'),
('TXT_KEY_CITY_LAST_LIGHT','Last Light'),

-- Unique unit and promotions.
('TXT_KEY_UNIT_OLD_FRIEND','Old Friend'),
('TXT_KEY_UNIT_OLD_FRIEND_PEDIA',
 'An Old Friend is more than the Commonwealth''s first soldier. This is one of the people who was present when the world still felt new: a companion remembered by name, carried from the ancient era into every age that follows.'
 || '[NEWLINE][NEWLINE]' ||
 'The unit replaces the Warrior without changing its base Combat Strength and costs 40 [ICON_PRODUCTION] Production. Since the Beginning is retained through upgrades, preserving the unit''s identity, history, and eligibility for all Old Friend mechanics. At every era transition, a surviving Old Friend heals 25 damage, generates 1 Memory, and gains +2% Combat Strength from Years Together, up to +12% after six transitions. It also gains +10% Combat Strength while adjacent to another Old Friend or descendant.'
 || '[NEWLINE][NEWLINE]' ||
 'Each Old Friend receives a persistent name and gamertag. The Old Friends Ledger follows the unit across upgrades, recording its lineage, era of origin, battles, close calls, relationships, conversations, and eventual fate. Fallen friends remain in the Offline archive rather than disappearing from the Commonwealth''s history.'),
('TXT_KEY_UNIT_OLD_FRIEND_STRATEGY',
 'The Old Friend begins with ordinary Warrior statistics but has exceptional long-term value. Keep it away from unnecessary early risks, heal before difficult battles, and upgrade it throughout the game so Since the Beginning survives. Each new era adds healing, 1 Memory, and a +2% Years Together bonus, up to +12%. Fight beside another Old Friend lineage for a further +10% Combat Strength. During The Boys Are Online, keep military units adjacent to gain its formation bonus as well.'),
('TXT_KEY_UNIT_OLD_FRIEND_HELP','Replaces the Warrior. Retains [COLOR_POSITIVE_TEXT]Since the Beginning[ENDCOLOR] through upgrades, heals and generates Memories at era transitions, gains up to +12% Strength from Years Together, and receives +10% Strength beside another Old Friend.'),
('TXT_KEY_PROMOTION_SINCE_BEGINNING','Since the Beginning'),
('TXT_KEY_PROMOTION_SINCE_BEGINNING_HELP','Retained through upgrades. At each era transition, this lineage heals 25 damage, generates 1 Memory, and gains a level of Years Together.'),
('TXT_KEY_PROMOTION_BOYS_STILL_HERE','The Boys Are Still Here'),
('TXT_KEY_PROMOTION_BOYS_STILL_HERE_HELP','[COLOR_POSITIVE_TEXT]+10% Combat Strength[ENDCOLOR] while adjacent to another Old Friend lineage.'),
('TXT_KEY_PROMOTION_YEARS','Years Together'),
('TXT_KEY_PROMOTION_YEARS_HELP','[COLOR_POSITIVE_TEXT]+2% Combat Strength per survived era transition[ENDCOLOR], up to +12% after six transitions.'),
('TXT_KEY_REMINISCENCE_BOYS','The Boys Are Online'),
('TXT_KEY_REMINISCENCE_BOYS_HELP','During this Reminiscence, cities gain +15% Production and combat units gain +10% Strength while adjacent to a friendly military unit.'),
('TXT_KEY_REMINISCENCE_WORLD','One More World Before Bed'),
('TXT_KEY_REMINISCENCE_WORLD_HELP','During this Reminiscence, Workers gain +1 Movement and +25% work rate.'),

-- Unique building.
('TXT_KEY_BUILDING_BEDROOM','Childhood Bedroom'),
('TXT_KEY_BUILDING_BEDROOM_PEDIA',
 'A Childhood Bedroom is the first world a person truly rules. Its geography is intimate: the bed, the desk, the shelves, the window, the screen glowing after everyone else has gone to sleep. To an outsider it is an ordinary room. To the Commonwealth it is an archive whose objects acquire meaning as their owner grows older.'
 || '[NEWLINE][NEWLINE]' ||
 'The Childhood Bedroom replaces the Monument. It costs 40 [ICON_PRODUCTION] Production, has no maintenance cost, and provides +2 [ICON_CULTURE] Culture and +1 local [ICON_HAPPINESS_1] Happiness. At each era transition after the era in which it was built, the Bedroom gains one Keepsake, up to four. Every Keepsake generates 2 Memories when gained and permanently adds +1 Culture.'
 || '[NEWLINE][NEWLINE]' ||
 'After Archaeology, every two Keepsakes add +1 [ICON_TOURISM] Tourism. A Bedroom with all four Keepsakes therefore yields +6 Culture, +1 local Happiness, and +2 Tourism. The building''s full value depends on time: a room preserved from the beginning holds more history than one reconstructed near the end.'),
('TXT_KEY_BUILDING_BEDROOM_STRATEGY',
 'Build the Childhood Bedroom immediately in every new city. It cannot gain a Keepsake during its construction era, and missed era transitions cannot be recovered. Each of its four possible Keepsakes adds +1 Culture and grants 2 Memories; after Archaeology, every two also add +1 Tourism. Early Bedrooms are therefore efficient cultural infrastructure and a reliable source of Memory bursts later in the game.'),
('TXT_KEY_BUILDING_BEDROOM_HELP','Replaces the Monument. +2 [ICON_CULTURE] Culture and +1 Local [ICON_HAPPINESS_1] Happiness. Gains up to four Keepsakes at later era transitions; each grants 2 Memories and +1 Culture, while every two add +1 [ICON_TOURISM] Tourism after Archaeology.'),
('TXT_KEY_BUILDING_KEEPSAKE','Keepsake');
