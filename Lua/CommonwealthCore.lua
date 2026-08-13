-- The Commonwealth of Yesterday gameplay systems.
-- State is stored in the game's mod save database and survives save/load.
print('CommonwealthCore loaded')

local CIV = GameInfoTypes.CIVILIZATION_COMMONWEALTH_YESTERDAY
local OLD_FRIEND = GameInfoTypes.UNIT_COMMONWEALTH_OLD_FRIEND
local SINCE = GameInfoTypes.PROMOTION_COMMONWEALTH_SINCE_BEGINNING
local FRIEND_ADJ = GameInfoTypes.PROMOTION_COMMONWEALTH_ADJACENT_FRIEND
local REM_ADJ = GameInfoTypes.PROMOTION_COMMONWEALTH_REMINISCENCE_ADJ
local WORKER_BUFF = GameInfoTypes.PROMOTION_COMMONWEALTH_WORKER_MOVE
local BEDROOM = GameInfoTypes.BUILDING_COMMONWEALTH_BEDROOM
local KEEP = {
  GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_1, GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_2,
  GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_3, GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_4
}
local YEARS = {
  GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_1, GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_2,
  GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_3, GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_4,
  GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_5, GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_6
}
local B_PROD = GameInfoTypes.BUILDING_COMMONWEALTH_PRODUCTION
local B_CULT = GameInfoTypes.BUILDING_COMMONWEALTH_CULTURE
local B_SCI = GameInfoTypes.BUILDING_COMMONWEALTH_SCIENCE
local B_HAPPY = GameInfoTypes.BUILDING_COMMONWEALTH_HAPPINESS
local B_FOOD = GameInfoTypes.BUILDING_COMMONWEALTH_BEDROOM_FOOD
local MEL_MILITARY = GameInfoTypes.BUILDING_COMMONWEALTH_MEL_MILITARY
local MEL_SCIENCE = GameInfoTypes.BUILDING_COMMONWEALTH_MEL_SCIENCE
local MEL_CULTURE = GameInfoTypes.BUILDING_COMMONWEALTH_MEL_CULTURE
local MEL_UNHAPPINESS = GameInfoTypes.BUILDING_COMMONWEALTH_MEL_UNHAPPINESS
local save = CommonwealthSaveData or Modding.OpenSaveData()
local friendIdentities = {
  tribute = {
    {name='Trent', tags={'Trentrouls'}},
    {name='Gabriel', tags={'ThatOneYi','Shadow77281','antfinder'}},
    {name='Dion', tags={'Elkittyoverlord','SneakyMcMeowpants'}},
    {name='Harrison', tags={'Hazzad911','Jemkid911'}},
    {name='Lachlan', tags={'RomanGladius','ShermanMaster','CrimsonKnight57','Vigilanty101','Jemboy911'}},
    {name='Ben', tags={'BobTheNinja','Lynkrieger'}}
  },
  names = {
    'Alex','Avery','Aaron','Adrian','Archie','Bailey','Blake','Caleb','Callum','Cameron',
    'Casey','Charlie','Connor','Dylan','Elliot','Ethan','Felix','Finley','Flynn','Hayden',
    'Henry','Isaac','Jack','Jamie','Jesse','Joel','Jordan','Julian','Kai','Leo',
    'Liam','Lucas','Marcus','Mason','Max','Miles','Morgan','Nathan','Noah','Oliver',
    'Oscar','Owen','Parker','Quinn','Reece','Rhys','Riley','Rowan','Sam','Sebastian',
    'Taylor','Theo','Toby','Xavier'
  },
  tags = {
    'AfterSchool','ArcadeGhost','AutumnServer','BackyardHero','BitCrusader','BlockBuilder',
    'BlueTorch','BonusLevel','BossKey','ByteKnight','CabinetWizard','CampfireSave',
    'CartridgeKid','CheckpointZero','CloudRunner','CoOpComet','ControllerTwo','CRTGlow',
    'DialUpDreamer','DungeonSnack','DustyDisc','EarlyAccess','FinalContinue','FireflyPing',
    'FirstSpawn','ForestLobby','GameNight','GoldenSave','GreenPotion','HomeByDinner',
    'KeyboardMage','LANLegend','LastCheckpoint','LoadingPlease','LobbyLurker','LostManual',
    'MemoryCard','MidnightModem','MoonlitQuest','MysteryPlayer','NightOwl','NoScopeNostalgia',
    'OldMap','OneMoreRound','OrangePortal','PatchNotes','PauseMenu','PixelNomad',
    'PocketHealer','QuestMarker','QuietCarry','RareDrop','RespawnReady','RetroRanger',
    'SaveSlotThree','SecretLevel','SideQuest','SilentServer','SnackBreak','SplitScreen',
    'StarryLobby','StartButton','SunsetServer','TapeDeck','TheLastLife','TownPortal',
    'TradeWindow','TutorialSkip','VictoryJingle','WeekendRaid','WoodenSword','WorldSelect'
  }
}

local function key(p, suffix) return 'COY_' .. p .. '_' .. suffix end
local function get(p, suffix, default)
  local value = save.GetValue(key(p, suffix))
  if value == nil then return default end
  return value
end
local function set(p, suffix, value) save.SetValue(key(p, suffix), value) end

-- Tribute identities are weighted eight times more heavily than generated names.
-- Used identities are avoided until the available pool is exhausted.
function CommonwealthChooseFriendIdentity(p)
  local candidates, totalWeight = {}, 0
  for i, identity in ipairs(friendIdentities.tribute) do
    if tonumber(get(p, 'USED_TRIBUTE_'..i, 0)) == 0 then
      candidates[#candidates+1] = {kind='tribute', index=i, weight=8}
      totalWeight = totalWeight + 8
    end
  end
  for i, name in ipairs(friendIdentities.names) do
    if tonumber(get(p, 'USED_NAME_'..i, 0)) == 0 then
      candidates[#candidates+1] = {kind='generated', index=i, weight=1}
      totalWeight = totalWeight + 1
    end
  end
  if totalWeight == 0 then
    for i, identity in ipairs(friendIdentities.tribute) do candidates[#candidates+1] = {kind='tribute', index=i, weight=8}; totalWeight = totalWeight + 8 end
    for i, name in ipairs(friendIdentities.names) do candidates[#candidates+1] = {kind='generated', index=i, weight=1}; totalWeight = totalWeight + 1 end
  end
  local roll = Game.Rand(totalWeight, 'Commonwealth Old Friend identity') + 1
  local chosen = candidates[#candidates]
  for _, candidate in ipairs(candidates) do
    roll = roll - candidate.weight
    if roll <= 0 then chosen = candidate; break end
  end
  if chosen.kind == 'tribute' then
    local identity = friendIdentities.tribute[chosen.index]
    set(p, 'USED_TRIBUTE_'..chosen.index, 1)
    local tagIndex = Game.Rand(#identity.tags, 'Commonwealth tribute gamertag') + 1
    local alternates = {}
    for i, tag in ipairs(identity.tags) do if i ~= tagIndex then alternates[#alternates+1] = tag end end
    return identity.name, identity.tags[tagIndex], table.concat(alternates, ', ')
  end
  set(p, 'USED_NAME_'..chosen.index, 1)
  local availableTags = {}
  for i, tag in ipairs(friendIdentities.tags) do if tonumber(get(p, 'USED_TAG_'..i, 0)) == 0 then availableTags[#availableTags+1] = i end end
  if #availableTags == 0 then for i, tag in ipairs(friendIdentities.tags) do availableTags[#availableTags+1] = i end end
  local tagIndex = availableTags[Game.Rand(#availableTags, 'Commonwealth generated gamertag') + 1]
  set(p, 'USED_TAG_'..tagIndex, 1)
  return friendIdentities.names[chosen.index], friendIdentities.tags[tagIndex], ''
end
function CommonwealthTributeAliases(name, primaryTag)
  for _, identity in ipairs(friendIdentities.tribute) do if identity.name == name then
    local aliases={}
    for _, tag in ipairs(identity.tags) do if tag ~= primaryTag then aliases[#aliases+1]=tag end end
    return table.concat(aliases, ', ')
  end end
  return nil
end
local function isCommonwealth(player)
  return player and player:IsAlive() and player:GetCivilizationType() == CIV
end
local function gameSpeedTurns(base)
  local speed = GameInfo.GameSpeeds[Game.GetGameSpeedType()]
  return math.max(1, math.floor(base * (speed and speed.GoldenAgePercent or 100) / 100 + 0.5))
end
local function memories(p) return tonumber(get(p, 'MEM', 0)) or 0 end
local function addMemories(p, amount, reason)
  if amount <= 0 then return end
  set(p, 'MEM', math.min(100, memories(p) + amount))
  if reason and Players[p]:IsHuman() then
    Events.GameplayAlertMessage(Locale.ConvertTextKey('[COLOR_POSITIVE_TEXT]+' .. amount .. ' Memories[ENDCOLOR] — ' .. reason))
  end
  LuaEvents.CommonwealthStateChanged(p)
end
function CommonwealthAddMemories(p, amount, reason) addMemories(p, amount, reason) end

local function friendFieldByID(p, unitID, field) return 'FRIEND_' .. p .. '_' .. unitID .. '_' .. field end
local function friendField(unit, field) return friendFieldByID(unit:GetOwner(), unit:GetID(), field) end
local function isFriend(unit) return unit and unit:IsHasPromotion(SINCE) end
local function archivedFriendField(p,id,field) return 'COY2_REC_'..p..'_'..id..'_'..field end
local function archiveMapField(p,unitID) return 'COY2_MAP_'..p..'_'..unitID end
local function restoreMappedFriend(unit)
  local p,unitID=unit:GetOwner(),unit:GetID()
  local id=tonumber(save.GetValue(archiveMapField(p,unitID))) or 0
  if id <= 0 then return false end
  local name=save.GetValue(archivedFriendField(p,id,'NAME'))
  local tag=save.GetValue(archivedFriendField(p,id,'TAG'))
  if not name or not tag then return false end
  save.SetValue(archiveMapField(p,unitID),id)
  local fields={NAME='NAME',TAG='TAG',ALIASES='ALIASES',BORN='BORN',ERA='BORN_ERA',YEARS='YEARS',UPGRADES='UPGRADES',LINEAGE='LINEAGE'}
  for legacy,archived in pairs(fields) do
    local value=save.GetValue(archivedFriendField(p,id,archived))
    if value ~= nil then save.SetValue(friendFieldByID(p,unitID,legacy),value) end
  end
  save.SetValue(friendFieldByID(p,unitID,'ACTIVE'),1)
  save.SetValue(archivedFriendField(p,id,'CURRENT_UNIT'),unitID)
  save.SetValue(archivedFriendField(p,id,'CURRENT_TYPE'),unit:GetUnitType())
  save.SetValue(archivedFriendField(p,id,'STATUS'),'Still With Us')
  save.SetValue(archivedFriendField(p,id,'DEATH_TURN'),-1)
  save.SetValue(archivedFriendField(p,id,'X'),unit:GetX()); save.SetValue(archivedFriendField(p,id,'Y'),unit:GetY())
  unit:SetName(tostring(name)..' - '..tostring(tag))
  print('CommonwealthCore: restored mapped profile '..id..' for unit '..unitID)
  return true
end
local function registerFriend(unit)
  if not isFriend(unit) then return false end
  local p = unit:GetOwner()
  local field = friendField(unit, 'NAME')
  local storedName = save.GetValue(field)
  local active = tonumber(save.GetValue(friendField(unit, 'ACTIVE')))
  local archiveID = tonumber(save.GetValue('COY2_MAP_'..p..'_'..unit:GetID())) or 0
  local currentName = tostring(unit:GetName() or '')
  -- Civ V eventually reuses dead unit IDs. Only an active marker, current
  -- archive mapping, or matching custom name proves this cache belongs to the
  -- present unit; otherwise replace the stale identity for the new generation.
  if storedName ~= nil and (active == 1 or archiveID > 0 or string.find(currentName,tostring(storedName),1,true)) then
    save.SetValue(friendField(unit, 'ACTIVE'), 1)
    local storedTag = tostring(save.GetValue(friendField(unit, 'TAG')) or '')
    unit:SetName(tostring(storedName) .. (storedTag ~= '' and ' - ' .. storedTag or ''))
    return true
  end
  if restoreMappedFriend(unit) then return true end
  -- Upgraded descendants receive identity only through their exact archive
  -- mapping or the native upgrade handoff. Never guess from names or tiles.
  if unit:GetUnitType() ~= OLD_FRIEND then return false end
  local name, tag, aliases = CommonwealthChooseFriendIdentity(p)
  save.SetValue(field, name); save.SetValue(friendField(unit, 'TAG'), tag)
  save.SetValue(friendField(unit, 'ALIASES'), aliases)
  save.SetValue(friendField(unit, 'ACTIVE'), 1)
  save.SetValue(friendField(unit, 'BORN'), Game.GetGameTurn())
  save.SetValue(friendField(unit, 'ERA'), Players[p]:GetCurrentEra())
  save.SetValue(friendField(unit, 'YEARS'), 0); save.SetValue(friendField(unit, 'UPGRADES'), 0)
  save.SetValue(friendField(unit, 'LINEAGE'), GameInfo.Units[unit:GetUnitType()].Type)
  unit:SetName(name .. ' - ' .. tag)
  return true
end

local unitFriendFields = {'NAME','TAG','ALIASES','BORN','ERA','YEARS','UPGRADES','LINEAGE'}
local function transferUnitFriend(p, oldID, newID)
  if oldID == newID then return end
  for _, field in ipairs(unitFriendFields) do
    local value = save.GetValue(friendFieldByID(p,oldID,field))
    if value ~= nil then save.SetValue(friendFieldByID(p,newID,field),value) end
  end
  save.SetValue(friendFieldByID(p,oldID,'ACTIVE'),0)
  save.SetValue(friendFieldByID(p,newID,'ACTIVE'),1)
end

local function applyYears(unit, level)
  for i, promo in ipairs(YEARS) do unit:SetHasPromotion(promo, i == level) end
end
local function friendYears(unit)
  local p,unitID=unit:GetOwner(),unit:GetID()
  local cached=tonumber(save.GetValue(friendField(unit,'YEARS'))) or 0
  local archiveID=tonumber(save.GetValue('COY2_MAP_'..p..'_'..unitID)) or 0
  local archived=archiveID > 0 and tonumber(save.GetValue('COY2_REC_'..p..'_'..archiveID..'_YEARS')) or 0
  local level=math.min(6,math.max(cached,archived or 0))
  if cached ~= level then save.SetValue(friendField(unit,'YEARS'),level) end
  return level
end
local function adjacentMilitary(unit, requireFriend)
  local plot = unit and unit:GetPlot()
  -- Upgrades briefly expose the replacement unit before it has a plot. Treat
  -- that transition as non-adjacent instead of aborting the identity handoff.
  if not plot then return false end
  for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1 do
    local otherPlot = Map.PlotDirection(plot:GetX(), plot:GetY(), direction)
    if otherPlot then
      for i = 0, otherPlot:GetNumUnits() - 1 do
        local other = otherPlot:GetUnit(i)
        if other and other:GetOwner() == unit:GetOwner() and other:GetID() ~= unit:GetID()
          and other:IsCombatUnit() and (not requireFriend or isFriend(other)) then return true end
      end
    end
  end
  return false
end
local function refreshUnits(p)
  local player = Players[p]
  if not isCommonwealth(player) then return end
  local active = tonumber(get(p, 'ACTIVE', 0)) or 0
  for unit in player:Units() do
    if isFriend(unit) then
      if registerFriend(unit) then applyYears(unit,friendYears(unit)) end
      unit:SetHasPromotion(FRIEND_ADJ, adjacentMilitary(unit, true))
    end
    unit:SetHasPromotion(REM_ADJ, active == 1 and unit:IsCombatUnit() and adjacentMilitary(unit, false))
    unit:SetHasPromotion(WORKER_BUFF, active == 2 and unit:GetUnitClassType() == GameInfoTypes.UNITCLASS_WORKER)
  end
end

local function bedroomAge(city)
  local value = tonumber(save.GetValue('COY_CITY_' .. city:GetOwner() .. '_' .. city:GetID() .. '_BED_ERA'))
  return value
end
local function setBedroomAge(city, era)
  save.SetValue('COY_CITY_' .. city:GetOwner() .. '_' .. city:GetID() .. '_BED_ERA', era)
end
local function hasBedroom(city)
  return city and (city:GetNumRealBuilding(BEDROOM) > 0 or city:GetNumFreeBuilding(BEDROOM) > 0)
end
local function keepsakes(city)
  local count = 0
  for _, building in ipairs(KEEP) do if city:GetNumRealBuilding(building) > 0 then count = count + 1 end end
  return count
end

local function applyEmpireEffects(p)
  local player = Players[p]
  if not isCommonwealth(player) then return end
  local active, melancholy = tonumber(get(p, 'ACTIVE', 0)) or 0, tonumber(get(p, 'MEL', 0)) or 0
  for city in player:Cities() do
    city:SetNumRealBuilding(B_PROD, active == 1 and 15 or 0)
    city:SetNumRealBuilding(B_CULT, active == 3 and 15 or 0)
    city:SetNumRealBuilding(B_SCI, 0)
    city:SetNumRealBuilding(B_HAPPY, active == 3 and 2 or 0)
    city:SetNumRealBuilding(B_FOOD, active == 3 and hasBedroom(city) and 1 or 0)
    -- Dedicated signed-effect buildings are toggled only between zero and one.
    -- This avoids unsupported negative building counts and cleans every stale
    -- Melancholy state whenever empire effects are refreshed.
    city:SetNumRealBuilding(MEL_MILITARY, melancholy == 1 and 1 or 0)
    city:SetNumRealBuilding(MEL_SCIENCE, melancholy == 2 and 1 or 0)
    city:SetNumRealBuilding(MEL_CULTURE, melancholy == 3 and 1 or 0)
    city:SetNumRealBuilding(MEL_UNHAPPINESS, melancholy == 3 and city:IsCapital() and 1 or 0)
  end
end

function CommonwealthActivate(p, choice)
  local player = Players[p]
  if not isCommonwealth(player) or choice < 1 or choice > 3 then return false end
  if (tonumber(get(p, 'ACTIVE_TURNS', 0)) or 0) > 0 or (tonumber(get(p, 'MEL_TURNS', 0)) or 0) > 0 then return false end
  local used = tonumber(get(p, 'USED', 0)) or 0
  local cost = 25 + used * 10
  if memories(p) < cost then return false end
  set(p, 'MEM', memories(p) - cost); set(p, 'USED', used + 1)
  set(p, 'ACTIVE', choice); set(p, 'ACTIVE_TURNS', gameSpeedTurns(8)); set(p, 'MEL', 0)
  applyEmpireEffects(p); refreshUnits(p); LuaEvents.CommonwealthStateChanged(p)
  return true
end

local function eraChanged(p, newEra)
  local player = Players[p]
  set(p, 'ERA', newEra); set(p, 'USED', 0)
  addMemories(p, 6 + 2 * player:GetNumCities(), 'a new era began')
  for unit in player:Units() do
    if isFriend(unit) then
      if registerFriend(unit) then
        local level = math.min(6, friendYears(unit) + 1)
        save.SetValue(friendField(unit, 'YEARS'), level)
        save.SetValue(friendField(unit, 'ERAS'), (tonumber(save.GetValue(friendField(unit, 'ERAS'))) or 0) + 1)
        unit:ChangeDamage(-25); addMemories(p, 1, nil); applyYears(unit, level)
      end
    end
  end
  for city in player:Cities() do
    if hasBedroom(city) then
      local builtEra = bedroomAge(city)
      if builtEra == nil then setBedroomAge(city, newEra)
      elseif builtEra < newEra then
        local level = keepsakes(city)
        if level < 4 then city:SetNumRealBuilding(KEEP[level + 1], 1); addMemories(p, 2, nil) end
      end
    end
  end
  applyEmpireEffects(p); refreshUnits(p)
end

local function turnStart(p)
  local player = Players[p]
  if not isCommonwealth(player) then return end
  local era = player:GetCurrentEra()
  local previousEra = get(p, 'ERA', nil)
  -- Register free policy Bedrooms before checking for an era transition. This
  -- lets a save made just before the next era award the naturally earned
  -- Keepsake without granting one merely for loading an existing save.
  for city in player:Cities() do
    if hasBedroom(city) and bedroomAge(city) == nil then
      setBedroomAge(city, tonumber(previousEra) or era)
    end
  end
  if previousEra == nil then set(p, 'ERA', era) elseif tonumber(previousEra) ~= era then eraChanged(p, era) end
  local activeTurns = tonumber(get(p, 'ACTIVE_TURNS', 0)) or 0
  local melTurns = tonumber(get(p, 'MEL_TURNS', 0)) or 0
  if activeTurns > 0 then
    activeTurns = activeTurns - 1; set(p, 'ACTIVE_TURNS', activeTurns)
    if activeTurns == 0 then
      local ended = tonumber(get(p, 'ACTIVE', 0)) or 0
      set(p, 'ACTIVE', 0); set(p, 'MEL', ended); set(p, 'MEL_TURNS', gameSpeedTurns(4))
    end
  elseif melTurns > 0 then
    melTurns = melTurns - 1; set(p, 'MEL_TURNS', melTurns)
    if melTurns == 0 then set(p, 'MEL', 0) end
  end
  applyEmpireEffects(p); refreshUnits(p)
  if not player:IsHuman() and memories(p) >= 25 and activeTurns == 0 and melTurns == 0 then
    CommonwealthActivate(p, player:GetNumMilitaryUnits() > player:GetNumCities() * 2 and 1 or (player:GetExcessHappiness() > 5 and 3 or 2))
  end
end

GameEvents.PlayerDoTurn.Add(turnStart)
GameEvents.UnitSetXY.Add(function(p) refreshUnits(p) end)
GameEvents.UnitCreated.Add(function(p, unitID)
  local player, unit = Players[p], Players[p] and Players[p]:GetUnitByID(unitID)
  if isCommonwealth(player) and unit and unit:GetUnitType() == OLD_FRIEND then registerFriend(unit) end
end)
if GameEvents.UnitUpgraded then GameEvents.UnitUpgraded.Add(function(p, oldID, newID)
  local player = Players[p]
  local oldUnit, newUnit = player and player:GetUnitByID(oldID), player and player:GetUnitByID(newID)
  if not isCommonwealth(player) or not newUnit then return end
  -- CP fires UnitUpgraded before CvUnit::convert copies promotions and names to
  -- the replacement. The old unit is therefore authoritative in this event;
  -- checking the new unit here rejects every ordinary Old Friend upgrade.
  if oldUnit and oldUnit:IsHasPromotion(SINCE) then
    transferUnitFriend(p,oldID,newID)
  else addMemories(p, 2, 'a unit was upgraded') end
end) end
if GameEvents.GreatPersonExpended then GameEvents.GreatPersonExpended.Add(function(p) if isCommonwealth(Players[p]) then addMemories(p, 3, 'a Great Person was expended') end end) end
if GameEvents.CityConstructed then GameEvents.CityConstructed.Add(function(p, cityID, buildingType)
  local player, city = Players[p], Players[p] and Players[p]:GetCityByID(cityID)
  if not isCommonwealth(player) or not city then return end
  if buildingType == BEDROOM then setBedroomAge(city, player:GetCurrentEra()) end
  local building = GameInfo.Buildings[buildingType]
  local class = building and GameInfo.BuildingClasses[building.BuildingClass]
  if class and class.MaxGlobalInstances == 1 then addMemories(p, 4, 'a World Wonder was completed') end
end) end

LuaEvents.CommonwealthGetState.Add(function(p)
  LuaEvents.CommonwealthStateResponse(p, memories(p), tonumber(get(p,'USED',0)) or 0,
    tonumber(get(p,'ACTIVE',0)) or 0, tonumber(get(p,'ACTIVE_TURNS',0)) or 0,
    tonumber(get(p,'MEL',0)) or 0, tonumber(get(p,'MEL_TURNS',0)) or 0)
end)
LuaEvents.CommonwealthActivateRequest.Add(function(p, choice) CommonwealthActivate(p, choice) end)
LuaEvents.CommonwealthLedgerRequest.Add(function(p)
  local rows = {}
  if isCommonwealth(Players[p]) then
    for unit in Players[p]:Units() do if isFriend(unit) then
      registerFriend(unit)
      rows[#rows+1] = {name=save.GetValue(friendField(unit,'NAME')) or 'Old Friend', tag=save.GetValue(friendField(unit,'TAG')) or '',
        form=Locale.ConvertTextKey(GameInfo.Units[unit:GetUnitType()].Description), years=friendYears(unit),
        level=unit:GetLevel(), experience=unit:GetExperience(), status='Still With Us'}
    end end
  end
  LuaEvents.CommonwealthLedgerResponse(p, rows)
end)
