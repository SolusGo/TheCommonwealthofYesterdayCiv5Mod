print('CommonwealthLoader loaded')

-- Modding.OpenSaveData is shared by every campaign that uses the mod. Scope
-- Commonwealth state to immutable setup data so map scripts cannot move the
-- namespace after they finish terrain generation or True Start placement.
local rawSave = Modding.OpenSaveData()
local function safePreGameNumber(name)
  local getter=PreGame and PreGame[name]
  if type(getter) ~= 'function' then return nil end
  local ok,value=pcall(getter)
  return ok and tonumber(value) or nil
end
local function safeNetworkNumber(name)
  local getter=Network and Network[name]
  if type(getter) ~= 'function' then return nil end
  local ok,value=pcall(getter)
  return ok and tonumber(value) or nil
end
local function safePreGameString(name)
  local getter=PreGame and PreGame[name]
  if type(getter) ~= 'function' then return nil end
  local ok,value=pcall(getter)
  return ok and value ~= nil and tostring(value) or nil
end
local function makeHasher()
  local hash=5381
  local function mix(value)
    if type(value) == 'string' then
      for index=1,#value do hash=(hash*65599+string.byte(value,index)+97)%2147483647 end
    else hash=(hash*65599+(tonumber(value) or 0)+97)%2147483647 end
  end
  return mix,function() return math.floor(hash) end
end
local function stableCampaignFingerprint()
  local width,height=Map.GetGridSize()
  local mix,result=makeHasher()
  mix(width); mix(height); mix(Game.GetGameSpeedType())
  local mapSeed=safePreGameNumber('GetMapSeed')
  local syncSeed=safePreGameNumber('GetSyncRandSeed') or safeNetworkNumber('GetSynchRandSeed')
  local rerollsOnLoad=GameOptionTypes and GameOptionTypes.GAMEOPTION_NEW_RANDOM_SEED
    and Game.IsOption(GameOptionTypes.GAMEOPTION_NEW_RANDOM_SEED)
  mix(mapSeed ~= nil and 1 or 0); if mapSeed ~= nil then mix(mapSeed) end
  mix(syncSeed ~= nil and not rerollsOnLoad and 1 or 0)
  if syncSeed ~= nil and not rerollsOnLoad then mix(syncSeed) end
  for playerID=0,GameDefines.MAX_MAJOR_CIVS-1 do
    local player=Players[playerID]
    if player and player:IsEverAlive() then
      mix(playerID); mix(player:GetCivilizationType()); mix(player:GetLeaderType())
    end
  end
  return tostring(width)..'x'..tostring(height)..'_'..tostring(result()),mapSeed,syncSeed,rerollsOnLoad
end
-- COY3 used generated terrain and assigned starting plots. YnAEMP can change
-- both after this add-in loads, so the same save received a second namespace
-- on reload. Retain the calculation only as a read-through migration source.
local function legacyCampaignFingerprint()
  local width,height=Map.GetGridSize()
  local mix,result=makeHasher()
  mix(width); mix(height); mix(Game.GetGameSpeedType())
  for index=0,(width*height)-1 do
    local plot=Map.GetPlot(index%width,math.floor(index/width))
    if plot then mix(plot:GetPlotType()); mix(plot:GetTerrainType()) end
  end
  for playerID=0,GameDefines.MAX_MAJOR_CIVS-1 do
    local player=Players[playerID]
    if player and player:IsEverAlive() then
      mix(playerID); mix(player:GetCivilizationType()); mix(player:GetLeaderType())
      local start=player:GetStartingPlot()
      mix(start and start:GetPlotIndex() or -1)
    end
  end
  return tostring(width)..'x'..tostring(height)..'_'..tostring(result())
end
local function isLoadedGame()
  local fileName=safePreGameString('GetLoadFileName') or ''
  if fileName ~= '' then return true end
  if UI and type(UI.IsLoadedGame) == 'function' then
    local ok,value=pcall(UI.IsLoadedGame,UI)
    if ok and value then return true end
  end
  return Game.GetGameTurn() > 0
end
local function legacyHasState(prefix)
  for playerID=0,GameDefines.MAX_MAJOR_CIVS-1 do
    if rawSave.GetValue(prefix..'COY_'..playerID..'_ERA') ~= nil
      or rawSave.GetValue(prefix..'COY2_COUNT_'..playerID) ~= nil then return true end
  end
  return false
end

local fingerprint,mapSeed,syncSeed,rerollsOnLoad=stableCampaignFingerprint()
local campaignPrefix='COY4_'..fingerprint..'_'
local migrationSourceKey=campaignPrefix..'COY4_MIGRATION_SOURCE'
local migrationSource=rawSave.GetValue(migrationSourceKey)
if migrationSource == nil then
  migrationSource=''
  if isLoadedGame() then
    local candidate='COY3_'..legacyCampaignFingerprint()..'_'
    if legacyHasState(candidate) then migrationSource=candidate end
  end
  rawSave.SetValue(migrationSourceKey,migrationSource)
end
CommonwealthSaveData = {
  GetValue = function(key)
    local value=rawSave.GetValue(campaignPrefix..key)
    if value == nil and migrationSource ~= '' then value=rawSave.GetValue(migrationSource..key) end
    return value
  end,
  SetValue = function(key,value) rawSave.SetValue(campaignPrefix..key,value) end
}
print('CommonwealthLoader: campaign state namespace '..campaignPrefix
  ..' (map seed '..tostring(mapSeed)..', sync seed '..tostring(syncSeed)
  ..(rerollsOnLoad and ', sync seed excluded by New Random Seed' or '')..')')
if mapSeed == nil and (syncSeed == nil or rerollsOnLoad) then
  print('CommonwealthLoader: warning - Civ V exposed no setup seeds; campaign separation is using immutable setup data only')
end
if migrationSource ~= '' then print('CommonwealthLoader: reading legacy campaign state from '..migrationSource) end

include('CommonwealthCore.lua')
include('CommonwealthFriends.lua')
