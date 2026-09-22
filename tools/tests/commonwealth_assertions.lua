local I=GameInfoTypes
local S=TestState.stored
local F=CommonwealthFriendState

local function key(player,profile,field) return 'COY2_REC_'..player..'_'..profile..'_'..field end
local function record(player,profile,field) return S[key(player,profile,field)] end
local function mapping(player,unitID) local value=tonumber(S['COY2_MAP_'..player..'_'..unitID]) or 0; return value>0 and value or nil end
local function fire(name,...) for _,handler in ipairs(GameEvents[name].handlers) do handler(...) end end
local function add(unit) Players[unit.owner].units[unit.id]=unit end

for _,name in ipairs({'UnitCreated','UnitSetXY','UnitUpgraded','UnitPrekill','UnitConverted',
  'BattleStarted','BattleJoined','BattleFinished','PlayerDoTurn'}) do
  assert(#GameEvents[name].handlers>0,name..' handler is not registered')
end
assert(#Events.RunCombatSim.handlers==0 and #Events.EndCombatSim.handlers==0,
  'persistent telemetry still depends on presentation combat events')

-- A genuine Old Friend upgraded before its first roster pass must mint exactly
-- one permanent profile inside the authoritative UnitUpgraded callback.
local early=NewUnit(0,1,I.UNIT_COMMONWEALTH_OLD_FRIEND,true)
local sword=NewUnit(0,2,I.UNIT_TEST_SWORD,false)
fire('UnitUpgraded',0,1,2,false)
local earlyProfile=mapping(0,2)
assert(earlyProfile and mapping(0,1)==nil,'pre-registration upgrade lost or duplicated its mapping')
assert(record(0,earlyProfile,'CURRENT_UNIT')==2 and record(0,earlyProfile,'CURRENT_TYPE')==I.UNIT_TEST_SWORD)
assert(record(0,earlyProfile,'LINEAGE')=='UNIT_COMMONWEALTH_OLD_FRIEND|UNIT_TEST_SWORD')
assert(record(0,earlyProfile,'UPGRADES')==1 and record(0,earlyProfile,'MEMORIES')==4)
assert(S.COY_0_MEM==4 and sword.name~='','Friend upgrade did not award/name atomically')

-- Repeated delivery is idempotent even though the first handoff retired oldID.
fire('UnitUpgraded',0,1,2,false)
assert(record(0,earlyProfile,'UPGRADES')==1 and S.COY_0_MEM==4,'duplicate upgrade was counted twice')

-- Simulate the post-callback promotion copy and verify Years Together remains
-- synchronized when a registered lineage upgrades again.
sword:SetHasPromotion(I.PROMOTION_COMMONWEALTH_SINCE_BEGINNING,true)
S[key(0,earlyProfile,'YEARS')]=3
local musket=NewUnit(0,3,I.UNIT_TEST_MUSKET,false)
fire('UnitUpgraded',0,2,3,false)
assert(mapping(0,3)==earlyProfile and record(0,earlyProfile,'UPGRADES')==2)
assert(record(0,earlyProfile,'LINEAGE')=='UNIT_COMMONWEALTH_OLD_FRIEND|UNIT_TEST_SWORD|UNIT_TEST_MUSKET')
assert(musket:IsHasPromotion(I.PROMOTION_COMMONWEALTH_YEARS_3),'Years Together was not synchronized')
assert(S.COY_0_MEM==8,'second Friend upgrade did not award exactly four Memories')

-- Ordinary upgrades remain on the +2 path.
local ordinary=NewUnit(0,40,I.UNIT_TEST_SWORD,false)
local ordinaryNew=NewUnit(0,41,I.UNIT_TEST_MUSKET,false)
fire('UnitUpgraded',0,40,41,false)
assert(S.COY_0_MEM==10,'ordinary upgrade reward changed')

-- Same-ID ruins replacement transfers the existing profile and records one form.
local ruinsOld=NewUnit(0,5,I.UNIT_COMMONWEALTH_OLD_FRIEND,true)
local ruinsProfile=F.Register(ruinsOld,true)
local ruinsNew=NewUnit(0,5,I.UNIT_TEST_SWORD,true)
assert(F.HandleUpgrade(0,5,5,true,ruinsOld,ruinsNew))
assert(mapping(0,5)==ruinsProfile and record(0,ruinsProfile,'UPGRADES')==1)

-- Two Friends upgrading on one turn retain distinct permanent identities.
local oldA=NewUnit(0,6,I.UNIT_COMMONWEALTH_OLD_FRIEND,true)
local oldB=NewUnit(0,7,I.UNIT_COMMONWEALTH_OLD_FRIEND,true)
local newA=NewUnit(0,8,I.UNIT_TEST_SWORD,false)
local newB=NewUnit(0,9,I.UNIT_TEST_SWORD,false)
fire('UnitUpgraded',0,6,8,false); fire('UnitUpgraded',0,7,9,false)
assert(mapping(0,8) and mapping(0,9) and mapping(0,8)~=mapping(0,9),'same-turn upgrades merged profiles')

-- A retired numeric ID cannot resurrect the old identity; it may only mint a
-- new profile after the conversion tick has passed.
local recycled=NewUnit(0,6,I.UNIT_COMMONWEALTH_OLD_FRIEND,true)
assert(F.Register(recycled,true)==nil,'same-tick recycled UnitID was trusted')
Game.turn=1
local recycledProfile=F.Register(recycled,true)
assert(recycledProfile and recycledProfile~=mapping(0,8),'recycled UnitID reused a permanent profile')

-- Leaving Commonwealth ownership archives the original profile and removes
-- every Commonwealth-only persistent or temporary promotion from the receiver.
local transfer=NewUnit(0,20,I.UNIT_COMMONWEALTH_OLD_FRIEND,true)
local transferProfile=F.Register(transfer,true)
local foreign=NewUnit(1,30,I.UNIT_TEST_SWORD,true)
for _,promotion in ipairs({I.PROMOTION_COMMONWEALTH_ADJACENT_FRIEND,I.PROMOTION_COMMONWEALTH_REMINISCENCE_ADJ,
  I.PROMOTION_COMMONWEALTH_WORKER_MOVE,I.PROMOTION_COMMONWEALTH_YEARS_4}) do foreign:SetHasPromotion(promotion,true) end
F.OnUnitConverted(0,1,20,30,false)
for _,promotion in ipairs({I.PROMOTION_COMMONWEALTH_SINCE_BEGINNING,I.PROMOTION_COMMONWEALTH_ADJACENT_FRIEND,
  I.PROMOTION_COMMONWEALTH_REMINISCENCE_ADJ,I.PROMOTION_COMMONWEALTH_WORKER_MOVE,I.PROMOTION_COMMONWEALTH_YEARS_4}) do
  assert(not foreign:IsHasPromotion(promotion),'foreign unit retained Commonwealth promotion '..promotion)
end
assert(record(0,transferProfile,'STATUS')=='Offline' and record(0,transferProfile,'CURRENT_UNIT')==-1)
assert(record(0,transferProfile,'LOCATION')=='Transferred away','transfer was not archived distinctly')
assert(S.FRIEND_0_20_ACTIVE==0 and S.FRIEND_0_20_PROFILE_ID==-1,'transferred unit cache stayed active')

-- Gameplay battle events update history without RunCombatSim/EndCombatSim.
local fighter=NewUnit(0,50,I.UNIT_COMMONWEALTH_OLD_FRIEND,true)
local fighterProfile=F.Register(fighter,true)
local function friendKillsEnemy(enemyID,friendRole)
  local enemy=NewUnit(1,enemyID,I.UNIT_TEST_ENEMY,false)
  F.OnBattleStarted(0,0,0)
  if friendRole==0 then F.OnBattleJoined(0,50,0,false); F.OnBattleJoined(1,enemyID,1,false)
  else F.OnBattleJoined(1,enemyID,0,false); F.OnBattleJoined(0,50,1,false) end
  F.OnUnitPrekill(1,enemyID,0,enemy.x,enemy.y,0,0)
  Players[1].units[enemyID]=nil
  F.OnBattleFinished()
end
friendKillsEnemy(60,0) -- ranged/attacking kill
friendKillsEnemy(61,0) -- Quick Combat uses the same gameplay path
friendKillsEnemy(62,1) -- defensive kill
friendKillsEnemy(63,0) -- off-screen AI-turn path has no UI dependency
assert(record(0,fighterProfile,'BATTLES')==4 and record(0,fighterProfile,'KILLS')==4,
  'gameplay battle telemetry missed an attacking, defensive, Quick Combat, or off-screen result')

-- Save/reload invariants are represented solely by the persistent archive:
-- current form, lineage and profile mapping survive independently of Lua tables.
assert(S['COY2_MAP_0_3']==earlyProfile and S[key(0,earlyProfile,'CURRENT_UNIT')]==3)
assert(S[key(0,earlyProfile,'CURRENT_TYPE')]==I.UNIT_TEST_MUSKET)
assert(S[key(0,earlyProfile,'LINEAGE')]=='UNIT_COMMONWEALTH_OLD_FRIEND|UNIT_TEST_SWORD|UNIT_TEST_MUSKET')

print('PASS Old Friend lifecycle: upgrades, reuse, transfer, combat and persistent invariants')
