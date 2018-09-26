local addon, bdNameplates = ...

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

function bdNameplates:unitColor(unit)
	if(not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		return unpack(colors.tapped)
	elseif UnitIsPlayer(unit) then
		return unpack(colors.class[select(2, UnitClass(unit))])
	else
		return unpack(colors.reaction[UnitReaction(unit, 'player')])
	end
end

function bdNameplates:numberize(v)
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

function bdNameplates:round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end