local addon, bdNameplates = ...
local oUF = bdCore.oUF

local config = bdCore.config.profile['Nameplates']

local function npcallback() end

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
		npcallback("", "", frame,unit)
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

local function cvar_set()
	
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

local function enemyStyle(self,unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf

	self.Auras:Show()
	-- self.Debuffs:Show()

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
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf
	
	if (UnitIsUnit(unit,"target")) then
		self:SetAlpha(1)
	else
		self:SetAlpha(0.8)
	end
	
	self.background:Hide()
	-- self.Debuffs:Hide()
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
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf
	
	--self.Power:Hide()
	-- self.Debuffs:Hide()
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

local lastenergy = 0
local function threatColor(self, forced)
	if (UnitIsPlayer(self.unit)) then return end
	local healthbar = self.Health
	local combat = UnitAffectingCombat("player")

	local isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation("player", self.unit)

	-- local threat = select(2, UnitDetailedThreatSituation("player", self.unit));
	-- local targeted = select(1, UnitDetailedThreatSituation("player", self.unit));
	-- local reaction = UnitReaction("player", self.unit);

	-- ptr lets unithealthmax be 0 all the time for some reason
	local perc = 100;
	if (UnitHealthMax(self.unit) ~= 0) then
		perc = (UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100
	end

	-- threat coloring
	if (UnitIsTapDenied(self.unit)) then
		-- 5 people or enemy faction have already tagged this mob
		healthbar:SetStatusBarColor(.5,.5,.5)
	elseif (combat) then 
		if (status == 3) then
			-- securely tanking
			healthbar:SetStatusBarColor(unpack(config.threatcolor))

		elseif (status == 2 or status == 1) then
			-- near or over tank threat
			healthbar:SetStatusBarColor(unpack(config.threatdangercolor))

		elseif (rawthreatpct ~= nil) then
			-- in combat, but not near tank threat
			healthbar:SetStatusBarColor(unpack(config.nothreatcolor))

			-- execute color alert
			if (config.executerange and perc <= config.executerange) then
				healthbar:SetStatusBarColor(unpack(config.executecolor))
			end

		end
	end

	if (self.forceSpecial) then
		healthbar:SetStatusBarColor(unpack(config.specialcolor))
	end

	--[[if (UnitName(unit) == "Ember of Taeshalach") then
		local power = UnitPower(unit)
		if (power >= (lastenergy + 40)) then
			healthbar:SetStatusBarColor(unpack(config.specialcolor))
		end
		lastenergy = power
	end--]]
	
	self.Fixate:Hide()
	if (config.fixatealert == "Always") then
		self.Fixate:Show()
		self.Fixate.text:SetText(UnitName(self.unit.."target"))
	end
	if (config.fixateMobs[name] and UnitExists(self.unit.."target")) then
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

local function npcallback(self, event, unit)
	if (self == nil) then return end

	local scale = UIParent:GetEffectiveScale()*1
	if (not InCombatLockdown()) then
		C_NamePlate.SetNamePlateFriendlySize((config.width * scale) + 10,0.1)
		C_NamePlate.SetNamePlateEnemySize(config.width * scale, (config.height + 10) * scale)
		C_NamePlate.SetNamePlateFriendlyClickThrough(true)
	end
	
	if (self and unit) then
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
		self.Curpower:SetFont(bdCore.media.font, config.height*.85,"OUTLINE")
		self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
		self.Castbar.Text:SetFont(bdCore.media.font, config.castbarheight*.85, "OUTLINE")
		self.Castbar.Icon:SetSize(config.height+config.castbarheight, config.height+config.castbarheight)

		self.Auras:SetSize(config.width+4, config.raidbefuffs)
		self.Auras.size = config.raidbefuffs

		-- self.Debuffs:SetSize(config.width+4, config.debuffsize)
		-- self.Debuffs.size = config.debuffsize

		self.RaidTargetIndicator:SetSize(config.raidmarkersize, config.raidmarkersize)
		self.RaidTargetIndicator:ClearAllPoints()
		self.RaidTargetIndicator:SetAlpha(1)

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
		
		if (config.hidecasticon) then
			self.Castbar.Icon:Hide()
			self.Castbar.bg:Hide()
		else
			self.Castbar.Icon:Show()
			self.Castbar.bg:Show()
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
		
		--nameplate:SetScript("OnUpdate",function() return end)
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
			enemyStyle(self,unit)
		end
		
		if (config.disableauras) then
			self.Auras:Hide()
		end
	end
	
	cvar_set()
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

	oUF.Tags.Events['bdncurpower'] = 'UNIT_POWER_FREQUENT UNIT_POWER PLAYER_TARGET_CHANGED'
	if (bdCore.isBFA) then
		oUF.Tags.Events['bdncurpower'] = 'UNIT_POWER_FREQUENT UNIT_POWER_UPDATE PLAYER_TARGET_CHANGED'
	end
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
	bdNameplates:resourceBuilder(self.Health, unit)

	
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
	self.QuestIndicator = self:CreateTexture(nil, 'OVERLAY')
    self.QuestIndicator:SetSize(20, 20)
    self.QuestIndicator:SetPoint('LEFT', self.Name, 'RIGHT', 2,  0)
	
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
	
	self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	self.Health:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("PLAYER_TARGET_CHANGED",function(self, event)
		npcallback(self, event, self.unit)
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
	self.fixated = false;
	
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

	self.PurgeBorder = CreateFrame("frame", nil, self)
	self.PurgeBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 1)
	self.PurgeBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
	self.PurgeBorder:SetBackdrop({edgeFile = bdCore.media.flat, edgeSize = 2})
	self.PurgeBorder:SetBackdropBorderColor(unpack(bdCore.media.blue))
	self.PurgeBorder:SetFrameLevel(27)
	self.PurgeBorder:Hide()
	
	-- For friendlies
	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(0)
	self.Auras:ClearAllPoints()
	self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
	self.Auras:SetSize(config.width, config.raidbefuffs)
	self.Auras:EnableMouse(false)
	self.Auras.size = config.raidbefuffs
	self.Auras.initialAnchor  = "BOTTOMLEFT"
	self.Auras.spacing = 2
	self.Auras.num = 20
	self.Auras['growth-y'] = "UP"
	self.Auras['growth-x'] = "RIGHT"
	self.Auras.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,timeMod, effect1, effect2, effect3)
		local allow = false

		main.PurgeBorder:Hide()

		if (nameplateShowAll or (nameplateShowSelf and caster == "player")) then
			allow = true
		end
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
	
	self.Auras.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local cdtext = button.cd:GetRegions()
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
		
		button:EnableMouse(false)
		button.icon:SetTexCoord(0.08, 0.9, 0.20, 0.74)
		button:SetHeight(config.raidbefuffs*.6)
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(false)

		if (config.highlightPurge and debuffType == "Magic") then
			main.PurgeBorder:Show()
		end
	end

	-- Special Spells
	local total = 0
	self.SpellMonitor = CreateFrame("frame", nil, self)
	self.SpellMonitor:SetScript("OnUpdate", function(spellmontor, elapsed)
		total = total + elapsed
		if (total > 0.1) then
			self.forceSpecial = false
			for name, v in pairs(config.specialSpells) do
				if (AuraUtil.FindAuraByName(name, self.unit) or AuraUtil.FindAuraByName(name, self.unit, "HARMFUL")) then
					self.forceSpecial = true
					self.Health:SetStatusBarColor(unpack(config.specialcolor))
					break
				end
			end
			local name = UnitName(self.unit) or "";
			if (config.specialunits[name]) then
				self.forceSpecial = true
			end
		end
	end)
	
	
	-- For Enemies
	--[[self.Debuffs = CreateFrame("Frame", nil, self)
	self.Debuffs:SetFrameLevel(0)
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
	self.Debuffs.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,timeMod, effect1, effect2, effect3)
		
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
	--]]

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
end


bdCore:hookEvent("nameplate_update",enumerateNameplates)
bdCore:hookEvent("bd_reconfig", enumerateNameplates)

local tchange = CreateFrame("frame",nil,UIParent)
oUF:RegisterStyle("bdNameplates", style) --styleName: String, styleFunc: Function
oUF:SetActiveStyle("bdNameplates")
oUF:SpawnNamePlates("bdNameplates", npcallback)