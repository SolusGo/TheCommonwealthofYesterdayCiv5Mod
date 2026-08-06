local CIV = GameInfoTypes.CIVILIZATION_COMMONWEALTH_YESTERDAY
local state = {mem=0, used=0, active=0, activeTurns=0, mel=0, melTurns=0}
local labels = {'','The Boys Are Online','One More World Before Bed','The Summer That Never Ended'}
local melancholy = {'','Everyone Logged Off','The Sun Is Coming Up','September Morning'}
local function playerID() return Game.GetActivePlayer() end
local function eligible() local p=Players[playerID()]; return p and p:GetCivilizationType()==CIV end
local function refresh() ContextPtr:SetHide(not eligible()); if eligible() then LuaEvents.CommonwealthGetState(playerID()) end end
local function redraw()
  local cost=25+state.used*10; Controls.MemoryLabel:SetText('Memories: '..state.mem..'/100')
  if state.activeTurns>0 then Controls.StatusLabel:SetText(labels[state.active]..' — '..state.activeTurns..' turns remain')
  elseif state.melTurns>0 then Controls.StatusLabel:SetText(melancholy[state.mel]..' — '..state.melTurns..' turns remain')
  else Controls.StatusLabel:SetText('Next Reminiscence: '..cost..' Memories') end
  local disabled=state.activeTurns>0 or state.melTurns>0 or state.mem<cost
  Controls.BoysButton:SetDisabled(disabled); Controls.WorldButton:SetDisabled(disabled); Controls.SummerButton:SetDisabled(disabled)
end
LuaEvents.CommonwealthStateResponse.Add(function(p,mem,used,active,activeTurns,mel,melTurns) if p~=playerID() then return end; state={mem=mem,used=used,active=active,activeTurns=activeTurns,mel=mel,melTurns=melTurns}; redraw() end)
LuaEvents.CommonwealthStateChanged.Add(function(p) if p==playerID() then refresh() end end)
Controls.OpenButton:RegisterCallback(Mouse.eLClick,function() Controls.Panel:SetHide(not Controls.Panel:IsHidden()); Controls.Ledger:SetHide(true); refresh() end)
Controls.CloseButton:RegisterCallback(Mouse.eLClick,function() Controls.Panel:SetHide(true) end)
local function activate(choice) LuaEvents.CommonwealthActivateRequest(playerID(),choice); refresh() end
Controls.BoysButton:RegisterCallback(Mouse.eLClick,function() activate(1) end); Controls.WorldButton:RegisterCallback(Mouse.eLClick,function() activate(2) end); Controls.SummerButton:RegisterCallback(Mouse.eLClick,function() activate(3) end)
Controls.LedgerButton:RegisterCallback(Mouse.eLClick,function() Controls.Ledger:SetHide(false); Controls.Panel:SetHide(true); LuaEvents.CommonwealthLedgerRequest(playerID()) end)
Controls.LedgerClose:RegisterCallback(Mouse.eLClick,function() Controls.Ledger:SetHide(true) end)
LuaEvents.CommonwealthLedgerResponse.Add(function(p,rows)
  if p~=playerID() then return end; Controls.LedgerStack:DestroyAllChildren()
  for _,row in ipairs(rows) do local control={}; ContextPtr:BuildInstanceForControl('FriendRow',control,Controls.LedgerStack); control.FriendText:SetText('[COLOR_POSITIVE_TEXT]'..row.name..'[ENDCOLOR] — '..row.tag..'[NEWLINE]'..row.form..' | Years Together: '..row.years..' | Level '..row.level..' | '..row.status) end
  Controls.LedgerStack:CalculateSize(); Controls.LedgerStack:ReprocessAnchoring()
end)
Events.ActivePlayerTurnStart.Add(refresh); Events.LoadScreenClose.Add(refresh); refresh()
