local addon, bdNameplates = ...

local config = bdCore.config.profile['Nameplates']

function bdNameplates:resourceBuilder(frame, unit)
	local unitClass = select(2, UnitClass("player"))
	local maxWidth = frame:GetWidth()

	-- create resource bars
	frame.ClassPower = {}
	for index = 1, 10 do
        local bar = CreateFrame('StatusBar', nil, frame)
        frame.ClassPower[index] = Bar
    end

	-- resize function
	function frame.ClassPower:SizeResources(cur, max, hasMaxChanged, powerType)
		if (hasMaxChanged) then
			-- Position and size.
			for i = 1, #frame.ClassPower do
				local bar = frame.ClassPower[i]
				bar:Show()
				if (i > max) then
					bar:Hide()
				end

				bar:SetSize(maxWidth / max, config.resourceHeight)
				bar:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT', (index - 1) * bar:GetWidth(), 0)
			end
		end
	end
	frame.ClassPower:SizeResources(0, 10, true)

	-- Any time resources update, run this function
	function frame.ClassPower:PostUpdate(cur, max, hasMaxChanged, powerType)
		if (not config.trackResources) then
			frame.ClassPower:Hide()
			return
		end

		-- hide, resize, and reposition
		frame.ClassPower:SizeResources(cure, max, hasMaxChanged, powerType)

		-- todo custom colors?
		-- if (powerType == ) then

		-- end		
	end

end