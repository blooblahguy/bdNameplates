local addon, bdNameplates = ...
local config = bdCore.config.profile['Nameplates']

-- v1 done
function bdNameplates:friendlyStyle(self, event, unit)
	local tapDenied = UnitIsTapDenied(unit)
	local isPlayer = UnitIsPlayer(unit) and select(2, UnitClass(unit)) or false
	local reaction = UnitReaction(unit)

	local colors = bdNameplates:unitColor(tapDenied, isPlayer, reaction)
	self.Name:SetTextColor(unpack(colors))

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