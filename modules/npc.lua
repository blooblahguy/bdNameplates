local addon, bdNameplates = ...
local config = bdConfigLib:GetSave('Nameplates')

-- v1 done
function bdNameplates:npcStyle(self, event, unit)
	-- local colors = bdNameplates:unitColor(false, false, self.reaction, false)
	self.Name:SetTextColor(unpack(self.colors))

	if (self.currentStyle and self.currentStyle == "npc") then return end

	-- castbar
	self:DisableElement("Castbar")

	-- healthbar
	self.Health:Hide()

	-- powerbar
	self.Power:Hide()

	-- name
	self.Name:Show()

	-- auras
	self.Auras:Hide()

	self.currentStyle = "npc"
end
