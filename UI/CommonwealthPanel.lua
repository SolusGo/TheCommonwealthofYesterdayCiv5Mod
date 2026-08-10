include('IconSupport')

local CIV = GameInfoTypes.CIVILIZATION_COMMONWEALTH_YESTERDAY
local BEDROOM = GameInfoTypes.BUILDING_COMMONWEALTH_BEDROOM
local KEEPSAKES = {
  GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_1, GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_2,
  GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_3, GameInfoTypes.BUILDING_COMMONWEALTH_KEEP_4
}
local ARCHAEOLOGY = GameInfoTypes.TECH_ARCHAEOLOGY
local state = {mem=0,used=0,active=0,activeTurns=0,mel=0,melTurns=0}
local labels = {
  [1]='The Boys Are Online',
  [2]='One More World Before Bed',
  [3]='The Summer That Never Ended'
}
local melancholy = {
  [1]='Everyone Logged Off',
  [2]='The Sun Is Coming Up',
  [3]='September Morning'
}
local melancholyEffects = {
  [1]='-10% military Production',
  [2]='-10% Science',
  [3]='-10% Culture, -2 Happiness'
}
local ledgerRows, selectedFriend, ledgerFilter = {}, nil, 'online'
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

local function hookFriendPortrait(control,size)
  if control then IconHookup(0,size,'COMMONWEALTH_OLD_FRIEND_ATLAS',control) end
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

local function playerID() return Game.GetActivePlayer() end
local function eligible() local p=Players[playerID()]; return p and p:GetCivilizationType()==CIV end
local function refresh()
  ContextPtr:SetHide(not eligible())
  if eligible() then LuaEvents.CommonwealthGetState(playerID()); LuaEvents.CommonwealthConversationStatusRequest(playerID()) end
end
local function selectedCommonwealthCity()
  local p=Players[playerID()]
  if not p then return nil end
  local city=UI.GetHeadSelectedCity and UI.GetHeadSelectedCity() or nil
  if city and city:GetOwner()==playerID() then return city end
  return p:GetCapitalCity()
end
local function redrawKeepsakes()
  if not eligible() then return end
  local city=selectedCommonwealthCity()
  if not city then
    Controls.KeepsakeCity:SetText('No city selected'); Controls.KeepsakeYield:SetText(''); setPips('Keep',0,4); return
  end
  local hasBedroom=city:GetNumRealBuilding(BEDROOM)>0 or city:GetNumFreeBuilding(BEDROOM)>0
  local count=0
  for _,building in ipairs(KEEPSAKES) do if city:GetNumRealBuilding(building)>0 then count=count+1 end end
  Controls.KeepsakeCity:SetText(city:GetName()..(hasBedroom and '' or ' - No Bedroom'))
  setPips('Keep',count,4)
  if not hasBedroom then Controls.KeepsakeYield:SetText('Not collecting') return end
  local player=Players[playerID()]
  local team=player and Teams[player:GetTeam()]
  local hasArchaeology=team and team:GetTeamTechs():HasTech(ARCHAEOLOGY)
  local tourism=hasArchaeology and math.floor(count/2) or 0
  Controls.KeepsakeYield:SetText('+'..count..' [ICON_CULTURE]'..(hasArchaeology and ('  +'..tourism..' [ICON_TOURISM]') or '[NEWLINE]Tourism later'))
end
local function redraw()
  local cost=25+state.used*10; Controls.MemoryButton:SetText('MEMORIES: '..state.mem..' / 100')
  Controls.MemoryAmount:SetText(state.mem..' / 100 Memories')
  Controls.MemoryCost:SetText('Next: '..cost)
  Controls.MemoryFill:SetSizeX(math.max(1,math.floor(420*math.max(0,math.min(100,state.mem))/100)))
  Controls.MemoryCostMarker:SetOffsetX(40+math.floor(420*math.max(0,math.min(100,cost))/100))
  if state.activeTurns>0 then Controls.StatusLabel:SetText(labels[state.active]..' - '..state.activeTurns..' turns remain')
  elseif state.melTurns>0 then Controls.StatusLabel:SetText('Melancholy: '..melancholy[state.mel]..' ('..melancholyEffects[state.mel]..') - '..state.melTurns..' turns remain')
  else Controls.StatusLabel:SetText('Next Reminiscence: '..cost..' Memories') end
  local disabled=state.activeTurns>0 or state.melTurns>0 or state.mem<cost
  Controls.BoysButton:SetDisabled(disabled); Controls.WorldButton:SetDisabled(disabled); Controls.SummerButton:SetDisabled(disabled)
  redrawKeepsakes()
end

local function selectFriend(row)
  selectedFriend=row
  if not row then
    Controls.ProfileName:SetText('Select an Old Friend'); Controls.ProfileTag:SetText(''); Controls.ProfileStatus:SetText('')
    Controls.ProfileSummary:SetText(''); Controls.CombatStats:SetText(''); Controls.SurvivalStats:SetText('')
    Controls.LineageText:SetText(''); Controls.RelationshipText:SetText(''); Controls.TimelineText:SetText(''); Controls.YearsBonus:SetText('')
    setPips('Year',0,6); hookFriendPortrait(Controls.ProfilePortrait,64)
    Controls.LocateButton:SetDisabled(true); Controls.RememberButton:SetDisabled(true); return
  end
  Controls.ProfileName:SetText(row.name..' - '..row.epithet)
  local aliases = row.aliases and row.aliases ~= '' and ('   |   Aliases: '..row.aliases) or ''
  Controls.ProfileTag:SetText('Known Online As: '..row.tag..aliases)
  local lastOnline = row.status=='Offline' and row.deathTurn>=0 and ('   |   Last Online: Turn '..row.deathTurn) or ''
  Controls.ProfileStatus:SetText('Status: '..row.status..'   |   Current Location: '..row.location..lastOnline)
  Controls.ProfileSummary:SetText('Current Form: '..row.form..'[NEWLINE]Created: '..row.bornEra..', Turn '..row.bornTurn..'   |   Level '..row.level..' ('..row.xp..' XP)')
  setPips('Year',row.years,6); Controls.YearsBonus:SetText(row.years..'/6  (+'..(row.years*2)..'%)'); hookFriendPortrait(Controls.ProfilePortrait,64)
  Controls.CombatStats:SetText('[ICON_STRENGTH] COMBAT RECORD[NEWLINE]Battles: '..row.battles..'   Enemies Defeated: '..row.kills)
  Controls.SurvivalStats:SetText('[ICON_HEALTH] PERSONAL RECORD[NEWLINE]Lowest HP: '..row.lowHP..'   Distance: '..row.distance..'   Upgrades: '..row.upgrades)
  Controls.LineageText:SetText(row.lineage ~= '' and row.lineage or row.form)
  Controls.RelationshipText:SetText('Closest: '..row.closest..'   |   Together: '..row.together..' turns   |   Conversations: '..row.conversations..'[NEWLINE]Eras Survived: '..row.eras..'   |   Memories Generated: '..row.memories)
  Controls.TimelineText:SetText(row.timeline ~= '' and row.timeline or 'No archived events yet.')
  Controls.LocateButton:SetDisabled(row.status=='Offline' or row.currentUnit<0)
  Controls.RememberButton:SetDisabled(false)
end

local function includeRow(row)
  if ledgerFilter=='all' then return true end
  if ledgerFilter=='offline' then return row.status=='Offline' end
  return row.status~='Offline'
end
local function renderLedgerList()
  Controls.LedgerStack:DestroyAllChildren(); local shown=0; local first=nil
  for _,row in ipairs(ledgerRows) do if includeRow(row) then
    shown=shown+1; if not first then first=row end
    local control={}; ContextPtr:BuildInstanceForControl('FriendRow',control,Controls.LedgerStack)
    hookFriendPortrait(control.RowPortrait,45)
    control.RowName:SetText(row.name..' - '..row.tag)
    control.RowDetail:SetText(row.form..'   |   '..row.status)
    control.FriendButton:RegisterCallback(Mouse.eLClick,function() selectFriend(row) end)
  end end
  Controls.NoFriendsLabel:SetHide(shown>0); Controls.LedgerStack:CalculateSize(); Controls.LedgerStack:ReprocessAnchoring()
  Controls.LedgerScroll:CalculateInternalSize(); Controls.LedgerScroll:SetScrollValue(0)
  if not selectedFriend or not includeRow(selectedFriend) then selectFriend(first) else selectFriend(selectedFriend) end
end
local function setFilter(value) ledgerFilter=value; selectedFriend=nil; renderLedgerList() end

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
Controls.LedgerButton:RegisterCallback(Mouse.eLClick,function()
  Controls.Ledger:SetHide(false); Controls.Panel:SetHide(true); Controls.RememberQuote:SetText(''); LuaEvents.CommonwealthAdvancedLedgerRequest(playerID())
end)
Controls.LedgerClose:RegisterCallback(Mouse.eLClick,function() Controls.Ledger:SetHide(true) end)
Controls.LivingFilter:RegisterCallback(Mouse.eLClick,function() setFilter('online') end)
Controls.OfflineFilter:RegisterCallback(Mouse.eLClick,function() setFilter('offline') end)
Controls.AllFilter:RegisterCallback(Mouse.eLClick,function() setFilter('all') end)
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
  renderLedgerList()
end)
LuaEvents.CommonwealthConversationStatusResponse.Add(function(p,enabled)
  if p~=playerID() then return end
  conversationsEnabled=tonumber(enabled)==1
  Controls.ConversationToggle:SetText(conversationsEnabled and 'Conversations: On (8% base)' or 'Conversations: Off')
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
end)
Controls.ConversationClose:RegisterCallback(Mouse.eLClick,function() Controls.ConversationPanel:SetHide(true) end)
Events.ActivePlayerTurnStart.Add(refresh); Events.LoadScreenClose.Add(refresh)
Events.SerialEventEnterCityScreen.Add(redrawKeepsakes); Events.SerialEventExitCityScreen.Add(redrawKeepsakes)
Events.SerialEventCityInfoDirty.Add(redrawKeepsakes)
hookFriendPortrait(Controls.ProfilePortrait,64); hookFriendPortrait(Controls.ConversationPortraitOne,45); hookFriendPortrait(Controls.ConversationPortraitTwo,45)
refresh()
