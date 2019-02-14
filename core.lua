local addon, bdNameplates = ...
bdNameplates.cache = {}
local bdCore = bdCore
local oUF = bdCore.oUF
local config = bdConfigLib:GetSave('Nameplates')
local borderSize = bdConfigLib:GetSave("bdAddons").border or 2

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
bdNameplates.font_small:SetFont(bdCore.media.font, 10 + config.height * 0.25)
bdNameplates.font_small:SetShadowColor(0, 0, 0)
bdNameplates.font_small:SetShadowOffset(1, -1)

bdNameplates.font_castbar = CreateFont("BDN_FONT_CASTBAR")
bdNameplates.font_castbar:SetFont(bdCore.media.font, config.castbarheight * 0.85)
bdNameplates.font_castbar:SetShadowColor(0, 0, 0)
bdNameplates.font_castbar:SetShadowOffset(1, -1)

-- Scale of the UI here
local screenWidth, screenHeight = GetPhysicalScreenSize()

-- Scale the default nameplate parameters - note this doesn't seem to do anything on load, so investigating
local function nameplateSize(self)
	if (InCombatLockdown()) then return end

	if (self) then
		self:SetSize(config.width, config.height)
	end

	C_NamePlate.SetNamePlateFriendlySize(config.width, 0.1)
	C_NamePlate.SetNamePlateEnemySize(config.width, (config.height + config.targetingTopPadding + config.targetingBottomPadding))
	C_NamePlate.SetNamePlateSelfSize(config.width, config.height)
	C_NamePlate.SetNamePlateFriendlyClickThrough(true)
	C_NamePlate.SetNamePlateSelfClickThrough(true)
end
bdNameplates.eventer = CreateFrame("frame", nil)
bdNameplates.eventer:RegisterEvent("PLAYER_REGEN_ENABLED", nameplateSize)
bdNameplates.eventer:RegisterEvent("PLAYER_LOGIN", nameplateSize)


bdNameplates.dot = CreateFrame("frame", "bdNameplates Player Dot", UIParent)
bdNameplates.dot:SetSize(20, 20)
bdNameplates.dot:SetPoint("CENTER", 0, -15)
bdNameplates.dot.tex = bdNameplates.dot:CreateTexture(nil, "OVERLAY")
bdNameplates.dot.tex:SetTexture("Interface/Addons/bdNameplates/media/circle.blp")
bdNameplates.dot.tex:SetPoint("TOPLEFT", -2, 2)
bdNameplates.dot.tex:SetPoint("BOTTOMRIGHT", 2, -2)
bdNameplates.dot.tex:SetVertexColor(0,0,0,1)
bdNameplates.dot.tex2 = bdNameplates.dot:CreateTexture(nil, "OVERLAY")
bdNameplates.dot.tex2:SetTexture("Interface/Addons/bdNameplates/media/circle.blp")
bdNameplates.dot.tex2:SetAllPoints()
bdNameplates.dot.tex2:SetVertexColor(unpack(bdCore.media.red))
if (config.showCenterDot) then
	bdNameplates.dot:Show()
else
	bdNameplates.dot:Hide()
end
bdCore:makeMovable(bdNameplates.dot)


function bdNameplates:configCallback()
	nameplateSize()

	-- print(config.height * 0.85)
	-- update font sizes
	bdNameplates.font:SetFont(bdCore.media.font, config.enemynamesize)
	bdNameplates.font_small:SetFont(bdCore.media.font, config.height * 0.85)
	bdNameplates.font_castbar:SetFont(bdCore.media.font, config.castbarheight*0.85)
	bdNameplates.font_friendly:SetFont(bdCore.media.font, config.friendlynamesize)

	if (config.showCenterDot) then
		bdNameplates.dot:Show()
	else
		bdNameplates.dot:Hide()
	end

	-- set cVars
	local cvars = {
		['nameplateSelfAlpha'] = 1
		, ['nameplateShowAll'] = 1
		, ['nameplateMinAlpha'] = 1
		, ['nameplateMaxAlpha'] = 1
		, ['nameplateMotionSpeed'] = 0.1
		, ['nameplateOccludedAlphaMult'] = 1
		, ['nameplateMaxAlphaDistance'] = 1
		, ['nameplateMaxDistance'] = config.nameplatedistance+6 -- for some reason there is a 6yd diff
		, ["nameplateOverlapV"] = config.verticalspacing --0.8
		, ['nameplateShowOnlyNames'] = 0
		, ['nameplateShowDebuffsOnFriendly'] = 0
		, ['nameplateMinScale'] = 1
		, ['nameplateMaxScale'] = 1
		, ['nameplateMaxScaleDistance'] = 0
		, ['nameplateMinScaleDistance'] = 0
		, ['nameplateLargerScale'] = 1 -- for bosses
		, ['nameplateShowOnlyNames'] = config.friendlynamehack and 1 or 0 -- friendly names and no plates in raid
		, ['nameplateOverlapV'] = GetCVarDefault('nameplateOverlapV')
		, ['nameplateOverlapH'] = GetCVarDefault('nameplateOverlapH')
		, ['nameplateOtherTopInset'] = GetCVarDefault('nameplateOtherTopInset')
		, ['nameplateOtherBottomInset'] = GetCVarDefault('nameplateOtherBottomInset')
		, ['nameplateLargeTopInset'] = GetCVarDefault('nameplateLargeTopInset')
		, ['nameplateLargeBottomInset'] = GetCVarDefault('nameplateLargeBottomInset')
	}
	-- loop through and set CVARS
	if (not InCombatLockdown()) then
		for k, v in pairs(cvars) do
			SetCVar(k, v)
		end
	end

	bd_do_action("bdNameplatesConfig")
end

local function fixateUpdate(self, event, unit)
	if (not self.unit == unit) then return end

	local target = unit.."target"

	if (config.fixateMobs[UnitName(unit)]) then
		self.Fixate:Show()
		self.Fixate.text:SetText(UnitName(target))
	else
		if (UnitExists(target) and UnitIsPlayer(target)) then
			if (config.fixatealert == "Always" or config.fixatealert == "All") then
				self.Fixate:Show()
				self.Fixate.text:SetText(UnitName(target))
			elseif (config.fixatealert == "Personal" and UnitIsUnit(target, "player")) then
				self.Fixate:Show()
				self.Fixate.text:SetText(UnitName(target))
			end
		end
	end
end
local function updateVars(frame, unit)
	if (not unit) then return end
		
	frame.isTarget = UnitIsUnit("target", unit)
	frame.isPlayer = UnitIsPlayer(unit) and select(2, UnitClass(unit)) or false
	frame.reaction = UnitReaction(unit, "player") or false
end

--==========================================
-- HEALTH UPDATER
--- Calls on 
---- more than it ought to by default
---- NAME_PLATE_UNIT_ADDED
---- UNIT_HEALTH_FREQUENT
--==========================================
local specialunits = config.specialunits
local function nameplateUpdateHealth(self, event, unit)
	if(not unit or not UnitIsUnit(self.unit, unit)) then return false end
	
	if (event == "NAME_PLATE_UNIT_REMOVED") then return false end
	if (event == "OnShow") then return false end
	if (event == "OnUpdate") then return false end

	-- store these values for reuse
	updateVars(self, unit)

	local healthbar = self.Health
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	healthbar:SetMinMaxValues(0, max)
	healthbar:SetValue(cur)

	if (((cur / max) * 100) <= config.executerange) then
		healthbar:SetStatusBarColor(unpack(config.executecolor))
	elseif (specialunits[UnitName(unit)]) then
		healthbar:SetStatusBarColor(unpack(config.specialcolor))
	else
		local tapDenied = UnitIsTapDenied(unit) or false
		local status = UnitThreatSituation("player", unit)
		if (status == nil) then
			status = false
		end
		self.smartColors = bdNameplates:unitColor(tapDenied, self.isPlayer, self.reaction, status)
		healthbar:SetStatusBarColor(unpack(self.smartColors))
	end

	return true
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
bdNameplates.target = false
local function calculateTarget(self, event, unit)
	unit = unit or self.unit
	if (UnitIsUnit(unit, "target")) then
		self.isTarget = true
		self:SetAlpha(1)
		self.Health.Shadow:Show()
	else
		self.isTarget = false
		self:SetAlpha(config.unselectedalpha)
		self.Health.Shadow:Hide()
	end
end
local function bdNameplateCallback(self, event, unit)
	if (not self) then return end
	calculateTarget(self, event, unit)

	if (unit) then
		self.nameplate = C_NamePlate.GetNamePlateForUnit(unit)
		self.guid = UnitGUID(self.nameplate.namePlateUnitToken)
	end

	unit = unit or self.unit
	self.isPlayer = UnitIsPlayer(unit) and select(2, UnitClass(unit)) or false
	self.reaction = UnitReaction(unit, "player") or false
	self.Fixate:Hide()
	
	-- Force cvars/settings
	nameplateSize()

	--==========================================
	-- Style by unit type
	--==========================================
	if (UnitCanAttack("player", unit)) then
		fixateUpdate(self, event, unit)
		bdNameplates:enemyStyle(self, event, unit)
	elseif (UnitIsUnit(unit, "player")) then
		bdNameplates:personalStyle(self, event, unit)
	elseif (self.isPlayer) then
		bdNameplates:friendlyStyle(self, event, unit)
	else
		bdNameplates:npcStyle(self, event, unit)
	end

	--==========================================
	-- Overriding Configuration
	--==========================================
	-- disabled auras
	if (config.disableauras) then
		self.Auras:Hide()
	end

	-- hp text
	if (config.hptext == "None" or (config.showhptexttargetonly and not self.isTarget)) then
		self.Curhp:Hide()
	else
		self.Curhp:Show()
	end
end

--==========================================
-- NAMEPLATE CREATE
--- Calls when a new nameplate frame gets created
--==========================================
local function auraFilter(self, name, castByPlayer, debuffType, isStealable, nameplateShowSelf, nameplateShowAll)
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
	if (config.automydebuff and castByPlayer) then return true end
	-- show if blizzard decided that it was a self-show or all-show aira 
	if (nameplateShowAll or (nameplateShowSelf and castByPlayer)) then return true end
	-- if this is whitelisted for their own casts
	if (config.selfwhitelist and (config.selfwhitelist[name] and castByPlayer)) then return true end

	return false
end
bdNameplates.auraFilter = memoize(auraFilter, bdNameplates.cache)

local function nameplateCreate(self, unit)
	self.nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	self.guid = UnitGUID(self.nameplate.namePlateUnitToken)
	self.unit = unit

	-- self.bgtest = self:CreateTexture(nil, "OVERALY")
	-- self.bgtest:SetTexture(bdCore.media.flat)
	-- self.bgtest:SetVertexColor(0, 1, 0)
	-- self.bgtest:SetAlpha(0.5)
	-- self.bgtest:SetAllPoints()

	-- nameplate specific callback
	bd_add_action("bdNameplatesConfig", function()
		-- auras
		self.Auras.size = config.raidbefuffs
		self.Auras.showStealableBuffs = config.highlightPurge

		-- raid target
		self.RaidTargetIndicator:SetSize(config.raidmarkersize, config.raidmarkersize)
		self.RaidTargetIndicator:ClearAllPoints()
		if (config.markposition == "LEFT") then
			self.RaidTargetIndicator:SetPoint('RIGHT', self, "LEFT", -(config.raidmarkersize/2), 0)
		elseif (config.markposition == "RIGHT") then
			self.RaidTargetIndicator:SetPoint('LEFT', self, "RIGHT", config.raidmarkersize/2, 0)
		else
			self.RaidTargetIndicator:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
		end

		-- castbars
		self.Castbar.Icon:SetSize(config.height+config.castbarheight, config.height+config.castbarheight)
		-- cast icon
		if (config.hidecasticon) then
			self.Castbar.Icon:Hide()
			self.Castbar.Icon.bg:Hide()
		else
			self.Castbar.Icon:Show()
			self.Castbar.Icon.bg:Show()
		end
	end)
	
	self:SetPoint("BOTTOM", self.nameplate, "BOTTOM", 0, math.floor(config.targetingBottomPadding))
	self:SetSize(math.floor(config.width), math.floor(config.height))
	self:SetScale(bdCore.scale)
	self:EnableMouse(false)

	--==========================================
	-- HEALTHBAR
	--==========================================
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdCore.media.smooth)
	self.Health:SetAllPoints(self)
	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	bdCore:createShadow(self.Health, 10)
	bdCore:setBackdrop(self.Health)
	self.Health.Shadow:SetBackdropColor(unpack(config.glowcolor))
	self.Health.Shadow:SetBackdropBorderColor(unpack(config.glowcolor))

	--==========================================
	-- CALLBACKS
	--==========================================
	-- targeting callback
	self:RegisterEvent("PLAYER_TARGET_CHANGED", calculateTarget, true)

	-- coloring callbacks
	-- self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", nameplateUpdateHealth, true)
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
	self.Curhp.frequentUpdates = 0.1

	-- oUF.Tags.Events["bdncurhp"] = "UNIT_HEALTH UNIT_MAXHEALTH"
	oUF.Tags.Methods["bdncurhp"] = function(unit)
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
	-- FIXATES / TARGETS
	--==========================================
	self.Fixate = CreateFrame("frame",nil,self)
	self.Fixate:SetFrameLevel(4)
	self.Fixate:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -20)
	self.Fixate:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -8)
	self.Fixate:SetFrameLevel(100)
	self.Fixate.text = self.Fixate:CreateFontString(nil, "OVERLAY", "BDN_FONT_SMALL")

	local icon = select(3, GetSpellInfo(210099))
	self.Fixate.text.SetText_Old = self.Fixate.text.SetText
	self.Fixate.text.SetText = function(self, unit)
		local color = bdCore:RGBToHex(bdNameplates:unitColor(unit))
		if (unit and UnitIsUnit(unit,"player")) then
			self:SetAlpha(1)
			self:SetText_Old("|T"..icon..":16:16:0:0:60:60:4:56:4:56|t ".."|cff"..color..unit.."|r")
		else
			self:SetAlpha(0.8)
			self:SetText_Old("|cff"..color..unit.."|r")
		end
	end
	self.Fixate.text:SetAllPoints(self.Fixate)
	self.Fixate.text:SetJustifyH("CENTER")
	self.Fixate:Hide()
	self:RegisterEvent("UNIT_TARGET", fixateUpdate)

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
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false

		return bdNameplates:auraFilter(name, castByPlayer, debuffType, isStealable, nameplateShowSelf, nameplateShowAll)
	end
	
	self.Auras.PostCreateIcon = function(self, button)
		bdCore:setBackdrop(button)

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
	end
	self.Auras.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		button:SetHeight(config.raidbefuffs * 0.6)
		if (config.highlightPurge and isStealable) then -- purge alert
			button.border:SetVertexColor(unpack(config.purgeColor))
		elseif (config.highlightEnrage and debuffType == "") then -- enrage alert
			button.border:SetVertexColor(unpack(config.enrageColor))
		else -- neither
			button.border:SetVertexColor(unpack(bdCore.media.border))
		end
	end

	--==========================================
	-- CASTBARS
	--==========================================
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(bdCore.media.flat)
	self.Castbar:SetStatusBarColor(unpack(config.kickable))
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
	bdCore:setBackdrop(self.Castbar)
	
	-- text
	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", "BDN_FONT_CASTBAR")
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 10, 0)

	self.Castbar.AttributeText = self.Castbar:CreateFontString(nil, "OVERLAY", "BDN_FONT_CASTBAR")
	self.Castbar.AttributeText:SetJustifyH("RIGHT")
	self.Castbar.AttributeText:SetPoint("RIGHT", self.Castbar, "RIGHT", -10, 0)
	
	-- icon
	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Castbar.Icon:SetDrawLayer('ARTWORK')
	self.Castbar.Icon:SetSize(config.height+12, config.height+12)
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT",self.Castbar, "BOTTOMLEFT", -2, 0)
	
	-- icon bg
	self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.Icon.bg:SetTexture(bdCore.media.flat)
	self.Castbar.Icon.bg:SetVertexColor(unpack(bdCore.media.border))
	self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -borderSize, borderSize)
	self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", borderSize, -borderSize)

	-- Combat log based extra information
	function self.Castbar:CastbarAttribute() 
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = CombatLogGetCurrentEventInfo();

		if (self.guid ~= sourceGUID) then return end

		if (event == 'SPELL_CAST_START') then
			destName = self.unit.."target"

			if UnitIsUnit(destName, "player") and bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
				print( format("%s is casting %s on me", sourceName, GetSpellLink(spellID)) )
			end

			self.Castbar.AttributeText:SetText("")
			-- attribute who this cast is targeting
			if (UnitExists(destName)) then
				self.Castbar.AttributeText:SetText(UnitName(destName))
			end
		elseif (event == "SPELL_INTERRUPT") then
			-- attribute who interrupted this cast
			if (UnitExists(sourceName)) then
				self.Castbar.AttributeText:SetText(UnitName(sourceName))
			end
		end
	end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.Castbar.CastbarAttribute, true)

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
	self.Castbar.PostCastNotInterruptible = self.Castbar.kickable
	self.Castbar.PostCastInterruptible = self.Castbar.kickable
	self.Castbar.PostCastStart = self.Castbar.kickable
end

oUF:RegisterStyle("bdNameplates", nameplateCreate)
oUF:SetActiveStyle("bdNameplates")
oUF:SpawnNamePlates("bdNameplates", bdNameplateCallback)
