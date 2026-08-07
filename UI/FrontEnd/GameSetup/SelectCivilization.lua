include("UniqueBonuses")

g_bIsScenario = false
g_bWasScenario = true
g_bRefreshCivs = false

function OnBack()
  UIManager:DequeuePopup(ContextPtr)
  ContextPtr:SetHide(true)
end
Controls.BackButton:RegisterCallback(Mouse.eLClick, OnBack)

function IsWBMap(file)
  return Path.UsesExtension(file, ".Civ5Map")
end

function ShowHideHandler(isHide)
  local isWBMap = IsWBMap(PreGame.GetMapScript())
  g_bIsScenario = PreGame.GetLoadWBScenario() and isWBMap
  if g_bWasScenario ~= g_bIsScenario then g_bRefreshCivs = true end
  g_bWasScenario = g_bIsScenario
  if not isHide and (isWBMap or g_bRefreshCivs) then
    g_bRefreshCivs = false
    Controls.Stack:DestroyAllChildren()
    InitCivSelection()
  end
end
ContextPtr:SetShowHideHandler(ShowHideHandler)

function InputHandler(uiMsg, wParam)
  if uiMsg == KeyEvents.KeyDown and wParam == Keys.VK_ESCAPE then OnBack(); return true end
end
ContextPtr:SetInputHandler(InputHandler)

function CivilizationSelected(civID, scenarioPlayerID)
  PreGame.SetCivilization(0, civID)
  if g_bIsScenario then
    UI.MoveScenarioPlayerToSlot(scenarioPlayerID, 0)
    local players = UI.GetMapPlayers(PreGame.GetMapScript())
    local player = players and players[scenarioPlayerID + 1]
    if player then PreGame.SetHandicap(0, player.DefaultHandicap) end
  end
  OnBack()
end

function AddRandomCivilizationEntry()
  local controls = {}
  ContextPtr:BuildInstanceForControl("ItemInstance", controls, Controls.Stack)
  controls.Button:SetVoid1(-1)
  controls.Button:RegisterCallback(Mouse.eLClick, CivilizationSelected)
  controls.Title:LocalizeAndSetText("TXT_KEY_RANDOM_LEADER")
  controls.BonusTitle:SetText("")
  controls.BonusDescription:SetText("")
  controls.Description:LocalizeAndSetText("TXT_KEY_RANDOM_LEADER_HELP")
  IconHookup(22, 128, "LEADER_ATLAS", controls.Portrait)
  if questionOffset then controls.CivIcon:SetTexture(questionTextureSheet); controls.CivIcon:SetTextureOffset(questionOffset) end
  for i = 1, maxSmallButtons do
    controls["B" .. i]:SetTexture(questionTextureSheet)
    controls["B" .. i]:SetTextureOffset(questionOffset)
    controls["B" .. i]:SetToolTipString(unknownString)
  end
end

function AddCivilizationEntry(traitsQuery, populateUniqueBonuses, civ, leaderType, leaderDescription, leaderPortraitIndex, leaderIconAtlas, scenarioCivID)
  local controls = {}
  ContextPtr:BuildInstanceForControl("ItemInstance", controls, Controls.Stack)
  controls.Button:SetVoid1(civ.ID)
  controls.Button:SetVoid2(scenarioCivID)
  controls.Button:RegisterCallback(Mouse.eLClick, CivilizationSelected)
  IconHookup(leaderPortraitIndex, 128, leaderIconAtlas, controls.Portrait)
  local offset, atlas = IconLookup(civ.PortraitIndex, 64, civ.IconAtlas)
  if offset then controls.CivIcon:SetTexture(atlas); controls.CivIcon:SetTextureOffset(offset) end

  local traitName = ""
  for row in traitsQuery(leaderType) do
    controls.BonusDescription:LocalizeAndSetText(row.Description)
    traitName = Locale.ConvertTextKey(row.ShortDescription)
  end
  controls.Title:SetText(Locale.ConvertTextKey("TXT_KEY_RANDOM_LEADER_CIV", leaderDescription, civ.ShortDescription))
  controls.BonusTitle:SetText(traitName)
  controls.Description:LocalizeAndSetText(civ.Description)
  populateUniqueBonuses(controls, civ.Type, true, false)
  return controls
end

function InitCivSelection()
  local traitsQuery = DB.CreateQuery([[SELECT Description, ShortDescription FROM Traits INNER JOIN Leader_Traits ON Traits.Type = Leader_Traits.TraitType WHERE Leader_Traits.LeaderType = ? LIMIT 1]])
  local populateUniqueBonuses = PopulateUniqueBonuses_CreateCached()
  local civEntries = {}
  if g_bIsScenario then
    local scenarioCivQuery = DB.CreateQuery([[SELECT Civilizations.ID, Civilizations.Type, Civilizations.Description, Civilizations.ShortDescription, Civilizations.PortraitIndex, Civilizations.IconAtlas, Leaders.Type AS LeaderType, Leaders.Description AS LeaderDescription, Leaders.PortraitIndex AS LeaderPortraitIndex, Leaders.IconAtlas AS LeaderIconAtlas FROM Civilizations, Leaders, Civilization_Leaders WHERE Civilizations.ID = ? AND Civilizations.Type = Civilization_Leaders.CivilizationType AND Leaders.Type = Civilization_Leaders.LeaderheadType LIMIT 1]])
    local playerList = UI.GetMapPlayers(PreGame.GetMapScript())
    if playerList then
      for i, player in pairs(playerList) do if player.Playable then for row in scenarioCivQuery(player.CivType) do civEntries[#civEntries + 1] = {Locale.Lookup(row.LeaderDescription), row, i - 1} end end end
    end
  else
    AddRandomCivilizationEntry()
    local sql = [[SELECT Civilizations.ID, Civilizations.Type, Civilizations.Description, Civilizations.ShortDescription, Civilizations.PortraitIndex, Civilizations.IconAtlas, Leaders.Type AS LeaderType, Leaders.Description AS LeaderDescription, Leaders.PortraitIndex AS LeaderPortraitIndex, Leaders.IconAtlas AS LeaderIconAtlas FROM Civilizations, Leaders, Civilization_Leaders WHERE Civilizations.Type = Civilization_Leaders.CivilizationType AND Leaders.Type = Civilization_Leaders.LeaderheadType AND Civilizations.Playable = 1]]
    for row in DB.Query(sql) do civEntries[#civEntries + 1] = {Locale.Lookup(row.LeaderDescription), row} end
  end
  table.sort(civEntries, function(a, b) return Locale.Compare(a[1], b[1]) == -1 end)
  for _, entry in ipairs(civEntries) do
    local row = entry[2]
    AddCivilizationEntry(traitsQuery, populateUniqueBonuses, row, row.LeaderType, row.LeaderDescription, row.LeaderPortraitIndex, row.LeaderIconAtlas, entry[3])
  end
  Controls.Stack:CalculateSize()
  Controls.Stack:ReprocessAnchoring()
  Controls.ScrollPanel:CalculateInternalSize()
end

Events.AfterModsActivate.Add(function() g_bRefreshCivs = true end)
Events.AfterModsDeactivate.Add(function() g_bRefreshCivs = true end)
