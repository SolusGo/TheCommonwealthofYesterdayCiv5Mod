-- Persistent Old Friends archive and telemetry for the advanced Ledger.
print('CommonwealthFriends loaded')

local CIV = GameInfoTypes.CIVILIZATION_COMMONWEALTH_YESTERDAY
local SINCE = GameInfoTypes.PROMOTION_COMMONWEALTH_SINCE_BEGINNING
local BEDROOM = GameInfoTypes.BUILDING_COMMONWEALTH_BEDROOM
local save = Modding.OpenSaveData()
local combatCredit = {}
local conversationLines = {
  {id='river', kind='general', a='Remember when the map ended at the river?', b='It still does. We just learned how to cross it.'},
  {id='online', kind='general', a='I thought everyone else had logged off.', b='Not everyone.'},
  {id='save', kind='general', a='Do you still have the old save?', b='Of course. I could never bring myself to overwrite it.'},
  {id='sunrise', kind='general', a='We said one more turn.', b='We always did. Then the sun came up.'},
  {id='quiet', kind='general', a='It is quieter than it used to be.', b='Maybe. But you are still here.'},
  {id='quest', kind='general', a='Do you remember what we were supposed to be doing?', b='No. That was never really the point.'},
  {id='joke', kind='general', a='You are going to tell the same joke again, right?', b='You laughed the first hundred times.'},
  {id='road', kind='general', a='Every road looks different now.', b='They all still lead home eventually.'},
  {id='lobby', kind='general', a='The lobby used to fill up so quickly.', b='It only ever needed two of us.'},
  {id='pause', kind='general', a='Are we lost?', b='No. We are exploring without a quest marker.'},
  {id='bedroom_desk', kind='bedroom', a='That desk looks smaller than I remember.', b='We were smaller too.'},
  {id='bedroom_screen', kind='bedroom', a='I can almost hear the old computer starting up.', b='Give it a minute. It always took a while.'},
  {id='bedroom_light', kind='bedroom', a='The light through that window has not changed.', b='Maybe that is why we kept coming back.'},
  {id='reminiscence_moment', kind='reminiscence', a='This feels exactly like it used to.', b='Do not look too closely. Just let it.'},
  {id='reminiscence_time', kind='reminiscence', a='How long do you think this moment will last?', b='Long enough to remember it.'},
  {id='scar', kind='scarred', a='You nearly logged off back there.', b='Nearly is doing a lot of work in that sentence.'},
  {id='scar_save', kind='scarred', a='You had me worried.', b='I knew you would keep the save running.'},
  {id='veteran_eras', kind='veteran', a='How many eras has it been now?', b='Enough that I have stopped counting.'},
  {id='veteran_forms', kind='veteran', a='You look different again.', b='New armour. Same account.'},
  {id='away_map', kind='away', a='We are a long way from Home.', b='Good thing we brought some of it with us.'},
  {id='away_return', kind='away', a='Think we will find the way back?', b='We always have before.'}
}
local function isCommonwealth(player)
  return player and player:IsAlive() and player:GetCivilizationType() == CIV
end
local function rkey(p, id, field) return 'COY2_REC_'..p..'_'..id..'_'..field end
local function mkey(p, unitID) return 'COY2_MAP_'..p..'_'..unitID end
local function getr(p, id, field, default)
  local value = save.GetValue(rkey(p,id,field)); if value == nil then return default end; return value
end
local function setr(p, id, field, value) save.SetValue(rkey(p,id,field), value) end
local function friendID(p, unitID)
  local id = tonumber(save.GetValue(mkey(p,unitID))) or 0
  return id > 0 and id or nil
end
local function setFriendID(p, unitID, id) save.SetValue(mkey(p,unitID), id or -1) end
local function eraName(era)
  local row = GameInfo.Eras[era]; return row and Locale.ConvertTextKey(row.Description) or ('Era '..tostring(era))
end
local function unitName(unitType)
  local row = GameInfo.Units[unitType]; return row and Locale.ConvertTextKey(row.Description) or 'Unknown Unit'
end
local function appendTimeline(p, id, text)
  local count = tonumber(getr(p,id,'TIMELINE_COUNT',0)) or 0
  if count >= 30 then return end
  count = count + 1; setr(p,id,'TIMELINE_COUNT',count)
  setr(p,id,'TIME_'..count..'_TURN',Game.GetGameTurn()); setr(p,id,'TIME_'..count..'_TEXT',text)
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

local function registerFriend(unit)
  if not unit or not unit:IsHasPromotion(SINCE) then return nil end
  local p, unitID = unit:GetOwner(), unit:GetID()
  local id = friendID(p,unitID)
  if id then return id end
  local nextID = tonumber(save.GetValue('COY2_COUNT_'..p)) or 0
  id = nextID + 1; save.SetValue('COY2_COUNT_'..p,id); setFriendID(p,unitID,id)
  local legacyPrefix = 'FRIEND_'..p..'_'..unitID..'_'
  local name = save.GetValue(legacyPrefix..'NAME')
  local tag = save.GetValue(legacyPrefix..'TAG')
  local aliases = save.GetValue(legacyPrefix..'ALIASES') or ''
  if not name or not tag then name,tag,aliases = CommonwealthChooseFriendIdentity(p) end
  local unitType = unit:GetUnitType()
  setr(p,id,'NAME',name); setr(p,id,'TAG',tag); setr(p,id,'ALIASES',aliases); setr(p,id,'BORN',Game.GetGameTurn())
  setr(p,id,'BORN_ERA',Players[p]:GetCurrentEra()); setr(p,id,'LAST_ERA',Players[p]:GetCurrentEra())
  setr(p,id,'YEARS',tonumber(save.GetValue(legacyPrefix..'YEARS')) or 0)
  setr(p,id,'ERAS',tonumber(save.GetValue(legacyPrefix..'ERAS')) or 0)
  setr(p,id,'BATTLES',0); setr(p,id,'KILLS',0); setr(p,id,'DISTANCE',0); setr(p,id,'UPGRADES',0)
  setr(p,id,'LOW_HP',unit:GetMaxHitPoints()-unit:GetDamage()); setr(p,id,'MEMORIES',0)
  setr(p,id,'CURRENT_UNIT',unitID); setr(p,id,'CURRENT_TYPE',unitType); setr(p,id,'LINEAGE',GameInfo.Units[unitType].Type)
  setr(p,id,'STATUS','Still With Us'); setr(p,id,'X',unit:GetX()); setr(p,id,'Y',unit:GetY())
  setr(p,id,'LOCATION',plotLocation(unit:GetPlot())); setr(p,id,'LEVEL',unit:GetLevel()); setr(p,id,'XP',unit:GetExperience())
  unit:SetName(name..' - '..tag)
  appendTimeline(p,id,name..' joined the Commonwealth during the '..eraName(Players[p]:GetCurrentEra())..'.')
  return id
end

local function updateUnitRecord(p, unit)
  local id = registerFriend(unit); if not id then return end
  local hp = unit:GetMaxHitPoints()-unit:GetDamage(); local oldLow = tonumber(getr(p,id,'LOW_HP',hp)) or hp
  if hp < oldLow then
    setr(p,id,'LOW_HP',hp)
    if hp <= 10 and oldLow > 10 then appendTimeline(p,id,getr(p,id,'NAME','An Old Friend')..' survived with only '..hp..' HP.') end
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
  end
  local capital = Players[p]:GetCapitalCity()
  local distance = capital and Map.PlotDistance(unit:GetX(),unit:GetY(),capital:GetX(),capital:GetY()) or 0
  setr(p,id,'STATUS',distance > 12 and 'Away From Home' or 'Still With Us')
end

local function pairKey(p,a,b)
  if a > b then a,b = b,a end
  return 'COY2_PAIR_'..p..'_'..a..'_'..b
end
local function conversationPairKey(p,a,b,suffix)
  if a > b then a,b = b,a end
  return 'COY2_CONV_'..p..'_'..a..'_'..b..'_'..suffix
end
local function conversationsEnabled(p)
  return tonumber(save.GetValue('COY2_CONV_ENABLED_'..p) or 1) ~= 0
end
local function nearBedroom(unit)
  local plot=unit and unit:GetPlot(); if not plot then return false end
  local function hasBedroom(checkPlot)
    local city=checkPlot and checkPlot:GetPlotCity()
    return city and city:GetNumRealBuilding(BEDROOM) > 0
  end
  if hasBedroom(plot) then return true end
  for direction=0,DirectionTypes.NUM_DIRECTION_TYPES-1 do
    if hasBedroom(Map.PlotDirection(plot:GetX(),plot:GetY(),direction)) then return true end
  end
  return false
end
local function unusedConversationLines(p,a,b,unitA,unitB)
  local contextual, general = {}, {}
  local active=(tonumber(save.GetValue('COY_'..p..'_ACTIVE')) or 0) > 0
  local bedroom=nearBedroom(unitA) or nearBedroom(unitB)
  local scarred=(unitA:GetMaxHitPoints()-unitA:GetDamage() <= 25) or (unitB:GetMaxHitPoints()-unitB:GetDamage() <= 25)
  local veteran=math.min(tonumber(getr(p,a,'YEARS',0)) or 0,tonumber(getr(p,b,'YEARS',0)) or 0) >= 3
  local away=getr(p,a,'STATUS','') == 'Away From Home' or getr(p,b,'STATUS','') == 'Away From Home'
  for _,line in ipairs(conversationLines) do
    if tonumber(save.GetValue(conversationPairKey(p,a,b,'USED_'..line.id)) or 0) == 0 then
      if line.kind == 'general' then general[#general+1]=line
      elseif (line.kind == 'reminiscence' and active) or (line.kind == 'bedroom' and bedroom)
        or (line.kind == 'scarred' and scarred) or (line.kind == 'veteran' and veteran)
        or (line.kind == 'away' and away) then contextual[#contextual+1]=line end
    end
  end
  return #contextual > 0 and contextual or general,active,bedroom
end
local function tryConversation(p,pairs)
  local player=Players[p]
  if not player:IsHuman() or not conversationsEnabled(p) or #pairs == 0 then return end
  local turn=Game.GetGameTurn(); local lastGlobal=tonumber(save.GetValue('COY2_CONV_LAST_'..p)) or -1000
  if turn-lastGlobal < 12 then return end
  local successes={}
  for _,pair in ipairs(pairs) do
    local lastPair=tonumber(save.GetValue(conversationPairKey(p,pair.a,pair.b,'LAST'))) or -1000
    if turn-lastPair >= 25 then
      local lines,active,bedroom=unusedConversationLines(p,pair.a,pair.b,pair.unitA,pair.unitB)
      local chance=4+(active and 4 or 0)+(bedroom and 2 or 0)
      if #lines > 0 and Game.Rand(100,'Commonwealth adjacent Old Friends conversation') < chance then
        successes[#successes+1]={pair=pair,lines=lines}
      end
    end
  end
  if #successes == 0 then return end
  local result=successes[Game.Rand(#successes,'Commonwealth conversation pair')+1]
  local pair=result.pair; local line=result.lines[Game.Rand(#result.lines,'Commonwealth conversation line')+1]
  local nameA,tagA=getr(p,pair.a,'NAME','Old Friend'),getr(p,pair.a,'TAG','')
  local nameB,tagB=getr(p,pair.b,'NAME','Old Friend'),getr(p,pair.b,'TAG','')
  local location=plotLocation(pair.unitA:GetPlot())
  save.SetValue('COY2_CONV_LAST_'..p,turn)
  save.SetValue(conversationPairKey(p,pair.a,pair.b,'LAST'),turn)
  save.SetValue(conversationPairKey(p,pair.a,pair.b,'USED_'..line.id),1)
  setr(p,pair.a,'CONVERSATIONS',(tonumber(getr(p,pair.a,'CONVERSATIONS',0)) or 0)+1)
  setr(p,pair.b,'CONVERSATIONS',(tonumber(getr(p,pair.b,'CONVERSATIONS',0)) or 0)+1)
  appendTimeline(p,pair.a,'Shared a quiet conversation with '..nameB..' at '..location..'.')
  appendTimeline(p,pair.b,'Shared a quiet conversation with '..nameA..' at '..location..'.')
  LuaEvents.CommonwealthConversationShown(p,nameA,tagA,line.a,nameB,tagB,line.b,location)
end
local function updateFriendships(p, units)
  local pairs={}
  for i=1,#units do for j=i+1,#units do
    if Map.PlotDistance(units[i]:GetX(),units[i]:GetY(),units[j]:GetX(),units[j]:GetY()) <= 1 then
      local a,b = registerFriend(units[i]),registerFriend(units[j])
      local key = pairKey(p,a,b); save.SetValue(key,(tonumber(save.GetValue(key)) or 0)+1)
      pairs[#pairs+1]={a=a,b=b,unitA=units[i],unitB=units[j]}
    end
  end end
  return pairs
end

local function friendsTurn(p,allowConversation)
  local player=Players[p]; if not isCommonwealth(player) then return end
  local units={}
  for unit in player:Units() do if unit:IsHasPromotion(SINCE) then updateUnitRecord(p,unit); units[#units+1]=unit end end
  local pairs=updateFriendships(p,units)
  if allowConversation then tryConversation(p,pairs) end
end
GameEvents.PlayerDoTurn.Add(function(p) friendsTurn(p,true) end)

GameEvents.UnitSetXY.Add(function(p,unitID,x,y)
  local player=Players[p]; if not isCommonwealth(player) then return end
  local unit=player:GetUnitByID(unitID); if not unit or not unit:IsHasPromotion(SINCE) then return end
  local id=registerFriend(unit); local oldX,oldY=tonumber(getr(p,id,'X',x)),tonumber(getr(p,id,'Y',y))
  if oldX ~= x or oldY ~= y then setr(p,id,'DISTANCE',(tonumber(getr(p,id,'DISTANCE',0)) or 0)+1) end
  setr(p,id,'X',x); setr(p,id,'Y',y); setr(p,id,'LOCATION',plotLocation(unit:GetPlot()))
end)

GameEvents.UnitCreated.Add(function(p,unitID)
  local player=Players[p]; local unit=player and player:GetUnitByID(unitID)
  if isCommonwealth(player) and unit and unit:IsHasPromotion(SINCE) then registerFriend(unit) end
end)

if GameEvents.UnitUpgraded then GameEvents.UnitUpgraded.Add(function(p,oldID,newID)
  local player=Players[p]; if not isCommonwealth(player) then return end
  local oldUnit,newUnit=player:GetUnitByID(oldID),player:GetUnitByID(newID)
  local id=friendID(p,oldID) or (oldUnit and registerFriend(oldUnit))
  if not id or not newUnit or not newUnit:IsHasPromotion(SINCE) then return end
  setFriendID(p,oldID,nil); setFriendID(p,newID,id)
  local unitType=GameInfo.Units[newUnit:GetUnitType()].Type; local lineage=getr(p,id,'LINEAGE','')
  if not lineageContains(lineage,unitType) then setr(p,id,'LINEAGE',lineage..'|'..unitType) end
  setr(p,id,'UPGRADES',(tonumber(getr(p,id,'UPGRADES',0)) or 0)+1)
  setr(p,id,'MEMORIES',(tonumber(getr(p,id,'MEMORIES',0)) or 0)+4)
  setr(p,id,'CURRENT_UNIT',newID); setr(p,id,'CURRENT_TYPE',newUnit:GetUnitType())
  newUnit:SetName(getr(p,id,'NAME','Old Friend')..' - '..getr(p,id,'TAG',''))
  appendTimeline(p,id,getr(p,id,'NAME','An Old Friend')..' became '..unitName(newUnit:GetUnitType())..'.')
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
        local hp=maxHP-finalDamage; if hp < (tonumber(getr(p,id,'LOW_HP',hp)) or hp) then setr(p,id,'LOW_HP',hp) end
      end
    end
  end
end) end

if GameEvents.UnitPrekill then GameEvents.UnitPrekill.Add(function(killedP,killedID,_,x,y,_,killerP)
  local credit=combatCredit[killedP..'_'..killedID]
  if credit and killerP == credit.p then
    setr(credit.p,credit.id,'KILLS',(tonumber(getr(credit.p,credit.id,'KILLS',0)) or 0)+1)
    appendTimeline(credit.p,credit.id,getr(credit.p,credit.id,'NAME','An Old Friend')..' defeated an enemy near tile '..x..', '..y..'.')
  end
  combatCredit[killedP..'_'..killedID]=nil
  local player=Players[killedP]; if not isCommonwealth(player) then return end
  local unit=player:GetUnitByID(killedID); local id=friendID(killedP,killedID) or (unit and registerFriend(unit))
  if not id then return end
  setr(killedP,id,'STATUS','Offline'); setr(killedP,id,'DEATH_TURN',Game.GetGameTurn())
  setr(killedP,id,'DEATH_X',x); setr(killedP,id,'DEATH_Y',y); setr(killedP,id,'LOCATION','Tile '..x..', '..y)
  setr(killedP,id,'CURRENT_UNIT',-1); setFriendID(killedP,killedID,nil)
  appendTimeline(killedP,id,getr(killedP,id,'NAME','An Old Friend')..' went offline at tile '..x..', '..y..'.')
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

LuaEvents.CommonwealthAdvancedLedgerRequest.Add(function(p)
  local player=Players[p]; if not isCommonwealth(player) then LuaEvents.CommonwealthAdvancedLedgerResponse(p,{}); return end
  friendsTurn(p,false)
  local rows={}; local count=tonumber(save.GetValue('COY2_COUNT_'..p)) or 0
  for id=1,count do
    local closest,together=closestFriend(p,id,count); local timeline={}; local tc=tonumber(getr(p,id,'TIMELINE_COUNT',0)) or 0
    for i=1,tc do timeline[#timeline+1]='[COLOR_GREY]Turn '..getr(p,id,'TIME_'..i..'_TURN',0)..'[ENDCOLOR][NEWLINE]'..getr(p,id,'TIME_'..i..'_TEXT','') end
    local currentType=tonumber(getr(p,id,'CURRENT_TYPE',-1)) or -1
    rows[#rows+1]={id=id,name=getr(p,id,'NAME','Old Friend'),tag=getr(p,id,'TAG',''),aliases=getr(p,id,'ALIASES',''),epithet=epithet(p,id),status=getr(p,id,'STATUS','Offline'),
      form=currentType>=0 and unitName(currentType) or 'Unknown',bornEra=eraName(tonumber(getr(p,id,'BORN_ERA',0)) or 0),bornTurn=tonumber(getr(p,id,'BORN',0)) or 0,
      years=tonumber(getr(p,id,'YEARS',0)) or 0,eras=tonumber(getr(p,id,'ERAS',0)) or 0,level=tonumber(getr(p,id,'LEVEL',1)) or 1,xp=tonumber(getr(p,id,'XP',0)) or 0,
      battles=tonumber(getr(p,id,'BATTLES',0)) or 0,kills=tonumber(getr(p,id,'KILLS',0)) or 0,distance=tonumber(getr(p,id,'DISTANCE',0)) or 0,
      upgrades=tonumber(getr(p,id,'UPGRADES',0)) or 0,lowHP=tonumber(getr(p,id,'LOW_HP',100)) or 100,memories=tonumber(getr(p,id,'MEMORIES',0)) or 0,conversations=tonumber(getr(p,id,'CONVERSATIONS',0)) or 0,
      closest=closest,together=together,location=getr(p,id,'LOCATION','Unknown'),lineage=displayLineage(getr(p,id,'LINEAGE','')),timeline=table.concat(timeline,'[NEWLINE][NEWLINE]'),
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
