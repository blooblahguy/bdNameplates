local addon, bdNameplates = ...
local config = bdConfigLib:GetSave('Nameplates')

-- v1 done
function bdNameplates:friendlyStyle(self, event, unit)
	-- local colors = bdNameplates:unitColor(false, self.isPlayer, self.reaction, false)
	self.Name:SetTextColor(unpack(self.smartColors))
	self.Name:SetAlpha(config.friendnamealpha)

	if (self.currentStyle and self.currentStyle == "friendly") then return end

	-- auras
	self.Auras:Show()

	-- names
	if (config.hidefriendnames) then
		self.Name:Hide()
	else
		self.Name:Show()
		self.Name:SetAlpha(config.friendnamealpha)
	end

	-- castbars
	self:DisableElement("Castbar")

	-- healthbar
	if (config.friendlyplates) then
		self.Health:Show()
	else
		self.Health:Hide()
	end

	-- power
	self.Power:Hide()

	self.currentStyle = "friendly"
end
