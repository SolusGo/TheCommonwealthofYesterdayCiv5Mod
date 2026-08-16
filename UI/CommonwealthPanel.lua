include('IconSupport')

local CIV = GameInfoTypes.CIVILIZATION_COMMONWEALTH_YESTERDAY
local BEDROOM = GameInfoTypes.BUILDING_COMMONWEALTH_BEDROOM
local KEEPSAKES = {
  GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_1, GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_2,
  GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_3, GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_4
}
local ARCHAEOLOGY = GameInfoTypes.TECH_ARCHAEOLOGY
local MEMORY_MAX = tonumber(GameDefines.COMMONWEALTH_MEMORY_MAX) or 100
local REMINISCENCE_BASE_COST = tonumber(GameDefines.COMMONWEALTH_REMINISCENCE_BASE_COST) or 25
local REMINISCENCE_COST_STEP = tonumber(GameDefines.COMMONWEALTH_REMINISCENCE_COST_STEP) or 10
local CONVERSATION_BASE_CHANCE = tonumber(GameDefines.COMMONWEALTH_CONVERSATION_BASE_CHANCE) or 15
local state = {mem=0,used=0,active=0,activeTurns=0,mel=0,melTurns=0}
local reminiscences = {
  [1]={name='The Boys Are Online',activeEffect='+15% Production; adjacent military units gain +10% Strength.',melancholyName='Everyone Logged Off',melancholyEffect='-10% military Production.',iconAtlas='COMMONWEALTH_OLD_FRIEND_ATLAS',portraitIndex=0},
  [2]={name='One More World Before Bed',activeEffect='Workers gain +1 Movement and +25% work rate.',melancholyName='The Sun Is Coming Up',melancholyEffect='-10% Science.',iconAtlas='COMMONWEALTH_CIV_ATLAS',portraitIndex=0},
  [3]={name='The Summer That Never Ended',activeEffect='+15% Culture, +2 Happiness per city, and +1 Bedroom Food.',melancholyName='September Morning',melancholyEffect='-10% Culture and -2 Happiness.',iconAtlas='COMMONWEALTH_BEDROOM_ATLAS',portraitIndex=0}
}
if GameInfo.Commonwealth_Reminiscences then for row in GameInfo.Commonwealth_Reminiscences() do
  reminiscences[row.ID]={name=row.Name,activeEffect=row.ActiveEffect,melancholyName=row.MelancholyName,
    melancholyEffect=row.MelancholyEffect,iconAtlas=row.IconAtlas,portraitIndex=row.PortraitIndex or 0}
end end
local ledgerRows, selectedFriend, ledgerFilter, ledgerSort, ledgerMode = {}, nil, 'online', 'name', 'profile'
local conversationHistory, keepsakeCityID = {}, nil
local sortModes={'name','years','recent','form'}
local conversationsEnabled = true
local conversationEvents = {
  general='A QUIET MOMENT', new_era='A NEW ERA', upgrade='AFTER AN UPGRADE',
  near_death='AFTER A CLOSE CALL', victory='AFTER THE BATTLE', reunion='REUNITED',
  reminiscence='A REMINISCENCE', bedroom='BACK IN THE BEDROOM', scarred='STILL STANDING',
  veteran='YEARS TOGETHER', away='FAR FROM HOME'
}
local quotes = {
  'We used to speak every night.',
  'Nobody really left. Life just became busier.',
  'The group is still there, even if the nights are quieter.',
  'There was once always someone online.'
}
local reminiscenceControls

local function hookFriendPortrait(control,size)
  if control then IconHookup(0,size,'COMMONWEALTH_OLD_FRIEND_ATLAS',control) end
end
local function hookUnitIcon(control,row)
  if not control then return end
  if not row or not row.iconAtlas or not IconHookup(row.iconIndex or 0,32,row.iconAtlas,control) then
    IconHookup(0,32,'COMMONWEALTH_OLD_FRIEND_ATLAS',control)
  end
  control:SetToolTipString(row and ('Current form: '..row.form) or 'Old Friend')
end
local function hookConversationEvent(eventType)
  local atlas = eventType == 'bedroom' and 'COMMONWEALTH_BEDROOM_ATLAS' or 'COMMONWEALTH_CIV_ATLAS'
  IconHookup(0,32,atlas,Controls.ConversationEventIcon)
end
local function setPips(prefix,count,total)
  count=math.max(0,math.min(total,tonumber(count) or 0))
  for i=1,total do
    local on,off=Controls[prefix..i..'On'],Controls[prefix..i..'Off']
    if on then on:SetHide(i>count) end
    if off then off:SetHide(i<=count) end
  end
end
local function setupReminiscenceCards()
  reminiscenceControls={
    [1]={button=Controls.BoysButton,icon=Controls.BoysIcon,name=Controls.BoysName,effect=Controls.BoysEffect},
    [2]={button=Controls.WorldButton,icon=Controls.WorldIcon,name=Controls.WorldName,effect=Controls.WorldEffect},
    [3]={button=Controls.SummerButton,icon=Controls.SummerIcon,name=Controls.SummerName,effect=Controls.SummerEffect}
  }
  for id,card in pairs(reminiscenceControls) do
    local data=reminiscences[id]
    IconHookup(data.portraitIndex or 0,32,data.iconAtlas,card.icon)
    card.name:SetText(data.name); card.effect:SetText(data.activeEffect)
    card.button:SetToolTipString(data.activeEffect..'[NEWLINE][NEWLINE]Then: '..data.melancholyName..' - '..data.melancholyEffect)
  end
end

local function playerID() return Game.GetActivePlayer() end
local function eligible() local p=Players[playerID()]; return p and p:GetCivilizationType()==CIV end
local function refresh()
  ContextPtr:SetHide(not eligible())
  if eligible() then
    LuaEvents.CommonwealthGetState(playerID()); LuaEvents.CommonwealthConversationStatusRequest(playerID())
    if not Controls.Ledger:IsHidden() then
      LuaEvents.CommonwealthAdvancedLedgerRequest(playerID()); LuaEvents.CommonwealthConversationHistoryRequest(playerID())
    end
  end
end
local function hasBedroom(city)
  return city and (city:GetNumRealBuilding(BEDROOM)>0 or city:GetNumFreeBuilding(BEDROOM)>0)
end
local redrawKeepsakes
local function bedroomCities()
  local result={}; local player=Players[playerID()]
  if player then for city in player:Cities() do if hasBedroom(city) then result[#result+1]=city end end end
  table.sort(result,function(a,b) return Locale.Compare(a:GetName(),b:GetName()) == -1 end)
  return result
end
local function selectedCommonwealthCity()
  local p=Players[playerID()]
  if not p then return nil end
  local city=UI.GetHeadSelectedCity and UI.GetHeadSelectedCity() or nil
  if city and city:GetOwner()==playerID() and hasBedroom(city) then keepsakeCityID=city:GetID(); return city end
  if keepsakeCityID ~= nil then
    local remembered=p:GetCityByID(keepsakeCityID)
    if hasBedroom(remembered) then return remembered end
  end
  local cities=bedroomCities()
  if #cities>0 then keepsakeCityID=cities[1]:GetID(); return cities[1] end
  return city and city:GetOwner()==playerID() and city or p:GetCapitalCity()
end
local function cycleKeepsakeCity(direction)
  local cities=bedroomCities(); if #cities==0 then return end
  local index=1
  for i,city in ipairs(cities) do if city:GetID()==keepsakeCityID then index=i; break end end
  index=((index-1+direction)%#cities)+1; keepsakeCityID=cities[index]:GetID(); redrawKeepsakes()
end
redrawKeepsakes=function()
  if not eligible() then return end
  local city=selectedCommonwealthCity()
  if not city then
    Controls.KeepsakeCity:SetText('No city selected'); Controls.KeepsakeYield:SetText(''); Controls.KeepsakeProgress:SetText('No Childhood Bedrooms found.')
    Controls.KeepsakePrevious:SetDisabled(true); Controls.KeepsakeNext:SetDisabled(true); setPips('Keep',0,4); return
  end
  local cityHasBedroom=hasBedroom(city)
  local count=0
  for _,building in ipairs(KEEPSAKES) do if city:GetNumRealBuilding(building)>0 then count=count+1 end end
  Controls.KeepsakeCity:SetText(city:GetName()..(cityHasBedroom and '' or ' - No Bedroom'))
  setPips('Keep',count,4)
  local cityCount=#bedroomCities(); Controls.KeepsakePrevious:SetDisabled(cityCount<=1); Controls.KeepsakeNext:SetDisabled(cityCount<=1)
  if not cityHasBedroom then Controls.KeepsakeYield:SetText('Not collecting'); Controls.KeepsakeProgress:SetText('Build a Childhood Bedroom first.'); return end
  local player=Players[playerID()]
  local team=player and Teams[player:GetTeam()]
  local hasArchaeology=team and team:GetTeamTechs():HasTech(ARCHAEOLOGY)
  local tourism=hasArchaeology and math.floor(count/2) or 0
  Controls.KeepsakeYield:SetText('+'..count..' [ICON_CULTURE]'..(hasArchaeology and ('  +'..tourism..' [ICON_TOURISM]') or '[NEWLINE]Tourism later'))
  Controls.KeepsakeProgress:SetText(count>=4 and 'All four Keepsakes preserved.' or 'Next Keepsake: at the next era transition.')
end
local function redraw()
  local cost=REMINISCENCE_BASE_COST+state.used*REMINISCENCE_COST_STEP; Controls.MemoryButton:SetText('[ICON_CULTURE] MEMORIES: '..state.mem..' / '..MEMORY_MAX)
  Controls.MemoryAmount:SetText(state.mem..' / '..MEMORY_MAX..' Memories')
  Controls.MemoryCost:SetText('Next: '..cost)
  Controls.MemoryFill:SetSizeX(math.max(1,math.floor(420*math.max(0,math.min(MEMORY_MAX,state.mem))/MEMORY_MAX)))
  Controls.MemoryFillGlow:SetSizeX(math.max(1,math.floor(420*math.max(0,math.min(MEMORY_MAX,state.mem))/MEMORY_MAX)))
  Controls.MemoryCostMarker:SetOffsetX(40+math.floor(420*math.max(0,math.min(MEMORY_MAX,cost))/MEMORY_MAX))
  local player=Players[playerID()]; local eraRow=player and GameInfo.Eras[player:GetCurrentEra()]
  local eraName=eraRow and Locale.ConvertTextKey(eraRow.Description) or 'Current Era'
  Controls.EraReset:SetText(eraName..'  |  Used this era: '..state.used..'  |  Next era resets to '..REMINISCENCE_BASE_COST)
  if state.activeTurns>0 then Controls.StatusLabel:SetText(reminiscences[state.active].name..' - '..state.activeTurns..' turns remain')
  elseif state.melTurns>0 then Controls.StatusLabel:SetText('Melancholy: '..reminiscences[state.mel].melancholyName..' ('..reminiscences[state.mel].melancholyEffect..') - '..state.melTurns..' turns remain')
  elseif state.mem>=cost then Controls.StatusLabel:SetText('[COLOR_POSITIVE_TEXT]Reminiscence ready.[ENDCOLOR] Choose a memory to relive.')
  else Controls.StatusLabel:SetText('Next Reminiscence: '..cost..' Memories') end
  local disabled=state.activeTurns>0 or state.melTurns>0 or state.mem<cost
  Controls.BoysButton:SetDisabled(disabled); Controls.WorldButton:SetDisabled(disabled); Controls.SummerButton:SetDisabled(disabled)
  local disabledReason=''
  if state.activeTurns>0 then disabledReason='[NEWLINE][NEWLINE]Unavailable while a Reminiscence is active.'
  elseif state.melTurns>0 then disabledReason='[NEWLINE][NEWLINE]Unavailable during Melancholy.'
  elseif state.mem<cost then disabledReason='[NEWLINE][NEWLINE]Needs '..(cost-state.mem)..' more Memories.' end
  for id,card in pairs(reminiscenceControls or {}) do local data=reminiscences[id]
    card.button:SetToolTipString(data.activeEffect..'[NEWLINE][NEWLINE]Then: '..data.melancholyName..' - '..data.melancholyEffect..disabledReason)
  end
  redrawKeepsakes()
end

local setLedgerMode
local function selectFriend(row)
  selectedFriend=row
  if not row then
    Controls.ProfileName:SetText('Select an Old Friend'); Controls.ProfileTag:SetText(''); Controls.ProfileStatus:SetText('')
    Controls.ProfileSummary:SetText(''); Controls.CombatStats:SetText(''); Controls.SurvivalStats:SetText('')
    Controls.LineageText:SetText(''); Controls.RelationshipText:SetText(''); Controls.TimelineText:SetText(''); Controls.YearsBonus:SetText('')
    Controls.TimelineScroll:CalculateInternalSize(); Controls.TimelineScroll:SetScrollValue(0)
    setPips('Year',0,6); hookFriendPortrait(Controls.ProfilePortrait,64); hookUnitIcon(Controls.ProfileFormIcon,nil)
    Controls.LocateButton:SetDisabled(true); Controls.RememberButton:SetDisabled(true); return
  end
  Controls.ProfileName:SetText(row.name..' - '..row.epithet)
  if setLedgerMode then setLedgerMode('profile') end
  local aliases = row.aliases and row.aliases ~= '' and ('   |   Aliases: '..row.aliases) or ''
  Controls.ProfileTag:SetText('Known Online As: '..row.tag..aliases)
  local lastOnline = row.status=='Offline' and row.deathTurn>=0 and ('   |   Last Online: Turn '..row.deathTurn) or ''
  Controls.ProfileStatus:SetText('Status: '..row.status..'   |   Current Location: '..row.location..lastOnline)
  Controls.ProfileSummary:SetText('Current Form: '..row.form..'[NEWLINE]Created: '..row.bornEra..', Turn '..row.bornTurn..'   |   Level '..row.level..' ('..row.xp..' XP)')
  setPips('Year',row.years,6); Controls.YearsBonus:SetText(row.years..'/6  (+'..(row.years*2)..'%)'); hookFriendPortrait(Controls.ProfilePortrait,64); hookUnitIcon(Controls.ProfileFormIcon,row)
  Controls.CombatStats:SetText('[ICON_STRENGTH] COMBAT RECORD[NEWLINE]Battles: '..row.battles..'   Enemies Defeated: '..row.kills)
  Controls.SurvivalStats:SetText('[ICON_HEALTH] PERSONAL RECORD[NEWLINE]Lowest HP: '..row.lowHP..'   Distance: '..row.distance..'   Upgrades: '..row.upgrades)
  Controls.LineageText:SetText(row.lineage ~= '' and row.lineage or row.form)
  Controls.RelationshipText:SetText('Closest: '..row.closest..'   |   Together: '..row.together..' turns   |   Conversations: '..row.conversations..'[NEWLINE]Eras Survived: '..row.eras..'   |   Memories Generated: '..row.memories)
  Controls.TimelineText:SetText(row.timeline ~= '' and row.timeline or 'No archived events yet.')
  Controls.TimelineScroll:CalculateInternalSize(); Controls.TimelineScroll:SetScrollValue(0)
  Controls.LocateButton:SetDisabled(row.status=='Offline' or row.currentUnit<0)
  Controls.RememberButton:SetDisabled(false)
end

local function includeRow(row)
  if ledgerFilter=='all' then return true end
  if ledgerFilter=='offline' then return row.status=='Offline' end
  return row.status~='Offline'
end
local function sortLedgerRows()
  table.sort(ledgerRows,function(a,b)
    if ledgerSort=='years' and a.years~=b.years then return a.years>b.years end
    if ledgerSort=='recent' and a.latestTurn~=b.latestTurn then return a.latestTurn>b.latestTurn end
    if ledgerSort=='form' and a.form~=b.form then return Locale.Compare(a.form,b.form)==-1 end
    return Locale.Compare(a.name,b.name)==-1
  end)
end
local function renderLedgerList()
  local previousMode=ledgerMode
  Controls.LedgerStack:DestroyAllChildren(); sortLedgerRows(); local shown=0; local first=nil
  for _,row in ipairs(ledgerRows) do if includeRow(row) then
    shown=shown+1; if not first then first=row end
    local control={}; ContextPtr:BuildInstanceForControl('FriendRow',control,Controls.LedgerStack)
    hookFriendPortrait(control.RowPortrait,45)
    hookUnitIcon(control.RowFormIcon,row); control.RowYears:SetText(row.years..'/6')
    control.RowName:SetText(row.name..' - '..row.tag)
    control.RowDetail:SetText(row.form..'   |   '..row.status)
    control.FriendButton:RegisterCallback(Mouse.eLClick,function() selectFriend(row) end)
  end end
  Controls.NoFriendsLabel:SetHide(shown>0); Controls.LedgerStack:CalculateSize(); Controls.LedgerStack:ReprocessAnchoring()
  Controls.LedgerScroll:CalculateInternalSize(); Controls.LedgerScroll:SetScrollValue(0)
  if not selectedFriend or not includeRow(selectedFriend) then selectFriend(first) else selectFriend(selectedFriend) end
  if previousMode=='conversations' then setLedgerMode(previousMode) end
end
local function setFilter(value)
  ledgerFilter=value; selectedFriend=nil
  Controls.LedgerView:SetText(string.upper(value=='all' and 'ALL' or value))
  Controls.LivingFilter:SetText(value=='online' and '[ICON_BULLET] Online' or 'Online')
  Controls.OfflineFilter:SetText(value=='offline' and '[ICON_BULLET] Offline' or 'Offline')
  Controls.AllFilter:SetText(value=='all' and '[ICON_BULLET] All' or 'All')
  renderLedgerList()
end
local function renderConversationHistory()
  Controls.ConversationArchiveStack:DestroyAllChildren()
  for _,row in ipairs(conversationHistory) do
    local control={}; ContextPtr:BuildInstanceForControl('ConversationArchiveRow',control,Controls.ConversationArchiveStack)
    local context=conversationEvents[row.kind] or conversationEvents.general
    control.HistoryContext:SetText(context..'  |  Turn '..row.turn..'  |  '..row.location)
    control.HistorySpeakerOne:SetText(row.nameA..(row.tagA~='' and (' - '..row.tagA) or ''))
    control.HistoryLineOne:SetText('"'..row.lineA..'"')
    control.HistorySpeakerTwo:SetText(row.nameB..(row.tagB~='' and (' - '..row.tagB) or ''))
    control.HistoryLineTwo:SetText('"'..row.lineB..'"')
  end
  Controls.NoConversationsLabel:SetHide(#conversationHistory>0)
  Controls.ConversationArchiveCount:SetText(#conversationHistory..' preserved')
  Controls.ConversationArchiveStack:CalculateSize(); Controls.ConversationArchiveStack:ReprocessAnchoring()
  Controls.ConversationArchiveScroll:CalculateInternalSize(); Controls.ConversationArchiveScroll:SetScrollValue(0)
end
setLedgerMode=function(mode)
  ledgerMode=mode
  Controls.ProfilePane:SetHide(mode~='profile'); Controls.ConversationArchivePane:SetHide(mode~='conversations')
  Controls.ProfileTab:SetText(mode=='profile' and '[ICON_BULLET] Profile' or 'Profile')
  Controls.ConversationHistoryTab:SetText(mode=='conversations' and '[ICON_BULLET] Conversations' or 'Conversations')
  if mode=='conversations' then LuaEvents.CommonwealthConversationHistoryRequest(playerID()) end
end
local function cycleLedgerSort()
  local index=1; for i,value in ipairs(sortModes) do if value==ledgerSort then index=i; break end end
  ledgerSort=sortModes[(index%#sortModes)+1]
  local labels={name='Name',years='Years Together',recent='Recent',form='Current Form'}
  Controls.SortButton:SetText('Sort: '..labels[ledgerSort]); renderLedgerList()
end

LuaEvents.CommonwealthStateResponse.Add(function(p,mem,used,active,activeTurns,mel,melTurns)
  if p~=playerID() then return end; state={mem=mem,used=used,active=active,activeTurns=activeTurns,mel=mel,melTurns=melTurns}; redraw()
end)
LuaEvents.CommonwealthStateChanged.Add(function(p) if p==playerID() then refresh() end end)
Controls.MemoryButton:RegisterCallback(Mouse.eLClick,function() Controls.Panel:SetHide(not Controls.Panel:IsHidden()); Controls.Ledger:SetHide(true); refresh() end)
Controls.CloseButton:RegisterCallback(Mouse.eLClick,function() Controls.Panel:SetHide(true) end)
local function activate(choice) LuaEvents.CommonwealthActivateRequest(playerID(),choice); refresh() end
Controls.BoysButton:RegisterCallback(Mouse.eLClick,function() activate(1) end)
Controls.WorldButton:RegisterCallback(Mouse.eLClick,function() activate(2) end)
Controls.SummerButton:RegisterCallback(Mouse.eLClick,function() activate(3) end)
Controls.KeepsakePrevious:RegisterCallback(Mouse.eLClick,function() cycleKeepsakeCity(-1) end)
Controls.KeepsakeNext:RegisterCallback(Mouse.eLClick,function() cycleKeepsakeCity(1) end)
Controls.LedgerButton:RegisterCallback(Mouse.eLClick,function()
  Controls.Ledger:SetHide(false); Controls.Panel:SetHide(true); Controls.RememberQuote:SetText('')
  LuaEvents.CommonwealthAdvancedLedgerRequest(playerID()); LuaEvents.CommonwealthConversationHistoryRequest(playerID())
end)
Controls.LedgerClose:RegisterCallback(Mouse.eLClick,function() Controls.Ledger:SetHide(true) end)
Controls.LivingFilter:RegisterCallback(Mouse.eLClick,function() setFilter('online') end)
Controls.OfflineFilter:RegisterCallback(Mouse.eLClick,function() setFilter('offline') end)
Controls.AllFilter:RegisterCallback(Mouse.eLClick,function() setFilter('all') end)
Controls.ProfileTab:RegisterCallback(Mouse.eLClick,function() setLedgerMode('profile') end)
Controls.ConversationHistoryTab:RegisterCallback(Mouse.eLClick,function() setLedgerMode('conversations') end)
Controls.SortButton:RegisterCallback(Mouse.eLClick,cycleLedgerSort)
Controls.ConversationToggle:RegisterCallback(Mouse.eLClick,function()
  conversationsEnabled=not conversationsEnabled
  if not conversationsEnabled then Controls.ConversationPanel:SetHide(true) end
  LuaEvents.CommonwealthConversationToggle(playerID(),conversationsEnabled and 1 or 0)
end)
Controls.LocateButton:RegisterCallback(Mouse.eLClick,function() if selectedFriend then LuaEvents.CommonwealthLocateFriend(playerID(),selectedFriend.id) end end)
Controls.RememberButton:RegisterCallback(Mouse.eLClick,function()
  if selectedFriend then Controls.RememberQuote:SetText('"'..quotes[((selectedFriend.id+Game.GetGameTurn()) % #quotes)+1]..'"') end
end)
LuaEvents.CommonwealthAdvancedLedgerResponse.Add(function(p,rows)
  if p~=playerID() then return end; ledgerRows=rows or {}; selectedFriend=nil
  local alive,offline=0,0; for _,row in ipairs(ledgerRows) do if row.status=='Offline' then offline=offline+1 else alive=alive+1 end end
  Controls.LedgerCount:SetText(alive..' online   |   '..offline..' no longer online   |   '..#ledgerRows..' archived profiles')
  setFilter(ledgerFilter)
end)
LuaEvents.CommonwealthConversationHistoryResponse.Add(function(p,rows)
  if p~=playerID() then return end; conversationHistory=rows or {}; renderConversationHistory()
end)
LuaEvents.CommonwealthConversationStatusResponse.Add(function(p,enabled)
  if p~=playerID() then return end
  conversationsEnabled=tonumber(enabled)==1
  Controls.ConversationToggle:SetText(conversationsEnabled and ('Conversations: On ('..CONVERSATION_BASE_CHANCE..'% base)') or 'Conversations: Off')
end)
LuaEvents.CommonwealthConversationShown.Add(function(p,nameA,tagA,lineA,nameB,tagB,lineB,location,eventType)
  if p~=playerID() or not conversationsEnabled then return end
  Controls.ConversationContext:SetText((conversationEvents[eventType] or conversationEvents.general)..'   |   Turn '..Game.GetGameTurn()..'   |   '..location)
  Controls.ConversationSpeakerOne:SetText(nameA..' - '..tagA)
  Controls.ConversationLineOne:SetText('"'..lineA..'"')
  Controls.ConversationSpeakerTwo:SetText(nameB..' - '..tagB)
  Controls.ConversationLineTwo:SetText('"'..lineB..'"')
  hookFriendPortrait(Controls.ConversationPortraitOne,45); hookFriendPortrait(Controls.ConversationPortraitTwo,45); hookConversationEvent(eventType)
  Controls.ConversationFooter:SetText(eventType=='general' and 'Another quiet moment preserved in the Ledger.' or 'A new chapter preserved in both timelines.')
  Controls.ConversationPanel:SetHide(false)
  if not Controls.Ledger:IsHidden() and ledgerMode=='conversations' then LuaEvents.CommonwealthConversationHistoryRequest(playerID()) end
end)
Controls.ConversationClose:RegisterCallback(Mouse.eLClick,function() Controls.ConversationPanel:SetHide(true) end)
Events.ActivePlayerTurnStart.Add(refresh)
Events.SerialEventEnterCityScreen.Add(function() keepsakeCityID=nil; redrawKeepsakes() end); Events.SerialEventExitCityScreen.Add(redrawKeepsakes)
Events.SerialEventCityInfoDirty.Add(redrawKeepsakes)
local function fitLedgerToScreen()
  local _,screenY=UIManager:GetScreenSizeVal(); local height=math.max(640,math.min(660,screenY-80)); local body=height-184
  Controls.Ledger:SetSizeVal(920,height); Controls.LedgerBackdrop:SetSizeVal(824,height-112)
  Controls.LedgerListPane:SetSizeY(body); Controls.LedgerListShade:SetSizeY(body-16); Controls.LedgerListAccent:SetSizeY(body-24); Controls.LedgerScroll:SetSizeY(body-16)
  Controls.ProfilePane:SetSizeY(body); Controls.ProfileShade:SetSizeY(body-16); Controls.ProfileAccent:SetSizeY(body-24)
  Controls.ConversationArchivePane:SetSizeY(body); Controls.ConversationArchiveShade:SetSizeY(body-16); Controls.ConversationArchiveAccent:SetSizeY(body-24)
  Controls.TimelineScroll:SetSizeY(math.max(22,body-434)); Controls.ConversationArchiveScroll:SetSizeY(math.max(362,body-74))
end
Events.LoadScreenClose.Add(function() fitLedgerToScreen(); refresh() end)
hookFriendPortrait(Controls.ProfilePortrait,64); hookFriendPortrait(Controls.ConversationPortraitOne,45); hookFriendPortrait(Controls.ConversationPortraitTwo,45)
setupReminiscenceCards(); fitLedgerToScreen(); setLedgerMode('profile'); refresh()
