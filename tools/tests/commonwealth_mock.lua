local nextType=100
GameInfoTypes=setmetatable({
  CIVILIZATION_COMMONWEALTH_YESTERDAY=1,
  UNIT_COMMONWEALTH_OLD_FRIEND=10,
  UNIT_TEST_SWORD=11,
  UNIT_TEST_MUSKET=12,
  UNIT_TEST_ENEMY=13,
  UNITCLASS_WORKER=90,
},{__index=function(table,key) nextType=nextType+1; rawset(table,key,nextType); return nextType end})

local function infoTable(rows)
  return setmetatable(rows or {},{__call=function(values)
    local keys={}; for key in pairs(values) do if type(key)=='number' then keys[#keys+1]=key end end
    table.sort(keys); local index=0
    return function() index=index+1; return values[keys[index]] end
  end})
end
GameInfo={
  Units=infoTable({
    [10]={ID=10,Type='UNIT_COMMONWEALTH_OLD_FRIEND',Description='Old Friend',PortraitIndex=0,IconAtlas='COMMONWEALTH_OLD_FRIEND_ATLAS'},
    [11]={ID=11,Type='UNIT_TEST_SWORD',Description='Swordsman',PortraitIndex=1,IconAtlas='UNIT_ATLAS'},
    [12]={ID=12,Type='UNIT_TEST_MUSKET',Description='Musketman',PortraitIndex=2,IconAtlas='UNIT_ATLAS'},
    [13]={ID=13,Type='UNIT_TEST_ENEMY',Description='Enemy',PortraitIndex=3,IconAtlas='UNIT_ATLAS'},
  }),
  Eras=infoTable({[0]={ID=0,Description='Ancient Era'},[1]={ID=1,Description='Classical Era'}}),
  GameSpeeds=infoTable({[0]={ID=0,GoldenAgePercent=100}}),
  Buildings=infoTable({}), BuildingClasses=infoTable({}),
}

local stored={}
local save={
  GetValue=function(key) return stored[key] end,
  SetValue=function(key,value) stored[key]=value end,
}
CommonwealthSaveData=save
Modding={OpenSaveData=function() return save end}

local function event()
  local result={handlers={}}
  function result.Add(handler) result.handlers[#result.handlers+1]=handler end
  return setmetatable(result,{__call=function(_,...) for _,handler in ipairs(result.handlers) do handler(...) end end})
end
local function eventBus()
  return setmetatable({},{__index=function(table,key) local value=event(); rawset(table,key,value); return value end})
end
GameEvents=eventBus(); Events=eventBus(); LuaEvents=eventBus()

Game={turn=0,GetGameTurn=function() return Game.turn end,GetGameSpeedType=function() return 0 end,
  Rand=function(limit) if limit <= 0 then return 0 end; return 0 end}
GameDefines={MAX_MAJOR_CIVS=4,MAX_CIV_PLAYERS=4}
DirectionTypes={NUM_DIRECTION_TYPES=6}
Locale={ConvertTextKey=function(value) return tostring(value or '') end,Compare=function(a,b) return a<b and -1 or (a==b and 0 or 1) end}
DB={Query=function() return function() return nil end end}

local plots={}
local function plot(x,y)
  local key=x..':'..y
  if not plots[key] then
    plots[key]={x=x,y=y,owner=-1,units={},GetX=function(self) return self.x end,GetY=function(self) return self.y end,
      GetOwner=function(self) return self.owner end,GetPlotCity=function() return nil end,
      GetNumUnits=function(self) return #self.units end,GetUnit=function(self,index) return self.units[index+1] end}
  end
  return plots[key]
end
Map={PlotDistance=function(x1,y1,x2,y2) return math.max(math.abs(x1-x2),math.abs(y1-y2)) end,
  PlotDirection=function() return nil end,GetPlot=function(x,y) return plot(x,y) end}

Players={}
function NewPlayer(id,civilization)
  local player={id=id,civ=civilization,alive=true,human=false,era=0,units={}}
  function player:IsAlive() return self.alive end
  function player:IsHuman() return self.human end
  function player:GetCivilizationType() return self.civ end
  function player:GetCurrentEra() return self.era end
  function player:GetUnitByID(unitID) return self.units[unitID] end
  function player:Units()
    local ids={}; for unitID in pairs(self.units) do ids[#ids+1]=unitID end; table.sort(ids)
    local index=0; return function() index=index+1; return self.units[ids[index]] end
  end
  function player:Cities() return function() return nil end end
  function player:GetCapitalCity() return nil end
  function player:GetCityByID() return nil end
  function player:GetNumCities() return 0 end
  function player:GetNumMilitaryUnits() return 0 end
  function player:GetExcessHappiness() return 0 end
  Players[id]=player; return player
end

function NewUnit(owner,id,kind,hasSince,x,y)
  local unit={owner=owner,id=id,kind=kind,promotions={},name='',damage=0,maxHP=100,level=1,xp=0,x=x or id,y=y or 0}
  if hasSince then unit.promotions[GameInfoTypes.PROMOTION_COMMONWEALTH_SINCE_BEGINNING]=true end
  function unit:GetOwner() return self.owner end
  function unit:GetID() return self.id end
  function unit:GetUnitType() return self.kind end
  function unit:GetUnitClassType() return 0 end
  function unit:IsHasPromotion(promotion) return self.promotions[promotion] == true end
  function unit:SetHasPromotion(promotion,value) self.promotions[promotion]=value and true or nil end
  function unit:SetName(value) self.name=value end
  function unit:GetName() return self.name end
  function unit:GetMaxHitPoints() return self.maxHP end
  function unit:GetDamage() return self.damage end
  function unit:ChangeDamage(value) self.damage=math.max(0,self.damage+value) end
  function unit:GetLevel() return self.level end
  function unit:GetExperience() return self.xp end
  function unit:GetX() return self.x end
  function unit:GetY() return self.y end
  function unit:GetPlot() return plot(self.x,self.y) end
  function unit:IsCombatUnit() return true end
  function unit:IsTrade() return false end
  Players[owner].units[id]=unit
  return unit
end

NewPlayer(0,GameInfoTypes.CIVILIZATION_COMMONWEALTH_YESTERDAY)
NewPlayer(1,999)

TestState={stored=stored,save=save,plot=plot}
