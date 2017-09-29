local oUF = bdCore.oUF
local defaultwhitelist = {
	['Arcane Torrent'] = true,
	['War Stomp'] = true,
}

local fixateMobs = {}
fixateMobs['Tormented Fragment'] = true
fixateMobs['Razorjaw Gladiator'] = true
fixateMobs['Sickly Tadpole'] = true
fixateMobs['Soul Residue'] = true
fixateMobs['Nightmare Ichor'] = true
fixateMobs['Atrigan'] = true

local raidwhitelist = {
	-- CC
	['Banish'] = true,
	['Repentance'] = true,
	['Polymorph: Sheep'] = true,
	['Polymorph'] = true,
	['Blind'] = true,
	['Paralyze'] = true,
	['Imprison'] = true,
	['Sap'] = true,
	
	-- ToS
	-- DI
	['Fel Squall'] = true,
	['Bone Saw'] = true,
	['Harrowing Reconstitution'] = true,
	
	-- Harjatan
	['Hardened Shell'] = true,
	['Frigid Blows'] = true,
	['Draw In'] = true,
	
	-- Host
	['Bonecage Armor'] = true,
	
	-- Maiden
	['Titanic Bulwark'] = true,
	
	-- Sisters
	['Embrace of the Eclipse'] = true,
	
	-- Avatar
	['Tainted Matrix'] = true,
	['Corrupted Matrix'] = true,
	['Matrix Empowerment'] = true,
	
	-- KJ
	['Felclaws'] = true,
}

local modules = {}
--modules["Star Augur Etraeus"] = function()

local function cvar_set() end
local function npcallback() end

local function enumerateNameplates()
	config = bdCore.config.profile['Nameplates']
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		local unit = frame.unitFrame.unit
		npcallback("", "", frame,unit)
	end
end

local defaults = {}

--------------
-- Positioning & Display
--------------
	defaults[#defaults+1] = {tab = {
		type="tab",
		value="Sizing & Display"
	}}
	defaults[#defaults+1] = {friendnamealpha={
		type="slider",
		value=1,
		min=0,
		max=1,
		step=0.1,
		label="Friendly Name Opacity",
		callback=function() enumerateNameplates() end
	}}
	
	defaults[#defaults+1] = {width={
		type="slider",
		value=200,
		min=30,
		max=250,
		step=2,
		label="Nameplates Width",
		callback=function() enumerateNameplates() end
	}}

	defaults[#defaults+1] = {height={
		type="slider",
		value=20,
		min=4,
		max=50,
		step=2,
		label="Nameplates Height",
		callback=function() enumerateNameplates() end
	}}
	defaults[#defaults+1] = {verticalspacing={
		type="slider",
		value=1.8,
		min=0,
		max=4,
		step=0.1,
		label="Vertical Spacing",
		callback=function() cvar_set() end
	}}
	defaults[#defaults+1] = {castbarheight={
		type="slider",
		value=18,
		min=4,
		max=50,
		step=2,
		label="Castbar Height",
		callback=function() cvar_set() end
	}}
	defaults[#defaults+1] = {nameplatedistance={
		type="slider",
		value=50,
		min=10,
		max=100,
		step=2,
		label="Nameplates Draw Distance",
		callback=function() cvar_set() end
	}}
	defaults[#defaults+1] = {bossmodules = {
		type = "checkbox",
		value = true,
		label = "Enable Boss Modules",
		callback = function() enumerateNameplates() end
	}}
	--[[
	defaults[#defaults+1] = {nameplatemotion = {
		type = "dropdown",
		value = 1,
		options = {1,0},
		label = "Stacking: 1 for stacked, 0 for overlapping",
		callback = function() cvar_set() end
	}}--]]

-------------
-- Text
-------------
	defaults[#defaults+1] = {tab = {
		type="tab",
		value="Text"
	}}
	defaults[#defaults+1] = {hptext = {
		type = "dropdown",
		value = "HP - %",
		options = {"None","HP - %", "HP", "%"},
		label = "Nameplate Health Text",
		callback = function() enumerateNameplates() end
	}}
	defaults[#defaults+1] = {fixatealert = {
		type = "dropdown",
		value = "All",
		options = {"All","Always","Personal","None"},
		label = "Fixate Alert"
	}}
	defaults[#defaults+1] = {showhptexttargetonly = {
		type = "checkbox",
		value = false,
		label = "Show Health Text on target only",
		callback = function() enumerateNameplates() end
	}}
	defaults[#defaults+1] = {hidefriendnames = {
		type = "checkbox",
		value = false,
		label = "Hide Friendly Names",
		callback = function() enumerateNameplates() end
	}}
	defaults[#defaults+1] = {enemynamesize={
		type="slider",
		value=16,
		min=8,
		max=24,
		step=1,
		label="Enemy Name Font Size",
		callback=function() enumerateNameplates() end
	}}
	defaults[#defaults+1] = {friendlynamesize={
		type="slider",
		value=16,
		min=8,
		max=24,
		step=1,
		label="Friendly Name Font Size",
		callback=function() enumerateNameplates() end
	}}

	defaults[#defaults+1] = {raidmarkersize={
		type="slider",
		value=24,
		min=10,
		max=50,
		step=2,
		label="Raid Marker Icon Size",
		callback=function() enumerateNameplates() end
	}}
	defaults[#defaults+1] = {markposition = {
		type = "dropdown",
		value = "TOP",
		options = {"LEFT","TOP","RIGHT"},
		label = "Raid Marker position",
		tooltip = "Where raid markers should be positioned on the nameplate.",
		callback = function() enumerateNameplates() end
	}}

-------------
-- Colors
-------------
	defaults[#defaults+1] = {tab = {
		type="tab",
		value="Colors"
	}}
	defaults[#defaults+1] = {kickable={
		type="color",
		value={.1, .4, .7, 1},
		name="Interruptable Cast Color"
	}}
	defaults[#defaults+1] = {nonkickable={
		type="color",
		value={.7, .7, .7, 1},
		name="Non-Interruptable Cast Color"
	}}
	defaults[#defaults+1] = {glowcolor={
		type="color",
		value={1,1,1,1},
		name="Target Glow Color"
	}}
	defaults[#defaults+1] = {threatcolor={
		type="color",
		value={.79, .3, .21, 1},
		name="Have Aggro Color"
	}}
	defaults[#defaults+1] = {nothreatcolor={
		type="color",
		value={0.3, 1, 0.3,1},
		name="No Aggro Color"
	}}
	defaults[#defaults+1] = {threatdangercolor={
		type="color",
		value={1, .55, 0.3,1},
		name="Danger Aggro Color"
	}}
	defaults[#defaults+1] = {executecolor={
		type="color",
		value={.1, .4, .7,1},
		name="Execute Range Color"
	}}
	defaults[#defaults+1] = {executerange = {
		type = "slider",
		value=20,
		min=0,
		max=40,
		step=5,
		label = "Execute range",
		callback = function() enumerateNameplates() end
	}}
	defaults[#defaults+1] = {unselectedalpha={
		type="slider",
		value=0.5,
		min=0.1,
		max=1,
		step=0.1,
		label="Unselected nameplate alpha",
		callback=function() enumerateNameplates() end
	}}

-------------
-- Target
-------------
	--[[defaults[#defaults+1] = {tab = {
		type="tab",
		value="Target"
	}}
	

	
	defaults[#defaults+1] = {showfriendlybar = {
		type = "checkbox",
		value = false,
		label = "Show health bar when targeting friendly.",
		callback = function() enumerateNameplates() end
	}}--]]

-------------
-- Your Debuffs
-------------
	defaults[#defaults+1] = {tab = {
		type="tab",
		value="Your Debuffs"
	}}
	defaults[#defaults+1] = {automydebuff={
		type="checkbox",
		value=false,
		label="Automatically track debuffs cast by you."
	}}
	defaults[#defaults+1] = {debuffsize={
		type="slider",
		value=40,
		min=20,
		max=40,
		step=2,
		label="Debuff Size",
	}}
	defaults[#defaults+1] = {selfwhitelist={
		type="list",
		value={},
		label="Enemy Debuffs (cast by you)",
		tooltip="Use to show a specified aura cast by you."
	}}

-------------
-- Anyone's Auras
-------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="All Auras"
}}
defaults[#defaults+1] = {raidbefuffs={
	type="slider",
	value=50,
	min=20,
	max=100,
	step=2,
	label="Raid Debuff Size",
}}
defaults[#defaults+1] = {whitelist={
	type="list",
	value=defaultwhitelist,
	label="Friendly/Enemy Auras (cast by anyone)",
	tooltip="Use to show a specified aura cast by anyone."
}}

-------------
-- Blacklist
-------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="Blacklist"
}}
defaults[#defaults+1] = {disableauras={
	type="checkbox",
	value=false,
	label="Don't show any auras."
}}
defaults[#defaults+1] = {text = {
	type="text",
	value="Certain abilities are tracked by default, i.e. stuns / silences. You can stop these from showing up using the blacklist. "
}}
defaults[#defaults+1] = {blacklist={
	type="list",
	value={},
	label="Aura Blacklist",
	tooltip="Useful if you want to blacklist any auras that Blizzard tracks by default."
}}


bdCore:addModule("Nameplates", defaults)
local config = bdCore.config.profile['Nameplates']
local scale = UIParent:GetEffectiveScale()*1
C_NamePlate.SetNamePlateFriendlySize(config.width * scale + 10,0.1)
C_NamePlate.SetNamePlateSelfSize(config.width * scale + 10,0.1)
C_NamePlate.SetNamePlateEnemySize(config.width * scale + 10, config.height * scale + config.enemynamesize + 4)

SetCVar('nameplateMotionSpeed', .1)

-- these should be defaulted pretty much always
--SetCVar('nameplateShowSelf', 1)
SetCVar('nameplateOverlapV', GetCVarDefault("nameplateOverlapV"))
SetCVar('nameplateOverlapH', GetCVarDefault("nameplateOverlapH"))
SetCVar('nameplateOtherTopInset', GetCVarDefault("nameplateOtherTopInset"))
SetCVar('nameplateOtherBottomInset', GetCVarDefault("nameplateOtherBottomInset"))
SetCVar('nameplateLargeTopInset', GetCVarDefault("nameplateLargeTopInset"))
SetCVar('nameplateLargeBottomInset', GetCVarDefault("nameplateLargeBottomInset"))

local function cvar_set()
	local cvars = {
		['nameplateSelfAlpha'] = 1,
		['nameplateShowAll'] = 1,
		['nameplateMinAlpha'] = 1,
		['nameplateMaxAlpha'] = 1,
		['nameplateMaxAlphaDistance'] = 0,
		['nameplateMaxDistance'] = config.nameplatedistance+6, -- for some reason there is a 6yd diff
		["nameplateOverlapV"] = config.verticalspacing, --0.8
		['nameplateShowFriends'] = 1,
		['nameplateShowOnlyNames'] = 1,
		['nameplateShowDebuffsOnFriendly'] = 1,
		--['nameplatePersonalShowAlways'] = 1,
		--['nameplateShowSelf'] = 1,
		--["nameplateMotionSpeed"] = config.speed, --0.1
		--["nameplateOverlapH"] = config.spacingH, --0.8
		--['nameplateMotion'] = tonumber(config.nameplatemotion),
		['nameplateMinScale'] = 1, 
		['nameplateMaxScale'] = 1, 
		['nameplateMaxScaleDistance'] = 0, 
		['nameplateMinScaleDistance'] = 0, 
		['nameplateLargerScale'] = 1, -- for bosses
	}
	
	if (not InCombatLockdown()) then
		for k, v in pairs(cvars) do
			local current = tonumber(GetCVar(k))
			if (current ~= tonumber(v)) then
				SetCVar(k, v)
			end
		end
	end
end

local function numberize(v)
	if v <= 9999 then return v end
	if v >= 1000000000 then
		local value = string.format("%.1fb", v/1000000000)
		return value
	elseif v >= 1000000 then
		local value = string.format("%.1fm", v/1000000)
		return value
	elseif v >= 10000 then
		local value = string.format("%.1fk", v/1000)
		return value
	end
end

local addon = CreateFrame("frame")
addon:RegisterEvent("CVAR_UPDATE")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:SetScript("OnEvent",cvar_set)

--[[
local executerange = 20

local talentdetect = CreateFrame("frame")
talentdetect:RegisterEvent('PLAYER_ENTERING_WORLD')
talentdetect:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
talentdetect:RegisterEvent('PLAYER_TALENT_UPDATE')
talentdetect:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
talentdetect:SetScript("OnEvent",function()
	local class = select(2, UnitClass("player"))
	if (class == "PRIEST") then
		local RoS = select(4, GetTalentInfo(4, 2))
		if (RoS) then
			executerange = 35
		else
			executerange = 20
		end
	end
end)
--]]
local function getcolor(unit)
	local reaction = UnitReaction(unit, "player") or 5
	
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		local color = RAID_CLASS_COLORS[class]
		return color.r, color.g, color.b
	elseif UnitCanAttack("player", unit) then
		if UnitIsDead(unit) then
			return 136/255, 136/255, 136/255
		else
			if reaction<4 then
				return 1, 68/255, 68/255
			elseif reaction==4 then
				return 1, 1, 68/255
			end
		end
	else
		if reaction<4 then
			return 48/255, 113/255, 191/255
		else
			return 1, 1, 1
		end
	end
end

local colors = {}
colors.tapped = {.6,.6,.6}
colors.offline = {.6,.6,.6}
colors.reaction = {}
colors.class = {}

for eclass, color in next, RAID_CLASS_COLORS do
	if not colors.class[eclass] then
		colors.class[eclass] = {color.r, color.g, color.b}
	end
end
for eclass, color in next, FACTION_BAR_COLORS do
	if not colors.reaction[eclass] then
		colors.reaction[eclass] = {color.r, color.g, color.b}
	end
end

local function round(num, numDecimalPlaces)
  return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
end


local function unitColor(unit)
	if (not UnitExists(unit)) then
		return unpack(colors.tapped)
	end
	if UnitIsPlayer(unit) then
		return unpack(colors.class[select(2, UnitClass(unit))])
	elseif UnitIsTapDenied(unit) then
		return unpack(colors.tapped)
	else
		return unpack(colors.reaction[UnitReaction(unit, 'player')])
	end
end

local function enemyStlye(self,unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf

	self.Auras:Hide()
	self.Debuffs:Show()
	if (UnitIsUnit(unit,"target")) then
		self:SetAlpha(1)
		self.Health.Shadow:Show()
		self.Health.Shadow:SetBackdropBorderColor(unpack(config.glowcolor))
	else
		self:SetAlpha(config.unselectedalpha)
	end
	
	self.Name:SetTextColor(1,1,1)
	self.Name:ClearAllPoints()
	self.Name:SetFont(bdCore.media.font, config.enemynamesize)
	self.Name:SetShadowColor(0,0,0)
	self.Name:SetPoint("BOTTOM", self, "TOP", 0, 6)	
	self.Castbar:SetAlpha(1)
	self.Health:Show()
end

local function npcStyle(self,unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf
	
	if (UnitIsUnit(unit,"target")) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.8)
	end
	
	self.background:Hide()
	self.Debuffs:Hide()
	self.Auras:Hide()
	self.Health:Hide()
	
	self.Name:SetFont(bdCore.media.font, config.friendlynamesize, "OUTLINE")
	self.Name:SetShadowColor(0,0,0,0)
	self.Name:SetTextColor(unitColor(unit))
	self.Name:ClearAllPoints()
	self.Name:SetPoint("TOP", self, "TOP", 0, 10)	
	self.Castbar:SetAlpha(0)
end
local function playerStyle(self,unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf
	
	self.Name:Hide()
	self.Power:Show()
	self.background:Hide()
	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOP", self, "BOTTOM", 0, -30)
	self.Health:SetSize(config.width, config.height)
	self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 0, -config.castbarheight)
	
	--nameplate:EnableMouse(false)
	--[[self.Debuffs:Hide()
	self.Auras:Show()
	self.Auras:ClearAllPoints()
	self.Auras:SetPoint("BOTTOM", self.Name, "TOP", -2, 10)
	self.Health:Hide()
	self.background:Hide()
	self.Castbar:SetAlpha(0)
	self.Name:Show()
	self.Name:ClearAllPoints()
	self.Name:SetFont(bdCore.media.font, config.friendlynamesize, "OUTLINE")
	self.Name:SetShadowColor(0,0,0,0)
	self.Name:SetTextColor(unitColor(unit))
	self.Namecontainer:SetAlpha(config.friendnamealpha)
	self.RaidIcon:SetAlpha(0)
	
	if (UnitIsUnit("target",unit)) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.8)
	end
	
	nameplate:SetScript("OnUpdate",function()	
		local selfpoint, object, objectpoint, x, y = nameplate:GetPoint()
		self.Name:SetPoint("CENTER", WorldFrame, "CENTER", 0, (30-((y-350)/4))*scale)
	end)--]]
end

-- Style your friends
local function friendlyStyle(self, unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf
	
	--self.Power:Hide()
	self.Debuffs:Hide()
	self.Auras:Show()
	self.Health:Hide()
	
	if (UnitIsUnit(unit,"target")) then
		self:SetAlpha(1)
		--[[if (config.showfriendlybar) then
			self.Health:Show()
			self.Name:ClearAllPoints()
			self.Name:SetPoint("TOP", self, "TOP", 0, 20)
		end	--]]
	else
		self:SetAlpha(0.8)
		self.Health:Hide()
		self.Name:ClearAllPoints()
		self.Name:SetPoint("TOP", self, "TOP", 0, 6)
	end
	
	if (UnitIsUnit(unit,"pet")) then
		self.Health:Show()
	end
	
	self.background:Hide()
	self.Namecontainer:SetAlpha(config.friendnamealpha)
	self.Name:SetTextColor(unitColor(unit))
	self.Name:SetFont(bdCore.media.font, config.friendlynamesize, "OUTLINE")
	self.Name:SetShadowColor(0,0,0,0)
	self.Castbar:SetAlpha(0)
	
	if (config.hidefriendnames and not UnitIsUnit(unit,"target")) then
		self.Name:Hide()
	end
end

local function threatColor(self, forced)
	if (UnitIsPlayer(self.unit)) then return end
	local healthbar = self.Health
	local combat = UnitAffectingCombat("player")
	local threat = select(2, UnitDetailedThreatSituation("player", self.unit));
	local targeted = select(1, UnitDetailedThreatSituation("player", self.unit));
	local reaction = UnitReaction("player", self.unit);
	--local perc = (UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100
	local perc = 100;
	local name = UnitName(self.unit) or "";

	if (UnitIsTapDenied(self.unit)) then
		healthbar:SetStatusBarColor(.5,.5,.5)
	elseif(combat) then 
		if(threat and threat >= 1) then
			if(threat == 3) then
				healthbar:SetStatusBarColor(unpack(config.threatcolor))
			elseif (threat == 2 or threat == 1 or targeted) then
				healthbar:SetStatusBarColor(unpack(config.threatdangercolor))
			end
		else
			healthbar:SetStatusBarColor(unpack(config.nothreatcolor))
			if (config.executerange and perc <= config.executerange) then
				healthbar:SetStatusBarColor(unpack(config.executecolor))
			end
		end
	end
	
	if (name == "Fel Explosives") then
		healthbar:SetStatusBarColor(0.9, .4, 0.9)
	end
	
	self.Fixate:Hide()
	if (config.fixatealert == "Always") then
		self.Fixate:Show()
		self.Fixate.text:SetText(UnitName(self.unit.."target"))
	end
	if (fixateMobs[name] and UnitExists(self.unit.."target")) then
		if (config.fixatealert == "All") then
			self.Fixate:Show()
			self.Fixate.text:SetText(UnitName(self.unit.."target"))
		elseif (config.fixatealert == "Personal" and UnitIsUnit(self.unit.."target","player")) then
			self.Fixate:Show()
			self.Fixate.text:SetText(UnitName(self.unit.."target"))
		end
	end
	
	if (not forced and healthbar.ForceUpdate) then
		healthbar:ForceUpdate()
	end
end

local function kickable(self)
	if (self.notInterruptible) then
		self.Icon:SetDesaturated(1)
		self:SetStatusBarColor(unpack(config.nonkickable))
	else
		self.Icon:SetDesaturated(false)
		self:SetStatusBarColor(unpack(config.kickable))
	end
end

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function style(self, unit)
	local scale = UIParent:GetEffectiveScale()*1
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local main = self
	self.styled = true
	nameplate.ouf = self
	--self:RegisterForClicks('AnyDown')
	
	-- Circle Alert
	--[[
	self.Circle = CreateFrame("frame",nil,self)
	self.Circle:SetAlpha(0.8)
	self.Circle:SetFrameLevel(1)
	self.Circle.parent = self
	self.Circle.tex = self.Circle:CreateTexture(nil,"OVERLAY")
	self.Circle.tex:SetAllPoints()
	self.Circle.tex:SetTexture("Interface\\Addons\\bdNameplates\\circle.blp")
	self.Circle.tex:SetVertexColor(0,0,0,1)
	self.Circle.SetYards = function(self,yards)
		self:SetSize(50*yards,50*yards)
		self:SetPoint("CENTER", self.parent.Name, "CENTER", 0, -30)
	end
	self.Circle.SetColor = function(self,...)
		self.tex:SetVertexColor(...)
	end
	self.Circle.SetType = function(self,type)
		if (type == "Circle" or type == 1) then
			self.tex:SetTexture("Interface\\Addons\\bdNameplates\\circle.blp")
		elseif (type == "Ring" or type == 2) then
			self.tex:SetTexture("Interface\\Addons\\bdNameplates\\ring.blp")
		end
	end
	
	self.Circle:RegisterEvent("ENCOUNTER_END")
	self.Circle:RegisterEvent("PLAYER_TARGET_CHANGED")
	self.Circle:SetScript("OnUpdate",function(self,event)
		if (event == "ENCOUNTER_END") then
			for _, frame in pairs(C_NamePlate.GetNamePlates()) do
				local unit = frame.unitFrame.unit
				local ouf = frame.ouf
				ouf.Circle:Hide()
			end
		else
			if (UnitIsUnit(unit,"target")) then
				self:SetAlpha(config.unselectedalpha)
			else
				self:SetAlpha(0.8)
			end
		end
	end)
	self.Circle:Hide()
	--]]

	self:EnableMouse(false)
	
	self.background = self:CreateTexture(nil, "BACKGROUND", nil, -7)
	self.background:SetTexture(bdCore.media.flat)
	self.background:SetAllPoints(self)
	self.background:SetVertexColor(0,1,0,.3)

	self.unit = unit
	self:SetScript("OnEnter", function()
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetUnit(self.unit)
		GameTooltip:Show()
	end)
	self:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	self.hooked = true
	
	self:SetPoint("BOTTOMLEFT",nameplate,"BOTTOMLEFT", 2, 2)
	self:SetPoint("BOTTOMRIGHT",nameplate,"BOTTOMRIGHT", -2, 2)
	self:SetScale(scale)
	self:SetHeight(config.height)
	
	self.Namecontainer = CreateFrame("frame",nil,self)
	self.Name = self.Namecontainer:CreateFontString(nil)
	self.Name:SetFont(bdCore.media.font, 14)
	self.Name:SetShadowOffset(1,-1)
	self:Tag(self.Name, '[name]')
	
	oUF.Tags.Events['bdncurhp'] = 'UNIT_HEALTH_FREQUENT UNIT_HEALTH UNIT_MAXHEALTH PLAYER_TARGET_CHANGED'
	oUF.Tags.Methods['bdncurhp'] = function(unit)
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		local hpPercent = hp / hpMax
		if hpMax == 0 then return end
		
		if (config.hptext == "None") then
			return ""
		elseif (config.hptext == "HP - %") then
			return numberize(hp).." - "..round(hpPercent * 100,1);
		elseif (config.hptext == "HP") then
			return numberize(hp);
		elseif (config.hptext == "%") then
			return round(hpPercent * 100,1);
		end
		
	end

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdCore.media.smooth)
	self.Health:SetAllPoints(self)
	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorHealth = true
	bdCore:setBackdrop(self.Health,true)
	self.Health:EnableMouse(false)

	
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(bdCore.media.flat)
	self.Power:ClearAllPoints()
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT",0, -2)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT",0, -2)
	self.Power:SetHeight(6)
	self.Power.frequentUpdates = true
	self.Power.colorTapping = true
	self.Power.colorDisconnected = true
	self.Power.colorPower = true
	self.Power.colorReaction = true
	self.Power.colorClass = true
	bdCore:setBackdrop(self.Power)
	self.Power:Hide()

	
	self.Curhp = self.Health:CreateFontString(nil,"OVERLAY")
	self.Curhp:SetFont(bdCore.media.font, 12,"OUTLINE")
	self.Curhp:SetJustifyH("RIGHT")
	self.Curhp:SetShadowColor(0,0,0,0)
	self.Curhp:SetAlpha(0.8)
	self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
	self:Tag(self.Curhp, '[bdncurhp]')
	
	bdCore:createShadow(self.Health,10)
	self.Health.Shadow:SetBackdropColor(1, 1, 1, 1)
	self.Health.Shadow:SetBackdropBorderColor(1, 1, 1, 0.8)
	
	self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	self.Health:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("PLAYER_TARGET_CHANGED",function(self)
		npcallback("","",self.unit,self)
	end)
	
	self.Health:SetScript("OnEvent",function()
		threatColor(main)
	end)
	function self.Health:PostUpdate()
		threatColor(main,true)
	end
	
	-- Fixate Alert
	self.Fixate = CreateFrame("frame",nil,self)
	self.Fixate:SetFrameLevel(4)
	self.Fixate:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -20)
	self.Fixate:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -8)
	self.Fixate:SetFrameLevel(100)
	self.Fixate.text = self.Fixate:CreateFontString(nil, "OVERLAY")
	self.Fixate.text:SetFont(bdCore.media.font, 18, "OUTLINE")
	local icon = select(3, GetSpellInfo(210099))
	self.Fixate.text.SetText_Old = self.Fixate.text.SetText
	self.Fixate.text.SetText = function(self,text)
		local color = bdCore:RGBToHex(unitColor(text))
		if (UnitIsUnit(text,"player")) then
			self:SetAlpha(1)
			self:SetText_Old("|T"..icon..":16:16:0:0:60:60:4:56:4:56|t ".."|cff"..color..text.."|r")
		else
			self:SetAlpha(0.8)
			self:SetText_Old("|cff"..color..text.."|r")
		end
	end
	self.Fixate.text:SetAllPoints(self.Fixate)
	self.Fixate.text:SetJustifyH("CENTER")
	self.Fixate:Hide()
	self.fixated = false;
	
	-- Absorb
	self.TotalAbsorb = CreateFrame('StatusBar', nil, self.Health)
	self.TotalAbsorb:SetAllPoints(self.Health)
	self.TotalAbsorb:SetStatusBarTexture(bdCore.media.flat)
	self.TotalAbsorb:SetStatusBarColor(.1,.1,.1,.6)
	
	-- Raid Icon
	self.RaidIcon = self:CreateTexture(nil, "OVERLAY",nil,7)
	self.RaidIcon:SetSize(config.raidmarkersize, config.raidmarkersize)
	if (config.markposition == "LEFT") then
		self.RaidIcon:SetPoint('LEFT', self, "RIGHT", -(config.raidmarkersize/2), 0)
	elseif (config.markposition == "RIGHT") then
		self.RaidIcon:SetPoint('RIGHT', self, "LEFT", config.raidmarkersize/2, 0)
	else
		self.RaidIcon:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
	end
	
	-- Quest indicator
	--[[self.Quest = CreateFrame("frame", nil, self.Health)
	self.Quest:SetSize(20,20)
	self.Quest:SetPoint("RIGHT", self.name, "LEFT", -6, 0)
	bdCore:setBackdrop(self.Quest)--]]	
	
	-- For friendlies
	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetPoint("BOTTOM", self, "TOP", -2, 18)
	self.Auras:SetSize((config.raidbefuffs*2)+4, config.raidbefuffs)
	self.Auras:EnableMouse(false)
	self.Auras.size = config.raidbefuffs
	self.Auras.initialAnchor  = "BOTTOM"
	self.Auras.spacing = 2
	self.Auras.num = 20
	self.Auras['growth-y'] = "UP"
	self.Auras['growth-x'] = "RIGHT"
	self.Auras.CustomFilter = function(icons, unit, icon, name, rank, texture, count, dispelType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,timeMod, effect1, effect2, effect3)
		local allow = false
		
		if (raidwhitelist[name] or raidwhitelist[spellID]) then
			allow = true
		end
		if (config.whitelist and config.whitelist[name]) then
			allow = true
		end
		if (config.selfwhitelist and (config.selfwhitelist[name] and caster == "player")) then
			allow = true
		end
		if (config.automydebuff and caster == "player") then
			allow = true
		end
		if (config.blacklist and config.blacklist[name]) then
			allow = false
		end
		
		return allow
	end
	
	self.Auras.PostUpdateIcon = function(Auras, unit, button, index)
		local cdtext = button.cd:GetRegions()
		bdCore:setBackdrop(button)
		cdtext:SetFont(bdCore.media.font,14,"OUTLINE")
		cdtext:SetShadowColor(0,0,0,0)
		cdtext:SetJustifyH("CENTER")
		cdtext:ClearAllPoints()
		cdtext:SetAllPoints(button)
		
		button.count:SetFont(bdCore.media.font,12,"OUTLINE")
		button.count:SetShadowColor(0,0,0,0)
		button.count:SetJustifyH("RIGHT")
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		
		button:EnableMouse(false)
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(false)
	end
	
	-- For Enemies
	self.Debuffs = CreateFrame("Frame", nil, self)
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
	self.Debuffs:SetSize(config.width, config.debuffsize)
	self.Debuffs:EnableMouse(false)
	self.Debuffs.size = config.debuffsize
	self.Debuffs.initialAnchor  = "BOTTOMLEFT"
	self.Debuffs.spacing = 2
	self.Debuffs.num = 20
	self.Debuffs['growth-y'] = "UP"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs.CustomFilter = function(icons, unit, icon, name, rank, texture, count, dispelType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,timeMod, effect1, effect2, effect3)
		
		local allow = false
		
		if (nameplateShowAll or (nameplateShowSelf and caster == "player")) then
			allow = true
		end
		if (config.whitelist and config.whitelist[name]) then
			allow = true
		end
		if (config.selfwhitelist and (config.selfwhitelist[name] and caster == "player")) then
			allow = true
		end
		if (config.blacklist and config.blacklist[name]) then
			allow = false
		end
		
		return allow
	end
	
	
	self.Debuffs.PostUpdateIcon = function(self, unit, button, index)
		local cdtext = button.cd:GetRegions()
		bdCore:setBackdrop(button)
		cdtext:SetFont(bdCore.media.font,14,"OUTLINE")
		cdtext:SetShadowColor(0,0,0,0)
		cdtext:SetJustifyH("LEFT")
		cdtext:ClearAllPoints()
		cdtext:SetPoint("TOPLEFT",button,"TOPLEFT",-1,8)
		
		button.count:SetFont(bdCore.media.font,12,"OUTLINE")
		button.count:SetTextColor(1,.8,.3)
		button.count:SetShadowColor(0,0,0,0)
		button.count:SetJustifyH("RIGHT")
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -1)
		
		button:EnableMouse(false)
		button.icon:SetTexCoord(0.08, 0.9, 0.20, 0.74)
		button:SetHeight(config.debuffsize*.6)
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(false)
	end
	
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(bdCore.media.flat)
	self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
	bdCore:setBackdrop(self.Castbar)
	
	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFont(bdCore.media.font, config.castbarheight*0.85, "OUTLINE")
	self.Castbar.Text:SetJustifyH("RIGHT")
	self.Castbar.Text:SetPoint("CENTER", self.Castbar, "CENTER")
	
	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Castbar.Icon:SetDrawLayer('ARTWORK')
	self.Castbar.Icon:SetSize(config.height+12, config.height+12)
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT",self.Castbar, "BOTTOMLEFT", -2, 0)
	
	self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.bg:SetTexture(bdCore.media.flat)
	self.Castbar.bg:SetVertexColor(unpack(bdCore.media.border))
	self.Castbar.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdCore.config.profile.General.border, bdCore.config.profile.General.border)
	self.Castbar.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdCore.config.profile.General.border, -bdCore.config.profile.General.border)
	
	self.Castbar.PostChannelStart = kickable
	self.Castbar.PostChannelUpdate = kickable
	self.Castbar.PostCastStart = kickable
	self.Castbar.PostCastDelayed = kickable
	self.Castbar.PostCastNotInterruptible = kickable
	self.Castbar.PostCastInterruptible = kickable
end

local function npcallback(self, event, unit)
	config = bdCore.config.profile['Nameplates']
	local scale = UIParent:GetEffectiveScale()*1
	if (not InCombatLockdown()) then
		C_NamePlate.SetNamePlateFriendlySize(config.width * scale + 10,0.1)
		C_NamePlate.SetNamePlateEnemySize(config.width * scale + 10, config.height * scale + config.enemynamesize + 4)
		C_NamePlate.SetNamePlateFriendlyClickThrough(true)
	end
	
	if (unit) then
		local unit = unit or "target"
		local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
		--print(nameplate.ouf)
		--local self = nameplate.ouf
		local reaction = UnitReaction("player",unit)
		--local ufaction = select(1, UnitFactionGroup(unit))
		--local pfaction = select(1, UnitFactionGroup("player"))
		self.Health.Shadow:Hide()
		self:EnableMouse(false)
		self.Health:EnableMouse(false)
		self.Name:Show()
		self.Namecontainer:SetAlpha(1)
		-- Update configurations
		self:SetHeight(config.height)
		self.Curhp:SetFont(bdCore.media.font, config.height*.85,"OUTLINE")
		self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
		self.Castbar.Text:SetFont(bdCore.media.font, config.castbarheight*.85, "OUTLINE")
		self.Castbar.Icon:SetSize(config.height+config.castbarheight, config.height+config.castbarheight)
		self.Auras:SetSize((config.raidbefuffs*2)+4, config.raidbefuffs)
		self.Auras.size = config.raidbefuffs
		self.Debuffs:SetSize(config.width+4, config.debuffsize)
		self.Debuffs.size = config.debuffsize
		self.RaidIcon:SetSize(config.raidmarkersize, config.raidmarkersize)
		self.RaidIcon:ClearAllPoints()
		self.RaidIcon:SetAlpha(1)
		if (config.markposition == "LEFT") then
			self.RaidIcon:SetPoint('RIGHT', self, "LEFT", -(config.raidmarkersize/2), 0)
		elseif (config.markposition == "RIGHT") then
			self.RaidIcon:SetPoint('LEFT', self, "RIGHT", config.raidmarkersize/2, 0)
		else
			self.RaidIcon:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
		end
		
		if (config.hptext == "None" or (config.showhptexttargetonly and not UnitIsUnit(unit,"target"))) then
			self.Curhp:Hide()
		else
			self.Curhp:Show()
		end
		
		
		
		--IsUnitOnQuest
		-- self.Quest:Hide()
		-- for q = 1, GetNumQuestLogEntries() do	
			-- if (IsUnitOnQuest(q,unit) == 1) then
				-- self.Quest:Show()
				-- break
			-- end
		-- end
		-- not UnitIsCharmed(unit) or
		
		nameplate:SetScript("OnUpdate",function() return end)
		self.Name:Show()
		self.Power:Hide()
		if (UnitIsUnit(unit,"player")) then
			--print("playerstyle"..UnitName(unit))
			playerStyle(self,unit)
		elseif (UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend("player",unit) and reaction and reaction >= 5)) then
			--print("friendlystyle"..UnitName(unit))
			friendlyStyle(self, unit)
		elseif (not UnitIsPlayer(unit) and (reaction and reaction >= 5) or ufaction == "Neutral") then
			--print("npcstyle"..UnitName(unit))
			npcStyle(self, unit)
		else
			--print("enemystyle"..UnitName(unit))
			enemyStlye(self,unit)
		end
		
		if (config.disableauras) then
			self.Debuffs:Hide()
		end
	end
	
	cvar_set()
end


bdCore:hookEvent("nameplate_update",enumerateNameplates)
bdCore:hookEvent("bd_reconfig", enumerateNameplates)

local tchange = CreateFrame("frame",nil,UIParent)
oUF:RegisterStyle("bdNameplates", style) --styleName: String, styleFunc: Function
oUF:SetActiveStyle("bdNameplates")
oUF:SpawnNamePlates("bdNameplates", npcallback)