local addon, bdNameplates = ...
local config = bdConfigLib:GetSave("Nameplates")

-- v1 done
function bdNameplates:personalStyle(self, event, unit)
	if (self.currentStyle and self.currentStyle == "personal") then return end

	-- castbar
	self:EnableElement("Castbar")
	self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 0, -config.castbarheight)
	if (config.hidecasticon) then
		self.Castbar.Icon:Hide()
		self.Castbar.bg:Hide()
	else
		self.Castbar.Icon:Show()
		self.Castbar.bg:Show()
	end

	-- healthbar
	self.Health:Show()
	if (config.hptext == "None" or config.showhptexttargetonly) then
		self.Curhp:Hide()
	else
		self.Curhp:Show()
	end

	-- powerbar
	self.Power:Show()

	-- name
	self.Name:Hide()

	-- auras
	self.Auras:Show()

	self.currentStyle = "personal"
end