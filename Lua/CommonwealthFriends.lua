-- Persistent Old Friends archive and telemetry for the advanced Ledger.
print('CommonwealthFriends loaded')

local CIV = GameInfoTypes.CIVILIZATION_COMMONWEALTH_YESTERDAY
local OLD_FRIEND = GameInfoTypes.UNIT_COMMONWEALTH_OLD_FRIEND
local SINCE = GameInfoTypes.PROMOTION_COMMONWEALTH_SINCE_BEGINNING
local BEDROOM = GameInfoTypes.BUILDING_COMMONWEALTH_BEDROOM
local YEARS = {
  GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_1, GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_2,
  GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_3, GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_4,
  GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_5, GameInfoTypes.PROMOTION_COMMONWEALTH_YEARS_6
}
local save = CommonwealthSaveData or Modding.OpenSaveData()
local combatCredit = {}
local conversationLines = {}
local EVENT_LIFETIME = 40
local MAX_PENDING_EVENTS = 6
local GLOBAL_CONVERSATION_COOLDOWN = 5
local PAIR_CONVERSATION_COOLDOWN = 9
local GLOBAL_LINE_REPEAT_COOLDOWN = 120
local BASE_CONVERSATION_CHANCE = 15
local REMINISCENCE_CHANCE_BONUS = 10
local BEDROOM_CHANCE_BONUS = 7
local EVENT_CONVERSATION_CHANCE = 75
local CONVERSATION_PITY_LIMIT = 4
local lastConversationTrace = ''
if GameInfo.Commonwealth_Conversations then
  for row in GameInfo.Commonwealth_Conversations() do
    conversationLines[#conversationLines+1]={id=row.ID,kind=row.EventType,a=row.SpeakerOne,b=row.SpeakerTwo}
  end
end
print('CommonwealthFriends: loaded '..tostring(#conversationLines)..' conversation exchanges')
if #conversationLines == 0 then print('CommonwealthFriends: no conversation data was loaded') end
local function isCommonwealth(player)
  return player and player:IsAlive() and player:GetCivilizationType() == CIV
end
local function rkey(p, id, field) return 'COY2_REC_'..p..'_'..id..'_'..field end
local function mkey(p, unitID) return 'COY2_MAP_'..p..'_'..unitID end
local function getr(p, id, field, default)
  local value = save.GetValue(rkey(p,id,field)); if value == nil then return default end; return value
end
local function setr(p, id, field, value) save.SetValue(rkey(p,id,field), value) end
local function storeFriendEvents(p,id,events,previousCount)
  previousCount=math.max(tonumber(previousCount) or 0,tonumber(getr(p,id,'EVENT_QUEUE_COUNT',0)) or 0)
  setr(p,id,'EVENT_QUEUE_COUNT',#events)
  for i=1,math.max(previousCount,#events) do
    local event=events[i]
    setr(p,id,'EVENT_QUEUE_'..i..'_TYPE',event and event.kind or '')
    setr(p,id,'EVENT_QUEUE_'..i..'_TURN',event and event.turn or -1000)
  end
end
local function loadFriendEvents(p,id)
  local turn=Game.GetGameTurn(); local storedCount=tonumber(getr(p,id,'EVENT_QUEUE_COUNT',0)) or 0
  local events,seen,changed={},{},false
  for i=1,storedCount do
    local kind=getr(p,id,'EVENT_QUEUE_'..i..'_TYPE','')
    local eventTurn=tonumber(getr(p,id,'EVENT_QUEUE_'..i..'_TURN',-1000)) or -1000
    if kind ~= '' and eventTurn <= turn and turn-eventTurn <= EVENT_LIFETIME and not seen[kind] then
      events[#events+1]={kind=kind,turn=eventTurn}; seen[kind]=true
    else changed=true end
  end
  if changed or #events ~= storedCount then storeFriendEvents(p,id,events,storedCount) end
  return events
end
local function markFriendEvent(p,id,eventType)
  local events=loadFriendEvents(p,id)
  for i,event in ipairs(events) do
    if event.kind == eventType then table.remove(events,i); break end
  end
  -- Coalesce repeated events of one kind while moving the refreshed event to
  -- the back, so older different events retain FIFO priority.
  events[#events+1]={kind=eventType,turn=Game.GetGameTurn()}
  while #events > MAX_PENDING_EVENTS do table.remove(events,1) end
  storeFriendEvents(p,id,events)
end
local function clearFriendEvent(p,id,index)
  local events=loadFriendEvents(p,id)
  if index and events[index] then table.remove(events,index) end
  storeFriendEvents(p,id,events)
end
local function friendID(p, unitID)
  local id = tonumber(save.GetValue(mkey(p,unitID))) or 0
  return id > 0 and id or nil
end
local function setFriendID(p, unitID, id) save.SetValue(mkey(p,unitID), id or -1) end
local function unitFriendField(p,unitID,field) return 'FRIEND_'..p..'_'..unitID..'_'..field end
local function eraName(era)
  local row = GameInfo.Eras[era]; return row and Locale.ConvertTextKey(row.Description) or ('Era '..tostring(era))
end
local function unitName(unitType)
  local row = GameInfo.Units[unitType]; return row and Locale.ConvertTextKey(row.Description) or 'Unknown Unit'
end
local function appendTimeline(p, id, text, eventTurn)
  local count = tonumber(getr(p,id,'TIMELINE_COUNT',0)) or 0
  -- Keep a rolling archive. The old cap preserved the first 30 events forever,
  -- which silently discarded later upgrades in long games.
  if count >= 30 then
    for i=2,count do
      setr(p,id,'TIME_'..(i-1)..'_TURN',getr(p,id,'TIME_'..i..'_TURN',0))
      setr(p,id,'TIME_'..(i-1)..'_TEXT',getr(p,id,'TIME_'..i..'_TEXT',''))
    end
    count = 29
  end
  count = count + 1; setr(p,id,'TIMELINE_COUNT',count)
  setr(p,id,'TIME_'..count..'_TURN',eventTurn or Game.GetGameTurn()); setr(p,id,'TIME_'..count..'_TEXT',text)
end
local function plotLocation(plot)
  if not plot then return 'Unknown' end
  local city = plot:GetPlotCity()
  if city then return city:GetName() end
  local owner = plot:GetOwner()
  if owner and owner >= 0 and Players[owner] then
    local capital = Players[owner]:GetCapitalCity()
    if capital and Map.PlotDistance(plot:GetX(),plot:GetY(),capital:GetX(),capital:GetY()) <= 3 then return 'Near '..capital:GetName() end
  end
  return 'Tile '..plot:GetX()..', '..plot:GetY()
end
local function lineageContains(lineage, value)
  for part in string.gmatch(lineage or '', '[^|]+') do if part == value then return true end end
  return false
end
local function timelineHasUpgrade(p,id,form)
  local needle=' became '..form..'.'
  local count=tonumber(getr(p,id,'TIMELINE_COUNT',0)) or 0
  for i=1,count do
    if string.find(getr(p,id,'TIME_'..i..'_TEXT',''),needle,1,true) then return true end
  end
  return false
end
local function recordLedgerUpgrade(p,id,unitType,eventTurn)
  local typeRow=GameInfo.Units[unitType]
  if not typeRow then return false end
  local typeName=typeRow.Type
  local lineage=getr(p,id,'LINEAGE','')
  if not lineageContains(lineage,typeName) then
    lineage=lineage..(lineage ~= '' and '|' or '')..typeName
    setr(p,id,'LINEAGE',lineage)
  end
  local forms=0
  for _ in string.gmatch(lineage,'[^|]+') do forms=forms+1 end
  local expectedUpgrades=math.max(0,forms-1)
  local recordedUpgrades=tonumber(getr(p,id,'UPGRADES',0)) or 0
  local missingUpgrades=math.max(0,expectedUpgrades-recordedUpgrades)
  if missingUpgrades > 0 then
    setr(p,id,'UPGRADES',expectedUpgrades)
    setr(p,id,'MEMORIES',(tonumber(getr(p,id,'MEMORIES',0)) or 0)+(missingUpgrades*4))
  end
  local form=unitName(unitType)
  local appended=false
  local recordedKey='UPGRADE_RECORDED_'..typeName
  if tonumber(getr(p,id,recordedKey,0)) ~= 1 and not timelineHasUpgrade(p,id,form) then
    appendTimeline(p,id,getr(p,id,'NAME','An Old Friend')..' became '..form..'.',eventTurn)
    markFriendEvent(p,id,'upgrade')
    appended=true
  end
  setr(p,id,recordedKey,1)
  return missingUpgrades > 0 or appended
end

local function registerFriend(unit)
  if not unit or not unit:IsHasPromotion(SINCE) then return nil end
  local p, unitID = unit:GetOwner(), unit:GetID()
  local id = friendID(p,unitID)
  if id then return id end
  -- Goody-hut upgrades can destroy and recreate a unit with the same ID. The
  -- pre-kill callback stores the original profile under that ID, so reclaim it
  -- before UnitCreated has a chance to make a second Friend profile.
  local pendingID=tonumber(save.GetValue('COY2_PENDING_UNIT_'..p..'_'..unitID)) or 0
  local pendingTurn=pendingID > 0 and (tonumber(getr(p,pendingID,'PENDING_DEATH_TURN',-1000)) or -1000) or -1000
  if unit:GetUnitType() ~= OLD_FRIEND and pendingID > 0 and pendingTurn == Game.GetGameTurn()
    then
    setFriendID(p,unitID,pendingID)
    setr(p,pendingID,'CURRENT_UNIT',unitID); setr(p,pendingID,'CURRENT_TYPE',unit:GetUnitType())
    setr(p,pendingID,'STATUS','Still With Us'); setr(p,pendingID,'DEATH_TURN',-1)
    unit:SetName(getr(p,pendingID,'NAME','Old Friend')..' - '..getr(p,pendingID,'TAG',''))
    print('CommonwealthFriends: reclaimed pending profile '..pendingID..' for recreated unit '..unitID)
    return pendingID
  end
  -- Native upgrades inherit Since the Beginning before UnitUpgraded fires.
  -- Do not create a provisional second profile for that brief replacement;
  -- the exact old/new ID handoff below will attach the original profile.
  if unit:GetUnitType() ~= OLD_FRIEND then return nil end
  local nextID = tonumber(save.GetValue('COY2_COUNT_'..p)) or 0
  id = nextID + 1; save.SetValue('COY2_COUNT_'..p,id); setFriendID(p,unitID,id)
  local unitPrefix = 'FRIEND_'..p..'_'..unitID..'_'
  local name = save.GetValue(unitPrefix..'NAME')
  local tag = save.GetValue(unitPrefix..'TAG')
  local aliases = save.GetValue(unitPrefix..'ALIASES') or ''
  if not name or not tag then name,tag,aliases = CommonwealthChooseFriendIdentity(p) end
  local unitType = unit:GetUnitType()
  setr(p,id,'NAME',name); setr(p,id,'TAG',tag); setr(p,id,'ALIASES',aliases); setr(p,id,'BORN',Game.GetGameTurn())
  setr(p,id,'BORN_ERA',Players[p]:GetCurrentEra()); setr(p,id,'LAST_ERA',Players[p]:GetCurrentEra())
  setr(p,id,'YEARS',tonumber(save.GetValue(unitPrefix..'YEARS')) or 0)
  setr(p,id,'ERAS',tonumber(save.GetValue(unitPrefix..'ERAS')) or 0)
  setr(p,id,'BATTLES',0); setr(p,id,'KILLS',0); setr(p,id,'DISTANCE',0); setr(p,id,'UPGRADES',0)
  setr(p,id,'LOW_HP',unit:GetMaxHitPoints()-unit:GetDamage()); setr(p,id,'MEMORIES',0)
  setr(p,id,'CURRENT_UNIT',unitID); setr(p,id,'CURRENT_TYPE',unitType); setr(p,id,'LINEAGE',GameInfo.Units[unitType].Type)
  setr(p,id,'STATUS','Still With Us'); setr(p,id,'X',unit:GetX()); setr(p,id,'Y',unit:GetY())
  setr(p,id,'LOCATION',plotLocation(unit:GetPlot())); setr(p,id,'LEVEL',unit:GetLevel()); setr(p,id,'XP',unit:GetExperience())
  unit:SetName(name..' - '..tag)
  appendTimeline(p,id,name..' joined the Commonwealth during the '..eraName(Players[p]:GetCurrentEra())..'.')
  return id
end

local function syncUnitFriendRecord(p,id,unit)
  if not unit or not id then return end
  local unitID=unit:GetID()
  save.SetValue(unitFriendField(p,unitID,'NAME'),getr(p,id,'NAME','Old Friend'))
  save.SetValue(unitFriendField(p,unitID,'TAG'),getr(p,id,'TAG',''))
  save.SetValue(unitFriendField(p,unitID,'ALIASES'),getr(p,id,'ALIASES',''))
  save.SetValue(unitFriendField(p,unitID,'BORN'),getr(p,id,'BORN',Game.GetGameTurn()))
  save.SetValue(unitFriendField(p,unitID,'ERA'),getr(p,id,'BORN_ERA',Players[p]:GetCurrentEra()))
  local profileYears=tonumber(getr(p,id,'YEARS',0)) or 0
  local cachedYears=tonumber(save.GetValue(unitFriendField(p,unitID,'YEARS'))) or 0
  local years=math.min(6,math.max(profileYears,cachedYears))
  setr(p,id,'YEARS',years); save.SetValue(unitFriendField(p,unitID,'YEARS'),years)
  for index,promotion in ipairs(YEARS) do unit:SetHasPromotion(promotion,index == years) end
  save.SetValue(unitFriendField(p,unitID,'UPGRADES'),tonumber(getr(p,id,'UPGRADES',0)) or 0)
  save.SetValue(unitFriendField(p,unitID,'LINEAGE'),getr(p,id,'LINEAGE',''))
  save.SetValue(unitFriendField(p,unitID,'ACTIVE'),1)
end

local function reconcileMappedUpgrade(p,unit)
  if unit:GetUnitType() == OLD_FRIEND then return end
  local id=friendID(p,unit:GetID()); if not id then return end
  local unitType=GameInfo.Units[unit:GetUnitType()].Type
  local lineage=getr(p,id,'LINEAGE','')
  if lineageContains(lineage,'UNIT_COMMONWEALTH_OLD_FRIEND') then
    local pendingTurn=tonumber(getr(p,id,'PENDING_DEATH_TURN',-1000)) or -1000
    if pendingTurn <= -1000 then pendingTurn=Game.GetGameTurn() end
    if recordLedgerUpgrade(p,id,unit:GetUnitType(),pendingTurn) then
      syncUnitFriendRecord(p,id,unit)
      print('CommonwealthFriends: reconciled missing upgrade record for '..getr(p,id,'NAME','Old Friend')..' as '..unitType)
    end
    return
  end
end

local function finalizePendingDeaths(p)
  local player=Players[p]; local count=tonumber(save.GetValue('COY2_COUNT_'..p)) or 0; local turn=Game.GetGameTurn()
  for id=1,count do
    local pendingTurn=tonumber(getr(p,id,'PENDING_DEATH_TURN',-1000)) or -1000
    if pendingTurn > -1000 and turn > pendingTurn then
      local unitID=tonumber(getr(p,id,'CURRENT_UNIT',-1)) or -1
      local unit=player:GetUnitByID(unitID)
      if not unit or not unit:IsHasPromotion(SINCE) or friendID(p,unitID) ~= id then
        local x=tonumber(getr(p,id,'PENDING_DEATH_X',-1)) or -1; local y=tonumber(getr(p,id,'PENDING_DEATH_Y',-1)) or -1
        setr(p,id,'STATUS','Offline'); setr(p,id,'DEATH_TURN',pendingTurn); setr(p,id,'DEATH_X',x); setr(p,id,'DEATH_Y',y)
        setr(p,id,'LOCATION','Tile '..x..', '..y); setr(p,id,'CURRENT_UNIT',-1)
        appendTimeline(p,id,getr(p,id,'NAME','An Old Friend')..' went offline at tile '..x..', '..y..'.',pendingTurn)
      end
      setr(p,id,'PENDING_DEATH_TURN',-1000)
    end
  end
end

local function updateUnitRecord(p, unit)
  local id = registerFriend(unit); if not id then return end
  local hp = unit:GetMaxHitPoints()-unit:GetDamage(); local oldLow = tonumber(getr(p,id,'LOW_HP',hp)) or hp
  if hp < oldLow then
    setr(p,id,'LOW_HP',hp)
    if hp <= 10 and oldLow > 10 then
      appendTimeline(p,id,getr(p,id,'NAME','An Old Friend')..' survived with only '..hp..' HP.')
      markFriendEvent(p,id,'near_death')
    end
  end
  setr(p,id,'LEVEL',unit:GetLevel()); setr(p,id,'XP',unit:GetExperience())
  setr(p,id,'CURRENT_UNIT',unit:GetID()); setr(p,id,'CURRENT_TYPE',unit:GetUnitType())
  setr(p,id,'LOCATION',plotLocation(unit:GetPlot()))
  local era = Players[p]:GetCurrentEra(); local lastEra = tonumber(getr(p,id,'LAST_ERA',era)) or era
  if era > lastEra then
    local years = math.min(6,(tonumber(getr(p,id,'YEARS',0)) or 0)+1)
    setr(p,id,'YEARS',years); setr(p,id,'ERAS',(tonumber(getr(p,id,'ERAS',0)) or 0)+1)
    setr(p,id,'MEMORIES',(tonumber(getr(p,id,'MEMORIES',0)) or 0)+1); setr(p,id,'LAST_ERA',era)
    appendTimeline(p,id,getr(p,id,'NAME','An Old Friend')..' survived into the '..eraName(era)..' and gained Years Together '..years..'.')
    markFriendEvent(p,id,'new_era')
  end
  local capital = Players[p]:GetCapitalCity()
  local distance = capital and Map.PlotDistance(unit:GetX(),unit:GetY(),capital:GetX(),capital:GetY()) or 0
  setr(p,id,'STATUS',distance > 12 and 'Away From Home' or 'Still With Us')
  syncUnitFriendRecord(p,id,unit)
end

local function pairKey(p,a,b)
  if a > b then a,b = b,a end
  return 'COY2_PAIR_'..p..'_'..a..'_'..b
end
local function conversationPairKey(p,a,b,suffix)
  if a > b then a,b = b,a end
  return 'COY2_CONV_'..p..'_'..a..'_'..b..'_'..suffix
end
local function globalConversationKey(p,lineID)
  return 'COY2_CONV_GLOBAL_'..p..'_LAST_'..tostring(lineID)
end
local function globalConversationUseKey(p,lineID)
  return 'COY2_CONV_GLOBAL_'..p..'_USES_'..tostring(lineID)
end
local function globalConversationUses(p,lineID)
  local uses=tonumber(save.GetValue(globalConversationUseKey(p,lineID)))
  if uses ~= nil then return math.max(0,uses) end
  -- Existing campaigns already have LAST keys. Count those as one use so the
  -- new shuffle bag immediately remembers dialogue heard before this update.
  return save.GetValue(globalConversationKey(p,lineID)) ~= nil and 1 or 0
end
local function leastUsedConversationLines(p,lines)
  local result={}; local least=nil
  for _,line in ipairs(lines) do
    local uses=globalConversationUses(p,line.id)
    if least == nil or uses < least then
      least=uses; result={line}
    elseif uses == least then
      result[#result+1]=line
    end
  end
  return result
end
local function conversationsEnabled(p)
  return tonumber(save.GetValue('COY2_CONV_ENABLED_'..p) or 1) ~= 0
end
local function nearBedroom(unit)
  local plot=unit and unit:GetPlot(); if not plot then return false end
  local function hasBedroom(checkPlot)
    local city=checkPlot and checkPlot:GetPlotCity()
    return city and (city:GetNumRealBuilding(BEDROOM) > 0 or city:GetNumFreeBuilding(BEDROOM) > 0)
  end
  if hasBedroom(plot) then return true end
  for direction=0,DirectionTypes.NUM_DIRECTION_TYPES-1 do
    if hasBedroom(Map.PlotDirection(plot:GetX(),plot:GetY(),direction)) then return true end
  end
  return false
end
local function pendingFriendEvent(p,id)
  local events=loadFriendEvents(p,id); local event=events[1]
  if event then return event.kind,event.turn,1 end
  return nil,-1000,nil
end
local function pendingPairEvent(p,a,b)
  local eventType=save.GetValue(conversationPairKey(p,a,b,'EVENT_TYPE')) or ''
  local eventTurn=tonumber(save.GetValue(conversationPairKey(p,a,b,'EVENT_TURN'))) or -1000
  local turn=Game.GetGameTurn()
  if eventType ~= '' and eventTurn <= turn and turn-eventTurn <= EVENT_LIFETIME then return eventType,eventTurn end
  if eventType ~= '' then
    save.SetValue(conversationPairKey(p,a,b,'EVENT_TYPE'),'')
    save.SetValue(conversationPairKey(p,a,b,'EVENT_TURN'),-1000)
  end
  return nil,-1000
end
local function unusedConversationLines(p,a,b,unitA,unitB,eventType)
  local eventLines,contextual,general = {}, {}, {}
  local turn=Game.GetGameTurn(); local eventPairHasUnused=false
  local active=(tonumber(save.GetValue('COY_'..p..'_ACTIVE')) or 0) > 0
  local bedroom=nearBedroom(unitA) or nearBedroom(unitB)
  local scarred=(unitA:GetMaxHitPoints()-unitA:GetDamage() <= 25) or (unitB:GetMaxHitPoints()-unitB:GetDamage() <= 25)
  local veteran=math.min(tonumber(getr(p,a,'YEARS',0)) or 0,tonumber(getr(p,b,'YEARS',0)) or 0) >= 3
  local away=getr(p,a,'STATUS','') == 'Away From Home' or getr(p,b,'STATUS','') == 'Away From Home'
  for _,line in ipairs(conversationLines) do
    local pairUnused=tonumber(save.GetValue(conversationPairKey(p,a,b,'USED_'..line.id)) or 0) == 0
    local globalLast=tonumber(save.GetValue(globalConversationKey(p,line.id))) or -1000
    if globalLast > turn then
      -- OpenSaveData persists across loading an earlier save. Preserve the
      -- fact that the line was heard, but clamp its timestamp to this timeline.
      globalLast=turn; save.SetValue(globalConversationKey(p,line.id),globalLast)
    end
    if eventType and line.kind == eventType and pairUnused then eventPairHasUnused=true end
    if pairUnused and turn-globalLast >= GLOBAL_LINE_REPEAT_COOLDOWN then
      if eventType and line.kind == eventType then eventLines[#eventLines+1]=line
      elseif line.kind == 'general' then general[#general+1]=line
      elseif (line.kind == 'reminiscence' and active) or (line.kind == 'bedroom' and bedroom)
        or (line.kind == 'scarred' and scarred) or (line.kind == 'veteran' and veteran)
        or (line.kind == 'away' and away) then contextual[#contextual+1]=line end
    end
  end
  -- Once this pair has heard every line for a recurring event category, use
  -- the globally least-recent exchange. If another pair used the remaining
  -- unseen lines recently, keep the event queued instead of repeating them.
  if eventType and #eventLines == 0 and not eventPairHasUnused then
    local oldestLine=nil; local oldestTurn=math.huge
    for _,line in ipairs(conversationLines) do if line.kind == eventType then
      local globalLast=tonumber(save.GetValue(globalConversationKey(p,line.id))) or -1000
      if globalLast < oldestTurn then oldestLine,oldestTurn=line,globalLast end
    end end
    if oldestLine then eventLines[1]=oldestLine end
  end
  -- A queued event with every suitable line inside the global repeat cooldown
  -- remains queued, but must not silence ordinary conversations in the meantime.
  if #eventLines > 0 then return leastUsedConversationLines(p,eventLines),active,bedroom,eventType end
  local available=#contextual > 0 and contextual or general
  return leastUsedConversationLines(p,available),active,bedroom,nil
end
local function expandConversationLine(text,p,selfName,otherName,location,selfUnit,otherUnit)
  local result=tostring(text or '')
  local replacements={
    SELF=selfName,OTHER=otherName,LOCATION=location,
    ERA=eraName(Players[p]:GetCurrentEra()),FORM=unitName(selfUnit:GetUnitType()),
    OTHER_FORM=unitName(otherUnit:GetUnitType())
  }
  for token,value in pairs(replacements) do result=result:gsub('{'..token..'}',function() return value end) end
  return result
end
local function tryConversation(p,pairs)
  local player=Players[p]
  if not player:IsHuman() or not conversationsEnabled(p) or #pairs == 0 then return end
  local turn=Game.GetGameTurn(); local lastGlobal=tonumber(save.GetValue('COY2_CONV_LAST_'..p)) or -1000
  if lastGlobal > turn then
    lastGlobal=-1000; save.SetValue('COY2_CONV_LAST_'..p,lastGlobal)
  end
  if turn-lastGlobal < GLOBAL_CONVERSATION_COOLDOWN then return end
  local successes,eventSuccesses,evaluated={},{},{}
  for _,pair in ipairs(pairs) do
    local lastPair=tonumber(save.GetValue(conversationPairKey(p,pair.a,pair.b,'LAST'))) or -1000
    if lastPair > turn then
      lastPair=-1000; save.SetValue(conversationPairKey(p,pair.a,pair.b,'LAST'),lastPair)
    end
    if turn-lastPair >= PAIR_CONVERSATION_COOLDOWN then
      local lines,active,bedroom,eventType=unusedConversationLines(p,pair.a,pair.b,pair.unitA,pair.unitB,pair.eventType)
      local misses=math.max(0,tonumber(save.GetValue(conversationPairKey(p,pair.a,pair.b,'MISSES'))) or 0)
      local chance=(eventType and EVENT_CONVERSATION_CHANCE or
        (BASE_CONVERSATION_CHANCE+(active and REMINISCENCE_CHANCE_BONUS or 0)+(bedroom and BEDROOM_CHANCE_BONUS or 0)))
        +math.min(eventType and 24 or 30,misses*(eventType and 8 or 10))
      local succeeded=#lines > 0 and (misses >= CONVERSATION_PITY_LIMIT
        or Game.Rand(100,'Commonwealth adjacent Old Friends conversation') < chance)
      if #lines > 0 then evaluated[#evaluated+1]={pair=pair,misses=misses} end
      if succeeded then
        local success={pair=pair,lines=lines,eventType=eventType}
        if eventType then eventSuccesses[#eventSuccesses+1]=success else successes[#successes+1]=success end
      elseif eventType then
        -- A failed special-event roll must not silence ordinary chatter for
        -- the same otherwise-eligible adjacent pair.
        local normalLines,normalActive,normalBedroom=unusedConversationLines(p,pair.a,pair.b,pair.unitA,pair.unitB,nil)
        local normalChance=BASE_CONVERSATION_CHANCE+(normalActive and REMINISCENCE_CHANCE_BONUS or 0)
          +(normalBedroom and BEDROOM_CHANCE_BONUS or 0)+math.min(30,misses*10)
        if #normalLines > 0 and (misses >= CONVERSATION_PITY_LIMIT
          or Game.Rand(100,'Commonwealth adjacent Old Friends fallback conversation') < normalChance) then
          successes[#successes+1]={pair=pair,lines=normalLines,eventType=nil}
        end
      end
    end
  end
  -- Successful special conversations retain priority, but a failed special
  -- roll no longer discards successful ordinary conversations this turn.
  if #eventSuccesses > 0 then successes=eventSuccesses end
  if #successes == 0 then
    for _,entry in ipairs(evaluated) do
      save.SetValue(conversationPairKey(p,entry.pair.a,entry.pair.b,'MISSES'),math.min(CONVERSATION_PITY_LIMIT,entry.misses+1))
    end
    return
  end
  local result=successes[Game.Rand(#successes,'Commonwealth conversation pair')+1]
  local pair=result.pair; local line=result.lines[Game.Rand(#result.lines,'Commonwealth conversation line')+1]
  for _,entry in ipairs(evaluated) do
    local selected=(entry.pair.a == pair.a and entry.pair.b == pair.b) or (entry.pair.a == pair.b and entry.pair.b == pair.a)
    save.SetValue(conversationPairKey(p,entry.pair.a,entry.pair.b,'MISSES'),selected and 0 or math.min(CONVERSATION_PITY_LIMIT,entry.misses+1))
  end
  local nameA,tagA=getr(p,pair.a,'NAME','Old Friend'),getr(p,pair.a,'TAG','')
  local nameB,tagB=getr(p,pair.b,'NAME','Old Friend'),getr(p,pair.b,'TAG','')
  local location=plotLocation(pair.unitA:GetPlot())
  local lineA=expandConversationLine(line.a,p,nameA,nameB,location,pair.unitA,pair.unitB)
  local lineB=expandConversationLine(line.b,p,nameB,nameA,location,pair.unitB,pair.unitA)
  local previousGlobalUses=globalConversationUses(p,line.id)
  save.SetValue('COY2_CONV_LAST_'..p,turn)
  save.SetValue(conversationPairKey(p,pair.a,pair.b,'LAST'),turn)
  save.SetValue(conversationPairKey(p,pair.a,pair.b,'USED_'..line.id),1)
  save.SetValue(globalConversationKey(p,line.id),turn)
  save.SetValue(globalConversationUseKey(p,line.id),previousGlobalUses+1)
  if result.eventType then
    if pair.eventFriend then clearFriendEvent(p,pair.eventFriend,pair.eventIndex)
    else
      save.SetValue(conversationPairKey(p,pair.a,pair.b,'EVENT_TYPE'),'')
      save.SetValue(conversationPairKey(p,pair.a,pair.b,'EVENT_TURN'),-1000)
    end
  end
  setr(p,pair.a,'CONVERSATIONS',(tonumber(getr(p,pair.a,'CONVERSATIONS',0)) or 0)+1)
  setr(p,pair.b,'CONVERSATIONS',(tonumber(getr(p,pair.b,'CONVERSATIONS',0)) or 0)+1)
  appendTimeline(p,pair.a,'Shared a quiet conversation with '..nameB..' at '..location..'.')
  appendTimeline(p,pair.b,'Shared a quiet conversation with '..nameA..' at '..location..'.')
  print('CommonwealthFriends: showed conversation '..line.id..' for '..nameA..' and '..nameB..' on turn '..turn)
  LuaEvents.CommonwealthConversationShown(p,nameA,tagA,lineA,nameB,tagB,lineB,location,line.kind or result.eventType or 'general')
end
local function updateFriendships(p, units)
  local pairs={}; local turn=Game.GetGameTurn()
  for i=1,#units do for j=i+1,#units do
    if Map.PlotDistance(units[i]:GetX(),units[i]:GetY(),units[j]:GetX(),units[j]:GetY()) <= 1 then
      local a,b = registerFriend(units[i]),registerFriend(units[j])
      local key = pairKey(p,a,b); save.SetValue(key,(tonumber(save.GetValue(key)) or 0)+1)
      local lastAdjacent=tonumber(save.GetValue(conversationPairKey(p,a,b,'ADJ_LAST'))) or -1000
      if lastAdjacent > turn then
        lastAdjacent=-1000; save.SetValue(conversationPairKey(p,a,b,'ADJ_LAST'),lastAdjacent)
      end
      if lastAdjacent > -1000 and turn-lastAdjacent >= 15 then
        save.SetValue(conversationPairKey(p,a,b,'EVENT_TYPE'),'reunion')
        save.SetValue(conversationPairKey(p,a,b,'EVENT_TURN'),turn)
      end
      save.SetValue(conversationPairKey(p,a,b,'ADJ_LAST'),turn)
      local eventType,eventTurn=pendingPairEvent(p,a,b); local eventFriend,eventIndex=nil,nil
      if not eventType then
        local eventA,turnA,indexA=pendingFriendEvent(p,a); local eventB,turnB,indexB=pendingFriendEvent(p,b)
        if eventA or eventB then
          if eventB and (not eventA or turnB < turnA) then eventType,eventTurn,eventFriend,eventIndex=eventB,turnB,b,indexB
          else eventType,eventTurn,eventFriend,eventIndex=eventA,turnA,a,indexA end
        end
      end
      local pair={a=a,b=b,unitA=units[i],unitB=units[j],eventType=eventType,eventFriend=eventFriend,eventIndex=eventIndex}
      if eventFriend == b then pair.a,pair.b=b,a; pair.unitA,pair.unitB=units[j],units[i] end
      pairs[#pairs+1]=pair
    end
  end end
  return pairs
end

local function friendsTurn(p,advanceTurn)
  local player=Players[p]; if not isCommonwealth(player) then return end
  finalizePendingDeaths(p)
  local units={}; local active=tonumber(save.GetValue('COY_'..p..'_ACTIVE')) or 0
  for unit in player:Units() do if unit:IsHasPromotion(SINCE) then
    registerFriend(unit); reconcileMappedUpgrade(p,unit); updateUnitRecord(p,unit)
    if friendID(p,unit:GetID()) then units[#units+1]=unit end
  end end
  if advanceTurn then
    local previousActive=tonumber(save.GetValue('COY2_CONV_ACTIVE_'..p)) or 0
    if active > 0 and previousActive == 0 then for _,unit in ipairs(units) do markFriendEvent(p,registerFriend(unit),'reminiscence') end end
    save.SetValue('COY2_CONV_ACTIVE_'..p,active)
    local pairs=updateFriendships(p,units)
    local trace=tostring(#units)..':'..tostring(#pairs)..':'..(conversationsEnabled(p) and 'on' or 'off')
    if trace ~= lastConversationTrace then
      print('CommonwealthFriends: conversation eligibility changed - '..#units..' lineage(s), '..#pairs..' adjacent pair(s), dialogue '..(conversationsEnabled(p) and 'enabled' or 'disabled'))
      lastConversationTrace=trace
    end
    tryConversation(p,pairs)
  end
end
GameEvents.PlayerDoTurn.Add(function(p) friendsTurn(p,true) end)

GameEvents.UnitSetXY.Add(function(p,unitID,x,y)
  local player=Players[p]; if not isCommonwealth(player) then return end
  local unit=player:GetUnitByID(unitID); if not unit or not unit:IsHasPromotion(SINCE) then return end
  if x < 0 or y < 0 or not unit:GetPlot() then return end
  registerFriend(unit); reconcileMappedUpgrade(p,unit)
  local id=friendID(p,unitID); if not id then return end
  local oldX,oldY=tonumber(getr(p,id,'X',x)),tonumber(getr(p,id,'Y',y))
  if oldX ~= x or oldY ~= y then setr(p,id,'DISTANCE',(tonumber(getr(p,id,'DISTANCE',0)) or 0)+1) end
  setr(p,id,'X',x); setr(p,id,'Y',y); setr(p,id,'LOCATION',plotLocation(unit:GetPlot()))
end)

GameEvents.UnitCreated.Add(function(p,unitID)
  local player=Players[p]; local unit=player and player:GetUnitByID(unitID)
  if isCommonwealth(player) and unit and unit:IsHasPromotion(SINCE) then
    registerFriend(unit); reconcileMappedUpgrade(p,unit)
  end
end)

if GameEvents.UnitUpgraded then GameEvents.UnitUpgraded.Add(function(p,oldID,newID,bGoodyHut)
  local player=Players[p]; if not isCommonwealth(player) then return end
  local oldUnit,newUnit=player:GetUnitByID(oldID),player:GetUnitByID(newID)
  -- CP invokes UnitUpgraded before convert() transfers promotions and identity
  -- to the replacement. Both paid and ruins upgrades must therefore be
  -- authenticated from the still-live old unit and its exact archive mapping.
  if not oldUnit or not oldUnit:IsHasPromotion(SINCE) then return end
  local id=friendID(p,oldID) or registerFriend(oldUnit)
  if not id or not newUnit then return end
  setFriendID(p,oldID,nil); setFriendID(p,newID,id)
  local unitType=GameInfo.Units[newUnit:GetUnitType()].Type
  recordLedgerUpgrade(p,id,newUnit:GetUnitType())
  setr(p,id,'CURRENT_UNIT',newID); setr(p,id,'CURRENT_TYPE',newUnit:GetUnitType())
  setr(p,id,'STATUS','Still With Us'); setr(p,id,'DEATH_TURN',-1)
  newUnit:SetName(getr(p,id,'NAME','Old Friend')..' - '..getr(p,id,'TAG',''))
  syncUnitFriendRecord(p,id,newUnit)
  if CommonwealthAddMemories then CommonwealthAddMemories(p,4,'an Old Friend was upgraded') end
  print('CommonwealthFriends: transferred profile '..id..' from unit '..oldID..' to '..newID..' as '..unitType)
end) end

if Events.RunCombatSim then Events.RunCombatSim.Add(function(ap,au,_,_,_,dp,du)
  local attacker=Players[ap] and Players[ap]:GetUnitByID(au); local defender=Players[dp] and Players[dp]:GetUnitByID(du)
  if attacker and attacker:IsHasPromotion(SINCE) then combatCredit[dp..'_'..du]={p=ap,id=registerFriend(attacker)} end
  if defender and defender:IsHasPromotion(SINCE) then combatCredit[ap..'_'..au]={p=dp,id=registerFriend(defender)} end
end) end
if Events.EndCombatSim then Events.EndCombatSim.Add(function(ap,au,_,af,amax,dp,du,_,df,dmax)
  local seen={}
  for _,data in ipairs({{ap,au,af,amax},{dp,du,df,dmax}}) do
    local p,unitID,finalDamage,maxHP=data[1],data[2],data[3],data[4]; local unit=Players[p] and Players[p]:GetUnitByID(unitID)
    if unit and unit:IsHasPromotion(SINCE) then
      local id=registerFriend(unit); if not seen[id] then setr(p,id,'BATTLES',(tonumber(getr(p,id,'BATTLES',0)) or 0)+1); seen[id]=true end
      if type(maxHP)=='number' and type(finalDamage)=='number' then
        local hp=maxHP-finalDamage; local oldLow=tonumber(getr(p,id,'LOW_HP',hp)) or hp
        if hp < oldLow then
          setr(p,id,'LOW_HP',hp)
          if hp <= 10 and oldLow > 10 then
            appendTimeline(p,id,getr(p,id,'NAME','An Old Friend')..' survived a battle with only '..hp..' HP.')
            markFriendEvent(p,id,'near_death')
          end
        end
      end
    end
  end
end) end

if GameEvents.UnitPrekill then GameEvents.UnitPrekill.Add(function(killedP,killedID,_,x,y,_,killerP)
  local credit=combatCredit[killedP..'_'..killedID]
  if credit and killerP == credit.p then
    setr(credit.p,credit.id,'KILLS',(tonumber(getr(credit.p,credit.id,'KILLS',0)) or 0)+1)
    appendTimeline(credit.p,credit.id,getr(credit.p,credit.id,'NAME','An Old Friend')..' defeated an enemy near tile '..x..', '..y..'.')
    markFriendEvent(credit.p,credit.id,'victory')
  end
  combatCredit[killedP..'_'..killedID]=nil
  local player=Players[killedP]; if not isCommonwealth(player) then return end
  local id=friendID(killedP,killedID)
  if not id then return end
  setr(killedP,id,'PENDING_DEATH_TURN',Game.GetGameTurn())
  setr(killedP,id,'PENDING_DEATH_X',x); setr(killedP,id,'PENDING_DEATH_Y',y)
  setr(killedP,id,'PENDING_OLD_UNIT',killedID)
  save.SetValue('COY2_PENDING_UNIT_'..killedP..'_'..killedID,id)
  setFriendID(killedP,killedID,nil)
  save.SetValue(unitFriendField(killedP,killedID,'ACTIVE'),0)
end) end

local function epithet(p,id)
  if getr(p,id,'STATUS','') == 'Offline' then return 'Last Online' end
  if (tonumber(getr(p,id,'YEARS',0)) or 0) >= 6 then return 'The One Who Never Logged Off' end
  if (tonumber(getr(p,id,'KILLS',0)) or 0) >= 10 then return 'The Quiet Carry' end
  if (tonumber(getr(p,id,'DISTANCE',0)) or 0) >= 50 then return 'Beyond the Old Map' end
  if (tonumber(getr(p,id,'LOW_HP',100)) or 100) <= 10 then return 'Last One Standing' end
  if id == 1 then return 'The First One Online' end
  return 'Since the Beginning'
end
local function closestFriend(p,id,count)
  local best,bestTurns=nil,0
  for other=1,count do if other~=id then
    local turns=tonumber(save.GetValue(pairKey(p,id,other))) or 0
    if turns>bestTurns then best,bestTurns=other,turns end
  end end
  return best and getr(p,best,'NAME','Unknown') or 'None yet',bestTurns
end
local function displayLineage(raw)
  local names={}
  for value in string.gmatch(raw or '','[^|]+') do local row=GameInfo.Units[value]; names[#names+1]=row and Locale.ConvertTextKey(row.Description) or value end
  return table.concat(names,'  [ICON_ARROW_RIGHT]  ')
end
local function timelineEventIcon(text)
  text=string.lower(text or '')
  if string.find(text,'became ',1,true) then return '[ICON_ARROW_RIGHT]' end
  if string.find(text,'survived into',1,true) then return '[ICON_CULTURE]' end
  if string.find(text,'defeated ',1,true) then return '[ICON_STRENGTH]' end
  if string.find(text,'survived with',1,true) or string.find(text,'survived a battle',1,true) then return '[ICON_HEALTH]' end
  if string.find(text,'conversation with',1,true) then return '[ICON_GREAT_PEOPLE]' end
  if string.find(text,'went offline',1,true) then return '[ICON_RAZING]' end
  if string.find(text,'joined the commonwealth',1,true) then return '[ICON_CAPITAL]' end
  return '[ICON_BULLET]'
end

LuaEvents.CommonwealthAdvancedLedgerRequest.Add(function(p)
  local player=Players[p]; if not isCommonwealth(player) then LuaEvents.CommonwealthAdvancedLedgerResponse(p,{}); return end
  friendsTurn(p,false)
  local rows={}; local count=tonumber(save.GetValue('COY2_COUNT_'..p)) or 0
  for id=1,count do
    local name,tag=getr(p,id,'NAME','Old Friend'),getr(p,id,'TAG','')
    local aliases=getr(p,id,'ALIASES','')
    local tributeAliases=CommonwealthTributeAliases and CommonwealthTributeAliases(name,tag)
    if tributeAliases then aliases=tributeAliases; setr(p,id,'ALIASES',aliases) end
    local closest,together=closestFriend(p,id,count); local timeline={}; local tc=tonumber(getr(p,id,'TIMELINE_COUNT',0)) or 0
    -- Show the newest memories first so recent upgrades remain visible in the
    -- Ledger's compact timeline viewport.
    for i=tc,1,-1 do
      local eventText=getr(p,id,'TIME_'..i..'_TEXT','')
      timeline[#timeline+1]=timelineEventIcon(eventText)..'  [COLOR_GREY]Turn '..getr(p,id,'TIME_'..i..'_TURN',0)..'[ENDCOLOR][NEWLINE]'..eventText
    end
    local currentType=tonumber(getr(p,id,'CURRENT_TYPE',-1)) or -1
    rows[#rows+1]={id=id,name=name,tag=tag,aliases=aliases,epithet=epithet(p,id),status=getr(p,id,'STATUS','Offline'),
      form=currentType>=0 and unitName(currentType) or 'Unknown',bornEra=eraName(tonumber(getr(p,id,'BORN_ERA',0)) or 0),bornTurn=tonumber(getr(p,id,'BORN',0)) or 0,
      years=tonumber(getr(p,id,'YEARS',0)) or 0,eras=tonumber(getr(p,id,'ERAS',0)) or 0,level=tonumber(getr(p,id,'LEVEL',1)) or 1,xp=tonumber(getr(p,id,'XP',0)) or 0,
      battles=tonumber(getr(p,id,'BATTLES',0)) or 0,kills=tonumber(getr(p,id,'KILLS',0)) or 0,distance=tonumber(getr(p,id,'DISTANCE',0)) or 0,
      upgrades=tonumber(getr(p,id,'UPGRADES',0)) or 0,lowHP=tonumber(getr(p,id,'LOW_HP',100)) or 100,memories=tonumber(getr(p,id,'MEMORIES',0)) or 0,conversations=tonumber(getr(p,id,'CONVERSATIONS',0)) or 0,
      closest=closest,together=together,location=getr(p,id,'LOCATION','Unknown'),lineage=displayLineage(getr(p,id,'LINEAGE','')),timeline=table.concat(timeline,'[NEWLINE]'),
      deathTurn=tonumber(getr(p,id,'DEATH_TURN',-1)) or -1,currentUnit=tonumber(getr(p,id,'CURRENT_UNIT',-1)) or -1}
  end
  LuaEvents.CommonwealthAdvancedLedgerResponse(p,rows)
end)

LuaEvents.CommonwealthLocateFriend.Add(function(p,id)
  local unitID=tonumber(getr(p,id,'CURRENT_UNIT',-1)) or -1; local unit=Players[p] and Players[p]:GetUnitByID(unitID)
  if unit then UI.LookAt(unit:GetPlot(),0); UI.SelectUnit(unit) end
end)

LuaEvents.CommonwealthConversationStatusRequest.Add(function(p)
  LuaEvents.CommonwealthConversationStatusResponse(p,conversationsEnabled(p) and 1 or 0)
end)
LuaEvents.CommonwealthConversationToggle.Add(function(p,enabled)
  if isCommonwealth(Players[p]) then
    save.SetValue('COY2_CONV_ENABLED_'..p,tonumber(enabled) == 1 and 1 or 0)
    LuaEvents.CommonwealthConversationStatusResponse(p,conversationsEnabled(p) and 1 or 0)
  end
end)
