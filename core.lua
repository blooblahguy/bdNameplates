local addon, bdNameplates = ...
local oUF = bdCore.oUF
local config = bdCore.config.profile['Nameplates']

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

local screenWidth, screenHeight = GetPhysicalScreenSize()
bdNameplates.scale = min(1.15, 768/screenHeight)

C_NamePlate.SetNamePlateFriendlySize(config.width, 0.1)
C_NamePlate.SetNamePlateEnemySize(config.width, config.height)
C_NamePlate.SetNamePlateFriendlyClickThrough(true)

SetCVar('nameplateMotionSpeed', .1)
SetCVar('nameplateOverlapV', GetCVarDefault("nameplateOverlapV"))
SetCVar('nameplateOverlapH', GetCVarDefault("nameplateOverlapH"))

SetCVar('nameplateOtherTopInset', GetCVarDefault("nameplateOtherTopInset"))
SetCVar('nameplateOtherBottomInset', GetCVarDefault("nameplateOtherBottomInset"))
SetCVar('nameplateLargeTopInset', GetCVarDefault("nameplateLargeTopInset"))
SetCVar('nameplateLargeBottomInset', GetCVarDefault("nameplateLargeBottomInset"))

function bdNameplates:configCallback()
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
	}

	if (config.friendlynamehack) then
		cvars['nameplateShowOnlyNames'] = 1	
	end
	
	if (not InCombatLockdown()) then
		for k, v in pairs(cvars) do
			local current = GetCVar(k)
			if (current ~= v) then
				SetCVar(k, v)
			end
		end
	end
end
bdNameplates:configCallback()

local function kickable(self)
	if (self.notInterruptible) then
		self.Icon:SetDesaturated(1)
		self:SetStatusBarColor(unpack(config.nonkickable))
	else
		self.Icon:SetDesaturated(false)
		self:SetStatusBarColor(unpack(config.kickable))
	end
end

function nameplateSize()
	if (not InCombatLockdown()) then
		C_NamePlate.SetNamePlateFriendlySize(config.width * bdNameplates.scale, 0.1)
		C_NamePlate.SetNamePlateEnemySize(config.width * bdNameplates.scale, config.height * bdNameplates.scale)
		C_NamePlate.SetNamePlateFriendlyClickThrough(true)
	end
end

function nameplateColor(self, event, unit)
	-- print(self, event, unit)
	if (not unit or unit == 'player' or UnitIsUnit('player', unit) or UnitIsFriend('player', unit)) then return end

	local healthbar = self.Health
	local combat = UnitAffectingCombat("player")
	local status = UnitThreatSituation("player", unit)

	if (UnitIsTapDenied(unit)) then
		-- 5 people or enemy faction have already tagged this mob
		healthbar:SetStatusBarColor(.5,.5,.5)
	elseif (combat) then 
		if (status == 3) then
			-- securely tanking
			healthbar:SetStatusBarColor(unpack(config.threatcolor))

		elseif (status == 2 or status == 1) then
			-- near or over tank threat
			healthbar:SetStatusBarColor(unpack(config.threatdangercolor))

		elseif (status ~= nil) then
			-- on threat table, but not near tank threat
			healthbar:SetStatusBarColor(unpack(config.nothreatcolor))
		else
			-- not on threat table
			self.Health:ForceUpdate()
		end
	end
end

function nameplateCallback(self, event, unit)
	nameplateSize()
	if (not self) then return end

	self:SetAlpha(config.unselectedalpha)

	if (not unit) then
		unit = self.unit
	else
		-- this is a real callback, not a target callback

	end

	nameplateColor(self, event, unit)

	if (UnitIsUnit("target", unit)) then
		self:SetAlpha(1)
	end
end

function nameplateCreate(self, unit)
	self.nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	self.scale = bdNameplates.scale
	self.unit = unit
	bdCore:setBackdrop(self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", nameplateSize)

	self:SetAllPoints(self.nameplate)
	self:SetScale(self.scale)
	self:EnableMouse(false)

	-- targeting callback
	self:RegisterEvent("PLAYER_TARGET_CHANGED", nameplateCallback)

	-- coloring callbacks
	self:RegisterEvent("PLAYER_REGEN_DISABLED", nameplateColor)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", nameplateColor)
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", nameplateColor, false)


	-- HEALTH
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdCore.media.smooth)
	self.Health:SetAllPoints(self)
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true

	-- bdCore:setBackdrop(self.Health,true)
	-- self.Health:EnableMouse(false)

	-- NAMES
	self.Name = self:CreateFontString(nil)
	self.Name:SetFont(bdCore.media.font, 16)
	self.Name:SetShadowOffset(1,-1)
	self.Name:SetPoint("BOTTOM", self, "TOP", 0, 6)	
	self:Tag(self.Name, '[name]')

	-- HP
	self.Curhp = self.Health:CreateFontString(nil,"OVERLAY")
	self.Curhp:SetFont(bdCore.media.font, 14,"OUTLINE")
	self.Curhp:SetJustifyH("RIGHT")
	self.Curhp:SetShadowColor(0,0,0,0)
	self.Curhp:SetAlpha(0.8)
	self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
	oUF.Tags.Events['bdncurhp'] = 'UNIT_HEALTH_FREQUENT'
	oUF.Tags.Methods['bdncurhp'] = function(unit)
		if (config.hptext == "None") then return '' end
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		local hpPercent = hp / hpMax
		
		if (config.hptext == "HP - %") then
			return bdNameplates:numberize(hp).." - "..bdNameplates:round(hpPercent * 100,1);
		elseif (config.hptext == "HP") then
			return bdNameplates:numberize(hp);
		elseif (config.hptext == "%") then
			return bdNameplates:round(hpPercent * 100,1);
		end
	end
	self:Tag(self.Curhp, '[bdncurhp]')

	-- power
	self.Curpower = self.Health:CreateFontString(nil,"OVERLAY")
	self.Curpower:SetFont(bdCore.media.font, 14,"OUTLINE")
	self.Curpower:SetJustifyH("LEFT")
	self.Curpower:SetShadowColor(0,0,0,0)
	self.Curpower:SetAlpha(0.8)
	self.Curpower:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
	oUF.Tags.Events['bdncurpower'] = 'UNIT_POWER_UPDATE'
	oUF.Tags.Methods['bdncurpower'] = function(unit)
		if (not config.showenergy) then return '' end
		local pp, ppMax = UnitPower(unit), UnitPowerMax(unit)
		if (pp == 0 or ppMax == 0) then return '' end

		local ppPercent = (pp / ppMax) * 100
		return math.floor(ppPercent);
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

	-- AURAS
	-- For friendlies
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
	self.Auras.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,timeMod, effect1, effect2, effect3)

		-- blacklist is priority
		if (config.blacklist and config.blacklist[name]) then return false end
		-- purgable spell, whitelist it
		if (config.highlightPurge and isStealable) then return true end
		-- this is an enrage
		if (config.highlightEnrage and debuffType == "") then return true end
		-- if we've whitelisted this inside of bdCore defaults
		if (raidwhitelist[name] or raidwhitelist[spellID]) then return true end
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
	
	self.Auras.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local cdtext = button.cd:GetRegions()
		button:SetHeight(config.raidbefuffs*.6)

		if (button.skinned) then return end

		bdCore:setBackdrop(button)
		cdtext:SetFont(bdCore.media.font, 14, "OUTLINE")
		cdtext:SetShadowColor(0,0,0,0)
		cdtext:SetJustifyH("CENTER")
		cdtext:ClearAllPoints()
		cdtext:SetAllPoints(button)
		
		button.count:SetFont(bdCore.media.font,12,"OUTLINE")
		button.count:SetTextColor(1,.8,.3)
		button.count:SetShadowColor(0,0,0,0)
		button.count:SetJustifyH("RIGHT")
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		
		button.icon:SetTexCoord(0.08, 0.9, 0.20, 0.74)
		
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(false)

		button.skinned = true
	end

	-- CASTBARS
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(bdCore.media.flat)
	self.Castbar:SetStatusBarColor(.1, .1, .1, 1)
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
	self.Castbar.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdCore.config.persistent.General.border, bdCore.config.persistent.General.border)
	self.Castbar.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdCore.config.persistent.General.border, -bdCore.config.persistent.General.border)
	
	self.Castbar.PostChannelStart = kickable
	self.Castbar.PostCastStart = kickable
	self.Castbar.PostCastNotInterruptible = kickable
	self.Castbar.PostCastInterruptible = kickable

	self.Castbar.timeToHold = 1
end

oUF:RegisterStyle("bdNameplates", nameplateCreate)
oUF:SetActiveStyle("bdNameplates")
oUF:SpawnNamePlates("bdNameplates", nameplateCallback)