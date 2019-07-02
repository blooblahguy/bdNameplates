local addon, bdNameplates = ...
local config = bdConfigLib:GetSave('Nameplates')

-- v1 done
function bdNameplates:personalStyle(self, event, unit)
	if (self.currentStyle and self.currentStyle == "personal") then return end

	ClassNameplateManaBarFrame:Hide()
	ClassNameplateManaBarFrame.Show = noop

	-- castbar
	self:EnableElement("Castbar")
	self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 0, -config.castbarheight)

	-- healthbar
	self.Health:Show()
	if (config.hptext == "None" or config.showhptexttargetonly) then
		self.Curhp:Hide()
	else
		self.Curhp:Show()
	end

	self.disableFixate = true
	bdNameplates:set_border(self)

	-- powerbar
	self.Power:Show()

	-- name
	self.Name:Hide()

	-- auras
	self.Auras:Show()

	self.currentStyle = "personal"
end
