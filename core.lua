local addon, bdNameplates = ...
bdNameplates.cache = {}
local bdCore = bdCore
local oUF = bdCore.oUF
local config = bdCore.config.profile['Nameplates']
local borderSize = bdCore.config.persistent.General.border

--[[
	performance notes for myself
	-lua is a funny language, localizing variables function calls is a big performance increase
	-local variables are accessed MUCH faster (anywhere from 30-300% faster)
	-table resizing is really expensive, try to create tables at the correct size. better still, instantiate table structures with a local table template var
	-tables don't get their size unset when they are set to nil, collect garbage at good times or only use correctly-sized tables
	-string concatenation through s = s + s2 is fucking terrible, instead store strings into table keys and use table.concat
	-table lists (keyless) are smaller and faster than associative tables
	-string.match is faster than string.find
	-look into cooroutines for some tasks
	-would be great if wow team could implement jit, though i don't think x64 supports it yet? (need to check)
--]]

-- lua functions
local unpack, floor = unpack, math.floor

-- blizz functions
local GetCVar, SetCVar, UnitThreatSituation, UnitAffectingCombat, UnitHealth, UnitHealthMax, UnitPlayerControlled, UnitIsTapDenied, UnitIsPlayer, UnitClass, UnitReaction, UnitIsUnit, UnitIsPlayer, UnitIsFriend, UnitIsPVPSanctuary, UnitName, C_NamePlate, UnitGUID = GetCVar, SetCVar, UnitThreatSituation, UnitAffectingCombat, UnitHealth, UnitHealthMax, UnitPlayerControlled, UnitIsTapDenied, UnitIsPlayer, UnitClass, UnitReaction, UnitIsUnit, UnitIsPlayer, UnitIsFriend, UnitIsPVPSanctuary, UnitName, C_NamePlate, UnitGUID

-- Features to reimplement
-- Fixate alerts
-- Circle module
-- Special Units
-- Special Spells
-- Absorbs

-- Fonts we use
bdNameplates.font = CreateFont("BDN_FONT")
bdNameplates.font:SetFont(bdCore.media.font, config.enemynamesize)
bdNameplates.font:SetShadowColor(0, 0, 0)
bdNameplates.font:SetShadowOffset(1, -1)

bdNameplates.font_friendly = CreateFont("BDN_FONT_FRIENDLY")
bdNameplates.font_friendly:SetFont(bdCore.media.font, config.friendlynamesize)
bdNameplates.font_friendly:SetShadowColor(0, 0, 0)
bdNameplates.font_friendly:SetShadowOffset(1, -1)

bdNameplates.font_small = CreateFont("BDN_FONT_SMALL")
bdNameplates.font_small:SetFont(bdCore.media.font, 13)
bdNameplates.font_small:SetShadowColor(0, 0, 0)
bdNameplates.font_small:SetShadowOffset(1, -1)

bdNameplates.font_castbar = CreateFont("BDN_FONT_CASTBAR")
bdNameplates.font_castbar:SetFont(bdCore.media.font, config.castbarheight*0.85)
bdNameplates.font_castbar:SetShadowColor(0, 0, 0)
bdNameplates.font_castbar:SetShadowOffset(1, -1)

-- Scale of the UI here
local screenWidth, screenHeight = GetPhysicalScreenSize()
bdNameplates.scale = min(1.15, 768/screenHeight)

-- Scale the default nameplate parameters - note this doesn't seem to do anything on load, so investigating
local function nameplateSize(self)
	if (not InCombatLockdown()) then return end
	if (self) then
		self:SetSize(config.width, config.height)
	end

	C_NamePlate.SetNamePlateFriendlySize(config.width * bdNameplates.scale, 0.1)
	C_NamePlate.SetNamePlateEnemySize(config.width * bdNameplates.scale, config.height * bdNameplates.scale)
	C_NamePlate.SetNamePlateSelfSize(config.width * bdNameplates.scale, config.height * bdNameplates.scale)
	C_NamePlate.SetNamePlateFriendlyClickThrough(true)
	C_NamePlate.SetNamePlateSelfClickThrough(true)
end
bdNameplates.eventer = CreateFrame("frame", nil)
bdNameplates.eventer:RegisterEvent("PLAYER_REGEN_ENABLED", nameplateSize)
bdNameplates.eventer:RegisterEvent("PLAYER_LOGIN", nameplateSize)

-- CVar default for things that really never need changing
SetCVar('nameplateMotionSpeed', .1)
SetCVar('nameplateOverlapV', GetCVarDefault("nameplateOverlapV"))
SetCVar('nameplateOverlapH', GetCVarDefault("nameplateOverlapH"))
SetCVar('nameplateOtherTopInset', GetCVarDefault("nameplateOtherTopInset"))
SetCVar('nameplateOtherBottomInset', GetCVarDefault("nameplateOtherBottomInset"))
SetCVar('nameplateLargeTopInset', GetCVarDefault("nameplateLargeTopInset"))
SetCVar('nameplateLargeBottomInset', GetCVarDefault("nameplateLargeBottomInset"))

function bdNameplates:configCallback()
	nameplateSize()

	-- update font sizes
	bdNameplates.font:SetFont(bdCore.media.font, config.enemynamesize)
	bdNameplates.font_small:SetFont(bdCore.media.font, config.height * 0.85)
	bdNameplates.font_castbar:SetFont(bdCore.media.font, config.castbarheight*0.85)
	bdNameplates.font_friendly:SetFont(bdCore.media.font, config.friendlynamesize)

	-- set cVars
	local cvars = {
		['nameplateSelfAlpha'] = 1,
		['nameplateShowAll'] = 1,
		['nameplateMinAlpha'] = 1,
		['nameplateMaxAlpha'] = 1,
		['nameplateOccludedAlphaMult'] = 1,
		['nameplateMaxAlphaDistance'] = 1,
		['nameplateMaxDistance'] = config.nameplatedistance+6, -- for some reason there is a 6yd diff
		["nameplateOverlapV"] = config.verticalspacing, --0.8
		['nameplateShowOnlyNames'] = 0,
		['nameplateShowDebuffsOnFriendly'] = 0,
		['nameplateMinScale'] = 1, 
		['nameplateMaxScale'] = 1, 
		['nameplateMaxScaleDistance'] = 0, 
		['nameplateMinScaleDistance'] = 0, 
		['nameplateLargerScale'] = 1, -- for bosses
		['nameplateShowOnlyNames'] = config.friendlynamehack and 1 or 0, -- friendly names and no plates in raid
	}
	-- loop through and set CVARS
	if (not InCombatLockdown()) then
		for k, v in pairs(cvars) do
			SetCVar(k, v)
		end
	end

end
bdNameplates:configCallback()

--==========================================
-- HEALTH UPDATER
--- Calls on 
---- more than it ought to by default
---- NAME_PLATE_UNIT_ADDED
---- UNIT_THREAT_LIST_UPDATE
---- UNIT_HEALTH_FREQUENT
--==========================================
local colorCache = {}
local function nameplateUpdateHealth(self, event, unit)
	if(not unit or self.unit ~= unit) then return end
	if (event == "NAME_PLATE_UNIT_REMOVED") then return end
	if (event == "OnShow") then return end
	if (event == "OnUpdate") then return end

	local healthbar = self.Health
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	healthbar:SetMinMaxValues(0, max)
	healthbar:SetValue(cur)

	local tapDenied = UnitIsTapDenied(unit) or false
	local isPlayer = UnitIsPlayer(unit) and select(2, UnitClass(unit)) or false
	local reaction = UnitReaction("player", unit) or false
	local status = UnitThreatSituation("player", unit)
	if (status == nil) then
		status = false
	end

	local colors = bdNameplates:unitColor(tapDenied, isPlayer, reaction, status)
	healthbar:SetStatusBarColor(unpack(colors))

-- 	function bdNameplates:unitColor(unit)
-- 	if(not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
-- 		return unpack(colors.tapped)
-- 	elseif UnitIsPlayer(unit) then
-- 		return unpack(colors.class[select(2, UnitClass(unit))])
-- 	else
-- 		return unpack(colors.reaction[UnitReaction(unit, 'player')])
-- 	end
-- end

-- 	if (unit == 'player' or UnitIsUnit('player', unit) or UnitIsFriend('player', unit) or status == nil) then
-- 		self.Health:SetStatusBarColor(bdNameplates:unitColor(unit))
-- 	elseif (status ~= nil and not UnitIsTapDenied(unit) and not UnitIsPlayer(unit) and (event == "UNIT_THREAT_LIST_UPDATE" or event == "NAME_PLATE_UNIT_ADDED")) then
-- 		if (status == 3) then
-- 			-- securely tanking
-- 			healthbar:SetStatusBarColor(unpack(config.threatcolor))
-- 		elseif (status == 2 or status == 1) then
-- 			-- near or over tank threat
-- 			healthbar:SetStatusBarColor(unpack(config.threatdangercolor))
-- 		else
-- 			-- on threat table, but not near tank threat
-- 			healthbar:SetStatusBarColor(unpack(config.nothreatcolor))
-- 		end
-- 	end

end


-- idk if we'll use this yet, but basically we can theoretically cache units to see if units have changed but kept the same id
-- local function unitID(unitUID)
	-- return memoize(function(unitUID)
		-- return select(1, strsplit(":", unitUID))
	-- end)
-- end
-- local function unitUID(unit)
	-- local GUID = UnitGUID(unit)
	-- return memoize(function(unit, GUID)
		-- local uid = {unit, GUID}
		-- return table.concat(uid,":")
	-- end)
-- end



--==========================================
-- MAIN CALLBACK
--- Calls on 
---- NAME_PLATE_UNIT_ADDED
---- NAME_PLATE_UNIT_REMOVED
---- PLAYER_TARGET_CHANGED
--==========================================
local function nameplateCallback(self, event, unit)

	-- Force cvars/settings
	nameplateSize(self)

	if (not self) then return end
	unit = unit or self.unit
	local reaction = UnitReaction("player", unit)

	--==========================================
	-- Configuration Updates First
	--==========================================
	self.Auras.size = config.raidbefuffs
	self.Auras.showStealableBuffs = config.highlightPurge
	self.RaidTargetIndicator:SetSize(config.raidmarkersize, config.raidmarkersize)
	self.RaidTargetIndicator:ClearAllPoints()
	if (config.markposition == "LEFT") then
		self.RaidTargetIndicator:SetPoint('RIGHT', self, "LEFT", -(config.raidmarkersize/2), 0)
	elseif (config.markposition == "RIGHT") then
		self.RaidTargetIndicator:SetPoint('LEFT', self, "RIGHT", config.raidmarkersize/2, 0)
	else
		self.RaidTargetIndicator:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
	end
	if (config.hptext == "None" or (config.showhptexttargetonly and not UnitIsUnit(unit, "target"))) then
		self.Curhp:Hide()
	else
		self.Curhp:Show()
	end

	--==========================================
	-- Style by unit type
	--==========================================
	if (UnitIsUnit(unit,"player")) then
		bdNameplates:personalStyle(self, event, unit)
	elseif (UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend("player",unit) and reaction and reaction >= 5)) then
		bdNameplates:friendlyStyle(self, event, unit)
	elseif (not UnitIsPlayer(unit) and (reaction and reaction >= 5) or ufaction == "Neutral") then
		bdNameplates:npcStyle(self, event, unit)
	else
		bdNameplates:enemyStyle(self, event, unit)
	end

	--==========================================
	-- Overrides
	--==========================================
	-- disabled auras
	if (config.disableauras) then
		self.Auras:Hide()
	end

	-- Highlight targeted unit
	if (UnitIsUnit("target", unit)) then
		self:SetAlpha(1)
		self.Health.Shadow:Show()
		self.Health.Shadow:SetBackdropBorderColor(unpack(config.glowcolor))
	else
		self:SetAlpha(config.unselectedalpha)
		self.Health.Shadow:Hide()
	end

	-- special unit
	if (config.specialunits[UnitName(unit)]) then
		self.specialUnit = true
	else
		self.specialUnit = false
	end

end

--==========================================
-- NAMEPLATE CREATE
--- Calls when a new nameplate frame gets created
--==========================================
local function auraFilter(self, name, caster, debuffType, isStealable, nameplateShowSelf, nameplateShowAll)
	-- blacklist is priority
	if (config.blacklist and config.blacklist[name]) then return false end
	-- purgable spell, whitelist it
	if (config.highlightPurge and isStealable) then return true end
	-- this is an enrage
	if (config.highlightEnrage and debuffType == "") then return true end
	-- if we've whitelisted this inside of bdCore defaults
	if (bdNameplates.forcedWhitelist[name]) then return true end
	-- if the user has whitelisted this
	if (config.whitelist and config.whitelist[name]) then return true end
	-- automatically display buffs cast by the player in config
	if (config.automydebuff and caster == "player") then return true end
	-- show if blizzard decided that it was a self-show or all-show aira 
	if (nameplateShowAll or (nameplateShowSelf and caster == "player")) then return true end
	-- if this is whitelisted for their own casts
	if (config.selfwhitelist and (config.selfwhitelist[name] and caster == "player")) then return true end

	return false
end
bdNameplates.auraFilter = memoize(auraFilter, bdNameplates.cache)

local function nameplateCreate(self, unit)
	self.nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	self.scale = bdNameplates.scale
	self.unit = unit
	
	self:SetPoint("CENTER", self.nameplate, "CENTER", 0, 0)
	self:SetSize(config.width, config.height)
	self:SetScale(self.scale)
	self:EnableMouse(false)

	--==========================================
	-- HEALTHBAR
	--==========================================
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdCore.media.smooth)
	self.Health:SetAllPoints(self)
	-- self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	bdCore:createShadow(self.Health, 10)
	bdCore:setBackdrop(self.Health)
	self.Health.Shadow:SetBackdropColor(1, 1, 1, 1)
	self.Health.Shadow:SetBackdropBorderColor(1, 1, 1, 0.8)

	--==========================================
	-- CALLBACKS
	--==========================================
	-- targeting callback
	self:RegisterEvent("PLAYER_TARGET_CHANGED", nameplateCallback)

	-- coloring callbacks
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", nameplateUpdateHealth)
	self.Health.Override = nameplateUpdateHealth
	
	--==========================================
	-- POWERBAR
	--==========================================
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(bdCore.media.flat)
	self.Power:ClearAllPoints()
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT",0, -2)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT",0, -2)
	self.Power:SetHeight(6)
	self.Power.displayAltPower = true
	self.Power.colorPower = true
	self.Power:Hide()
	bdCore:setBackdrop(self.Power)

	--==========================================
	-- UNIT NAME
	--==========================================
	self.Name = self:CreateFontString(nil, "OVERLAY", "BDN_FONT")
	self.Name:SetPoint("BOTTOM", self, "TOP", 0, 6)	
	self:Tag(self.Name, '[name]')

	--==========================================
	-- UNIT HEALTH
	--==========================================
	self.Curhp = self.Health:CreateFontString(nil, "OVERLAY", "BDN_FONT_SMALL")
	self.Curhp:SetJustifyH("RIGHT")
	self.Curhp:SetAlpha(0.8)
	self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)

	oUF.Tags.Events['bdncurhp'] = 'UNIT_HEALTH'
	oUF.Tags.Methods['bdncurhp'] = function(unit)
		if (config.hptext == "None") then return '' end
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		local hpPercent = bdNameplates:round(hp / hpMax * 100,1)
		hp = bdNameplates:numberize(hp)
		
		if (config.hptext == "HP - %") then
			return table.concat({hp, hpPercent}, " - ")
		elseif (config.hptext == "HP") then
			return hp
		elseif (config.hptext == "%") then
			return hpPercent
		end
	end
	self:Tag(self.Curhp, '[bdncurhp]')

	--==========================================
	-- UNIT POWER
	--==========================================
	self.Curpower = self.Health:CreateFontString(nil, "OVERLAY", "BDN_FONT_SMALL")
	self.Curpower:SetJustifyH("LEFT")
	self.Curpower:SetAlpha(0.8)
	self.Curpower:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
	local pp, ppMax, ppPercent
	oUF.Tags.Events['bdncurpower'] = 'UNIT_POWER_UPDATE'
	oUF.Tags.Methods['bdncurpower'] = function(unit)
		if (not config.showenergy) then return '' end
		pp, ppMax, ppPercent = UnitPower(unit), UnitPowerMax(unit), 0
		if (pp == 0 or ppMax == 0) then return '' end
		ppPercent = (pp / ppMax) * 100

		return floor(ppPercent);
	end
	self:Tag(self.Curpower, '[bdncurpower]')

	-- Raid Marker
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
	self.RaidTargetIndicator:SetSize(config.raidmarkersize, config.raidmarkersize)
	if (config.markposition == "LEFT") then
		self.RaidTargetIndicator:SetPoint('LEFT', self, "RIGHT", -(config.raidmarkersize/2), 0)
	elseif (config.markposition == "RIGHT") then
		self.RaidTargetIndicator:SetPoint('RIGHT', self, "LEFT", config.raidmarkersize/2, 0)
	else
		self.RaidTargetIndicator:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
	end

	--==========================================
	-- AURAS
	--==========================================
	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(0)
	self.Auras:ClearAllPoints()
	self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
	self.Auras:SetSize(config.width, config.raidbefuffs)
	self.Auras:EnableMouse(false)
	self.Auras.size = config.raidbefuffs
	self.Auras.initialAnchor  = "BOTTOMLEFT"
	self.Auras.showStealableBuffs = config.highlightPurge
	self.Auras.disableMouse = true
	self.Auras.spacing = 2
	self.Auras.num = 20
	self.Auras['growth-y'] = "UP"
	self.Auras['growth-x'] = "RIGHT"

	self.specialExpiration = 0
	self.enrageExpiration = 0
	
	

	self.Auras.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3)
		debuffType = debuffType or false
		caster = caster or false
		isStealable = isStealable or false
		nameplateShowSelf = nameplateShowSelf or false
		nameplateShowAll = nameplateShowAll or false

		return bdNameplates:auraFilter(name, caster, debuffType, isStealable, nameplateShowSelf, nameplateShowAll)
	end
	
	self.Auras.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		button:SetHeight(config.raidbefuffs*.6)
		bdCore:setBackdrop(button)
		if (config.highlightPurge and isStealable) then
			button.border:SetVertexColor(.16, .5, .81, 1)
		else
			button.border:SetVertexColor(unpack(bdCore.media.border))
		end

		if (button.skinned) then return end
		
		local cdtext = button.cd:GetRegions()
		cdtext:SetFontObject("BDN_FONT_SMALL") 
		cdtext:SetJustifyH("CENTER")
		cdtext:ClearAllPoints()
		cdtext:SetAllPoints(button)
		
		button.count:SetFontObject("BDN_FONT_SMALL") 
		button.count:SetTextColor(1,.8,.3)
		button.count:SetJustifyH("RIGHT")
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		
		button.icon:SetTexCoord(0.08, 0.9, 0.20, 0.74)
		
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(false)

		button.skinned = true
	end

	--==========================================
	-- CASTBARS
	--==========================================
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(bdCore.media.flat)
	self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
	bdCore:setBackdrop(self.Castbar)
	
	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", "BDN_FONT_CASTBAR")
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
	self.Castbar.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -borderSize, borderSize)
	self.Castbar.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", borderSize, -borderSize)

	-- Change color if cast is kickable or not
	function self.Castbar:kickable(unit, name)
		if (self.notInterruptible) then
			self.Icon:SetDesaturated(1)
			self:SetStatusBarColor(unpack(config.nonkickable))
		else
			self.Icon:SetDesaturated(false)
			self:SetStatusBarColor(unpack(config.kickable))
		end
	end	
	self.Castbar.PostChannelStart = self.Castbar.kickable
	self.Castbar.PostCastStart = self.Castbar.kickable
	self.Castbar.PostCastNotInterruptible = self.Castbar.kickable
	self.Castbar.PostCastInterruptible = self.Castbar.kickable
end

oUF:RegisterStyle("bdNameplates", nameplateCreate)
oUF:SetActiveStyle("bdNameplates")
oUF:SpawnNamePlates("bdNameplates", nameplateCallback)