local addon, bdNameplates = ...
local oUF = bdCore.oUF

local config = bdCore.config.profile['Nameplates']

local function nameplateCallback() end

function bdNameplates:configCallback()
	-- set cVars
	local cvars = {
		['nameplateSelfAlpha'] = 1,
		['nameplateShowAll'] = 1,
		['nameplateMinAlpha'] = 1,
		['nameplateMaxAlpha'] = 1,
		['nameplateMaxAlphaDistance'] = 0,
		['nameplateMaxDistance'] = config.nameplatedistance+6, -- for some reason there is a 6yd diff
		["nameplateOverlapV"] = config.verticalspacing, --0.8
		['nameplateShowOnlyNames'] = 0,
		['nameplateShowDebuffsOnFriendly'] = 0,
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

	if (config.friendlynamehack) then
		cvars['nameplateShowOnlyNames'] = 1	
	end
	
	if (not InCombatLockdown()) then
		for k, v in pairs(cvars) do
			local current = tonumber(GetCVar(k))
			if (current ~= tonumber(v)) then
				SetCVar(k, v)
			end
		end
	end

	-- restyle nameplates
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		local unit = frame.unitFrame.unit
		nameplateCallback(frame.ouf, "", frame,unit)
	end
end



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

local scale = UIParent:GetEffectiveScale()*1
C_NamePlate.SetNamePlateFriendlySize((config.width * scale) + 10,0.1)
C_NamePlate.SetNamePlateSelfSize((config.width * scale) + 10,0.1)
C_NamePlate.SetNamePlateEnemySize(config.width * scale, config.height * scale)

SetCVar('nameplateMotionSpeed', .1)

-- these should be defaulted pretty much always
--SetCVar('nameplateShowSelf', 1)
SetCVar('nameplateOverlapV', GetCVarDefault("nameplateOverlapV"))
SetCVar('nameplateOverlapH', GetCVarDefault("nameplateOverlapH"))
SetCVar('nameplateOtherTopInset', GetCVarDefault("nameplateOtherTopInset"))
SetCVar('nameplateOtherBottomInset', GetCVarDefault("nameplateOtherBottomInset"))
SetCVar('nameplateLargeTopInset', GetCVarDefault("nameplateLargeTopInset"))
SetCVar('nameplateLargeBottomInset', GetCVarDefault("nameplateLargeBottomInset"))


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
-- local function getcolor(unit)
-- 	local reaction = UnitReaction(unit, "player") or 5
	
-- 	if UnitIsPlayer(unit) then
-- 		local class = select(2, UnitClass(unit))
-- 		local color = RAID_CLASS_COLORS[class]
-- 		return color.r, color.g, color.b
-- 	elseif UnitCanAttack("player", unit) then
-- 		if UnitIsDead(unit) then
-- 			return 136/255, 136/255, 136/255
-- 		else
-- 			if reaction<4 then
-- 				return 1, 68/255, 68/255
-- 			elseif reaction==4 then
-- 				return 1, 1, 68/255
-- 			end
-- 		end
-- 	else
-- 		if reaction<4 then
-- 			return 48/255, 113/255, 191/255
-- 		else
-- 			return 1, 1, 1
-- 		end
-- 	end
-- end


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
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
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

local function enemyStyle(self,unit)
	self.Auras:Show()
	self.Health:Show()
	self.Name:Show()

	if (UnitIsUnit(unit,"target")) then
		self.Health.Shadow:Show()
		self.Health.Shadow:SetBackdropBorderColor(unpack(config.glowcolor))
	end
	
	self.Name:SetTextColor(1,1,1)
	self.Name:ClearAllPoints()
	self.Name:SetFont(bdCore.media.font, config.enemynamesize)
	self.Name:SetShadowColor(0,0,0)
	self.Name:SetPoint("BOTTOM", self, "TOP", 0, 6)	
	self.Castbar:SetAlpha(1)
	self.Health:SetAllPoints(self)

	if (config.hideEnemyNames == "Always Show") then
		self.Name:Show()
	elseif (config.hideEnemyNames == "Always Hide") then
		self.Name:Hide()
	elseif (config.hideEnemyNames == "Only Target") then
		self.Name:Hide()
		if (UnitIsUnit(unit,"target")) then
			self.Name:Show()
		end
	elseif (config.hideEnemyNames == "Hide in Arena") then
		local inInstance, instanceType = IsInInstance();
		self.Name:Show()
		if (inInstance and instanceType == "arena") then
			self.Name:Hide()
		end
	end
end

local function npcStyle(self,unit)
	self.background:Hide()
	self.Auras:Hide()
	self.Health:Hide()

	self.Name:Show()
	
	self.Name:SetFont(bdCore.media.font, config.friendlynamesize, "OUTLINE")
	self.Name:SetShadowColor(0,0,0,0)
	self.Name:SetTextColor(unitColor(unit))
	self.Name:ClearAllPoints()
	self.Name:SetPoint("TOP", self, "TOP", 0, 10)	

	self.Castbar:SetAlpha(0)
end
local function playerStyle(self,unit)
	self.Power:Show()
	self.Auras:Show()

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
	self.RaidTargetIndicator:SetAlpha(0)
	
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
	self.Auras:Show()
	self.Name:Show()
	
	if (config.friendlyplates) then
		self.Health:Show()
	else
		self.Health:Hide()
	end

	if (not UnitIsUnit(unit,"target")) then
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

local function threatColor(self, event, unit)
	if (unit == nil) then return end

	-- local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	self.Health:UpdateColor(self.unit, min, max)

	if (UnitIsUnit(self.unit,unit)) then

		if (UnitIsPlayer(unit)) then return end
		
		-- check priority health overrides first
		-- if (self.specialExpiration > GetTime() or self.specialUnit) then
		-- 	self.Health:SetStatusBarColor(unpack(config.specialcolor))
		-- end

		-- these things have been forced, don't proceed with more logic
		-- if (self.forceSpecial or self.forcePurge or self.forceEnrage) then return end
		
		-- we don't recolor players

		local healthbar = self.Health
		local combat = UnitAffectingCombat("player")
		local status = UnitThreatSituation("player", unit)

		-- threat coloring
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

				-- execute color alert
				if (config.executerange) then
					local perc = 100;
					if (UnitHealthMax(unit) ~= 0) then
						perc = (UnitHealth(unit) / UnitHealthMax(unit)) * 100
					end

					if (perc <= config.executerange) then
						healthbar:SetStatusBarColor(unpack(config.executecolor))
					end
				end
			end
		end
	end
end

local function fixateUpdate(self, event, unit)
	if (self.unit == unit) then
		local target = unit.."target"

		self.Circle:Hide()
		self.Fixate:Hide()
		
		if (UnitExists(target) and UnitIsPlayer(target)) then
			if (config.fixatealert ~= "None" and config.showFixateCircle and UnitIsUnit(target, "player")) then
				self.Circle:Show()
				self.Circle:SetYards(4)
				self.Circle:SetColor(.8,0,0,1,0.5)
				self.Circle:SetType(2)
			end

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

local function nameplateCallback(self, event, unit)
	
	-- set the scale of the nameplates
	local scale = UIParent:GetEffectiveScale()*1
	if (not InCombatLockdown()) then
		C_NamePlate.SetNamePlateFriendlySize((config.width * scale) + 10,0.1)
		C_NamePlate.SetNamePlateEnemySize(config.width * scale, (config.height + 10) * scale)
		C_NamePlate.SetNamePlateFriendlyClickThrough(true)
	end
	
	-- make sure we have the things we want
	if (not self or not unit) then return end
	
	-- force feature updates
	fixateUpdate(self, event, unit)
	threatColor(self, event, unit)
	
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local reaction = UnitReaction("player", unit)

	---------------------
	-- let's hide things first, and then we'll show / size / position for specific elements
	-- this is more verbose and possible slightly lower performance, but more readable and extendable
	---------------------
	self.Namecontainer:SetAlpha(1)
	self:EnableMouse(false)
	self.Health:EnableMouse(false)
	self.Auras:Hide()
	self.Auras.showStealableBuffs = config.highlightPurge
	self.Name:Hide()
	self.Health.Shadow:Hide()
	self.Curhp:Hide()
	self.Castbar.Icon:Hide()
	self.Castbar.bg:Hide()
	self.Power:Hide()

	---------------------
	-- configurations
	---------------------
	self:SetHeight(config.height)

	self.Curhp:SetFont(bdCore.media.font, config.height*.85,"OUTLINE")
	self.Curpower:SetFont(bdCore.media.font, config.height*.85,"OUTLINE")

	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
	self.Castbar.Text:SetFont(bdCore.media.font, config.castbarheight*.85, "OUTLINE")
	self.Castbar.Icon:SetSize(config.height+config.castbarheight, config.height+config.castbarheight)
	if (not config.hidecasticon) then
		self.Castbar.Icon:Show()
		self.Castbar.bg:Show()
	end

	self.Auras:SetSize(config.width+4, config.raidbefuffs)
	self.Auras.size = config.raidbefuffs

	self.RaidTargetIndicator:SetSize(config.raidmarkersize, config.raidmarkersize)
	self.RaidTargetIndicator:ClearAllPoints()
	if (config.markposition == "LEFT") then
		self.RaidTargetIndicator:SetPoint('RIGHT', self, "LEFT", -(config.raidmarkersize/2), 0)
	elseif (config.markposition == "RIGHT") then
		self.RaidTargetIndicator:SetPoint('LEFT', self, "RIGHT", config.raidmarkersize/2, 0)
	else
		self.RaidTargetIndicator:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
	end

	if (config.hptext == "None" or (config.showhptexttargetonly and not UnitIsUnit(unit,"target"))) then
		self.Curhp:Hide()
	else
		self.Curhp:Show()
	end

	-------------------------
	-- Style by unit type
	-------------------------
	if (UnitIsUnit(unit,"player")) then
		playerStyle(self, unit)
	elseif (UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend("player",unit) and reaction and reaction >= 5)) then
		friendlyStyle(self, unit)
	elseif (not UnitIsPlayer(unit) and (reaction and reaction >= 5) or ufaction == "Neutral") then
		npcStyle(self, unit)
	else
		enemyStyle(self, unit)
	end
	
	-------------------------
	-- overwrite special units
	-------------------------
	if (config.disableauras) then
		self.Auras:Hide()
	end
	if (UnitIsUnit("target", unit)) then
		self:SetAlpha(1)
	else
		self:SetAlpha(config.unselectedalpha)
	end

	-- special unit
	if (config.specialunits[UnitName(unit)]) then
		self.specialUnit = true
	else
		self.specialUnit = false
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

local total = 0
local threshhold = 0.5
local function specialUpdate(self, elapsed)
	total = total + elapsed
	local t = GetTime();
	if (self.specialExpiration > 0 and t > self.specialExpiration) then
		self.forceSpecial = false
		self.specialExpiration = 0
	end
	if (self.specialExpiration > 0 and total > threshold) then
		total = 0
	
		-- do we want to run this script at all?
		self.forceSpecial = false
		if (#config.specialSpells == 0) then
			return
		end

		-- for i = 1, 40 do
		-- 	local buff, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod = UnitAura(self.unit, i, "HELPFUL")
		-- 	local debuff = UnitAura(self.unit, i, "HARMFUL")

		-- 	if (config.specialSpells[buff] or config.specialSpells[debuff]) then
		-- 		self.forceSpecial = true
		-- 		skipSpecial = true
		-- 	end


		-- 	-- if we found these things then there is no reason to continue
		-- 	if (skipSpecial and skipPurge and skipEnrage) then break end
		-- end
	end
end



------------------------------
-- Nameplate Initiation
------------------------------
local function style(self, unit)
	local scale = UIParent:GetEffectiveScale()*1
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local main = self
	self.styled = true
	nameplate.ouf = self

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
	
	oUF.Tags.Events['bdncurhp'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH PLAYER_TARGET_CHANGED'
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


	oUF.Tags.Events['bdncurpower'] = 'UNIT_POWER_UPDATE PLAYER_TARGET_CHANGED'
	oUF.Tags.Methods['bdncurpower'] = function(unit)
		local pp, ppMax = UnitPower(unit), UnitPowerMax(unit)
		if not pp then return end
		if ppMax == 0 then return end
		local ppPercent = (pp / ppMax) * 100
		
		if (not config.showenergy) then
			return ""
		else
			return math.floor(ppPercent);
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

	-- Setup frame resource for rogue, monks, paladins, mmaybe more one day
	-- bdNameplates:resourceBuilder(self.Health, unit)
	
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

	-- quest indicator
	-- self.QuestIndicator = self:CreateTexture(nil, 'OVERLAY')
    -- self.QuestIndicator:SetSize(20, 20)
    -- self.QuestIndicator:SetPoint('LEFT', self.Name, 'RIGHT', 2,  0)
	
	self.Curhp = self.Health:CreateFontString(nil,"OVERLAY")
	self.Curhp:SetFont(bdCore.media.font, 12,"OUTLINE")
	self.Curhp:SetJustifyH("RIGHT")
	self.Curhp:SetShadowColor(0,0,0,0)
	self.Curhp:SetAlpha(0.8)
	self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
	self:Tag(self.Curhp, '[bdncurhp]')

	self.Curpower = self.Health:CreateFontString(nil,"OVERLAY")
	self.Curpower:SetFont(bdCore.media.font, 12,"OUTLINE")
	self.Curpower:SetJustifyH("LEFT")
	self.Curpower:SetShadowColor(0,0,0,0)
	self.Curpower:SetAlpha(0.8)
	self.Curpower:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
	self:Tag(self.Curpower, '[bdncurpower]')
	
	bdCore:createShadow(self.Health,10)
	self.Health.Shadow:SetBackdropColor(1, 1, 1, 1)
	self.Health.Shadow:SetBackdropBorderColor(1, 1, 1, 0.8)
	
	
	-- self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	-- self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	-- self.Health:RegisterEvent("UNIT_TARGET")

	-- On target change
	self:RegisterEvent("PLAYER_TARGET_CHANGED", nameplateCallback)

	-- Threatplates / combat in-out
	self:RegisterEvent("PLAYER_REGEN_DISABLED", threatColor)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", threatColor)
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", threatColor, false)
	-- self:RegisterEvent("UNIT_TARGET", threatColor, false)
	self.Health.PostUpdate = function(element, unit, cur, max)
		threatColor(self, "", self.unit)

		self.Health.Override = bdCore.noop
		self.Health.PostUpdate = bdCore.noop
	end

	self:RegisterEvent("UNIT_TARGET", fixateUpdate, false)



	-- Circle/Ring Alert
	self.Circle = CreateFrame("frame", nil, self)
	self.Circle:SetAlpha(0.8)
	self.Circle:SetFrameLevel(1)
	self.Circle.parent = self
	self.Circle.tex = self.Circle:CreateTexture(nil,"OVERLAY")
	self.Circle.tex:SetAllPoints()
	self.Circle.tex:SetTexture("Interface\\Addons\\bdNameplates\\circle.blp")
	self.Circle.tex:SetVertexColor(0,0,0,1)
	self.Circle.SetYards = function(self,yards)
		self:SetSize(40*yards,40*yards)
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
	self.Circle:SetScript("OnUpdate", function(self, event)
		if (event == "ENCOUNTER_END") then
			self.Circle:Hide()
		else
			if (UnitIsUnit(unit,"target")) then
				self:SetAlpha(config.unselectedalpha)
			else
				self:SetAlpha(0.8)
			end
		end
	end)
	self.Circle:Hide()
	

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
		if (text and UnitIsUnit(text,"player")) then
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

	-- spell monitoring
	-- self.SpellMonitor = CreateFrame("frame", nil, self)
	-- self.SpellMonitor.owner = self
	-- self.SpellMonitor:SetScript("OnUpdate", specialUpdate)

	-- Absorb
	self.TotalAbsorb = CreateFrame('StatusBar', nil, self.Health)
	self.TotalAbsorb:SetAllPoints(self.Health)
	self.TotalAbsorb:SetStatusBarTexture(bdCore.media.flat)
	self.TotalAbsorb:SetStatusBarColor(.1,.1,.1,.6)
	
	-- Raid Icon
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY",nil,7)
	self.RaidTargetIndicator:SetSize(config.raidmarkersize, config.raidmarkersize)
	if (config.markposition == "LEFT") then
		self.RaidTargetIndicator:SetPoint('LEFT', self, "RIGHT", -(config.raidmarkersize/2), 0)
	elseif (config.markposition == "RIGHT") then
		self.RaidTargetIndicator:SetPoint('RIGHT', self, "LEFT", config.raidmarkersize/2, 0)
	else
		self.RaidTargetIndicator:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
	end
	
	-- Quest indicator
	--[[self.Quest = CreateFrame("frame", nil, self.Health)
	self.Quest:SetSize(20,20)
	self.Quest:SetPoint("RIGHT", self.name, "LEFT", -6, 0)
	bdCore:setBackdrop(self.Quest)--]]	

	-- self.PurgeBorder = CreateFrame("frame", nil, self)
	-- self.PurgeBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 1)
	-- self.PurgeBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
	-- self.PurgeBorder:SetBackdrop({edgeFile = bdCore.media.flat, edgeSize = 2})
	-- self.PurgeBorder:SetBackdropBorderColor(unpack(bdCore.media.blue))
	-- self.PurgeBorder:SetFrameLevel(27)
	-- self.PurgeBorder:Hide()
	-- 

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

		-- this is a specialspell
		-- if (config.specialSpells[name] and expiration > self.specialExpiration) then
		-- 	self.specialExpiration = expiration
		-- 	return true
		-- end

		-- purgable spell, whitelist it
		if (config.highlightPurge and isStealable) then
			return true
		end

		-- this is an enrage
		if (config.highlightEnrage and debuffType == "") then
			return true
		end

		-- blacklist is priority
		if (config.blacklist and config.blacklist[name]) then
			return false
		end

		-- if we've whitelisted this inside of bdCore defaults
		if (raidwhitelist[name] or raidwhitelist[spellID]) then
			return true
		end

		-- if the user has whitelisted this
		if (config.whitelist and config.whitelist[name]) then
			return true
		end

		-- automatically display buffs cast by the player in config
		if (config.automydebuff and caster == "player") then
			return true
		end

		-- show if blizzard decided that it was a self-show or all-show aira 
		if (nameplateShowAll or (nameplateShowSelf and caster == "player")) then
			return true
		end

		-- if this is whitelisted for their own casts
		if (config.selfwhitelist and (config.selfwhitelist[name] and caster == "player")) then
			return true
		end
		

		return false
	end
	
	self.Auras.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local cdtext = button.cd:GetRegions()
		button:EnableMouse(false)
		button:SetHeight(config.raidbefuffs*.6)

		if (button.skinned) then return end

		bdCore:setBackdrop(button)
		cdtext:SetFont(bdCore.media.font,14,"OUTLINE")
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
	self.Castbar.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdCore.config.persistent.General.border, bdCore.config.persistent.General.border)
	self.Castbar.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdCore.config.persistent.General.border, -bdCore.config.persistent.General.border)
	
	self.Castbar.PostChannelStart = kickable
	self.Castbar.PostChannelUpdate = kickable
	self.Castbar.PostCastStart = kickable
	self.Castbar.PostCastDelayed = kickable
	self.Castbar.PostCastNotInterruptible = kickable
	self.Castbar.PostCastInterruptible = kickable

	self.Castbar.timeToHold = 1
end

oUF:RegisterStyle("bdNameplates", style) --styleName: String, styleFunc: Function
oUF:SetActiveStyle("bdNameplates")
oUF:SpawnNamePlates("bdNameplates", nameplateCallback)

-- config callbacks
-- bdCore:hookEvent("nameplate_update",bdNameplates.configCallback)
-- bdCore:hookEvent("bd_reconfig", bdNameplates.configCallback)