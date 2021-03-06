local addon, bdNameplates = ...
local config = bdConfigLib:GetSave('Nameplates')

function bdNameplates:enemyStyle(self, event, unit)
	-- names
	self.Name:Show()
	if (config.hideEnemyNames == "Always Hide") then
		self.Name:Hide()
	elseif (config.hideEnemyNames == "Only Target" and not self.isTarget) then
		self.Name:Hide()
	elseif (config.hideEnemyNames == "Hide in Arena") then
		local inInstance, instanceType = IsInInstance();
		if (inInstance and instanceType == "arena") then
			self.Name:Hide()
		end
	end

	if (self.currentStyle and self.currentStyle == "enemy") then return end
	
	-- auras
	self.Auras:Show()
	self.Name:SetTextColor(1,1,1)

	-- castbars
	self:EnableElement("Castbar")
	self.Castbar:ClearAllPoints()
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -bdNameplates:get_border(self.Castbar))
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)

	-- healthbar
	self.Health:Show()
	self.disableFixate = false

	-- power
	self.Power:Hide()

	self.currentStyle = "enemy"
end
