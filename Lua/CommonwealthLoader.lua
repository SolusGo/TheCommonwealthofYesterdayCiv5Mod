print('CommonwealthLoader loaded')

-- Modding.OpenSaveData is shared by every campaign that uses the mod. Scope
-- Commonwealth state to a stable fingerprint of the generated world and major
-- player setup so a fresh campaign cannot inherit Memories, identities,
-- cooldowns, or archive records from an older one. Plot and terrain types plus
-- starting plots survive save/load; transient ownership, units, improvements,
-- features, and resources are deliberately excluded.
local rawSave = Modding.OpenSaveData()
local function campaignFingerprint()
  local width,height=Map.GetGridSize()
  local hash=5381
  local function mix(value)
    hash=(hash*65599+(tonumber(value) or 0)+97)%2147483647
  end
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
  return tostring(width)..'x'..tostring(height)..'_'..tostring(math.floor(hash))
end
local campaignPrefix = 'COY3_'..campaignFingerprint()..'_'
CommonwealthSaveData = {
  GetValue = function(key) return rawSave.GetValue(campaignPrefix..key) end,
  SetValue = function(key,value) rawSave.SetValue(campaignPrefix..key,value) end
}
print('CommonwealthLoader: campaign state namespace '..campaignPrefix)

include('CommonwealthCore.lua')
include('CommonwealthFriends.lua')
