local addon, bdNameplates = ...
local config = bdCore.config.profile['Nameplates']

function bdNameplates:enemyStyle(self, event, unit)
	if (self.currentStyle and self.currentStyle == "enemy") then return end
	
	-- auras
	self.Auras:Show()

	-- names
	self.Name:Show()
	self.Name:SetTextColor(1,1,1)
	if (config.hideEnemyNames == "Always Hide") then
		self.Name:Hide()
	elseif (config.hideEnemyNames == "Only Target") then
		if (not UnitIsUnit(unit, "target")) then
			self.Name:Hide()
		end
	elseif (config.hideEnemyNames == "Hide in Arena") then
		local inInstance, instanceType = IsInInstance();
		if (inInstance and instanceType == "arena") then
			self.Name:Hide()
		end
	end

	-- castbars
	self:EnableElement("Castbar")
	self.Castbar:ClearAllPoints()
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
	self.Castbar.Icon:SetSize(config.height+config.castbarheight, config.height+config.castbarheight)
	if (config.hidecasticon) then
		self.Castbar.Icon:Hide()
		self.Castbar.bg:Hide()
	else
		self.Castbar.Icon:Show()
		self.Castbar.bg:Show()
	end

	-- healthbar
	self.Health:Show()

	-- power
	self.Power:Hide()

	self.currentStyle = "enemy"
end