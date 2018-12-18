local addon, bdNameplates = ...
local config = bdCore.config.profile['Nameplates']

local unpack, UnitPlayerControlled, UnitIsTapDenied, UnitIsPlayer, UnitClass, UnitReaction, format, floor = unpack, UnitPlayerControlled, UnitIsTapDenied, UnitIsPlayer, UnitClass, UnitReaction, string.format, math.floor

local colorCache = {}
local colors = {}
colors.tapped = {.6,.6,.6}
colors.offline = {.6,.6,.6}
colors.reaction = {}
colors.class = {}

-- class colors
for eclass, color in next, RAID_CLASS_COLORS do
	if not colors.class[eclass] then
		colors.class[eclass] = {color.r, color.g, color.b}
	end
end

-- factino colors
for eclass, color in next, FACTION_BAR_COLORS do
	if not colors.reaction[eclass] then
		colors.reaction[eclass] = {color.r, color.g, color.b}
	end
end

local function colorSave(self, tapDenied, isPlayer, reaction, status, executable)
	-- if (unit == 'player' or UnitIsUnit('player', unit) or UnitIsFriend('player', unit) or status == nil) then
-- 		self.Health:SetStatusBarColor(bdNameplates:unitColor(unit))
-- 	elseif (status ~= nil and not UnitIsTapDenied(unit) and not UnitIsPlayer(unit) and (event == "UNIT_THREAT_LIST_UPDATE" or event == "NAME_PLATE_UNIT_ADDED")) then

	if (isPlayer) then
		return colors.class[isPlayer]
	elseif (config.executecoloring and executable and not tapDenied) then
		return config.executecolor
	elseif (status == false) then
		if (tapDenied) then
			return colors.tapped
		else
			return colors.reaction[reaction]
		end
	else
		if (status == 3) then
			-- securely tanking
			return config.threatcolor
		elseif (status == 2 or status == 1) then
			-- near or over tank threat
			return config.threatdangercolor
		else
			-- on threat table, but not near tank threat
			return config.nothreatcolor
		end
	end
end

bdNameplates.unitColor = memoize(colorSave, bdNameplates.cache)



function bdNameplates:numberize(v)
	if v <= 9999 then return v end
	if v >= 1000000000 then
		local value = format("%.1fb", v/1000000000)
		return value
	elseif v >= 1000000 then
		local value = format("%.1fm", v/1000000)
		return value
	elseif v >= 10000 then
		local value = format("%.1fk", v/1000)
		return value
	end
end

function bdNameplates:round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return floor(num * mult + 0.5) / mult
end