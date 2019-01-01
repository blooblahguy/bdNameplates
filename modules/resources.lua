local addon, bdNameplates = ...
local config = bdConfigLib:GetSave("Nameplates")

function bdNameplates:resourceBuilder(frame, unit)
	-- print("here")
	local unitClass = select(2, UnitClass("player"))
	local maxWidth = frame:GetWidth()

	-- create resource bars
	frame.ClassPower = {}
	for index = 1, 10 do
        local bar = CreateFrame('StatusBar', nil, frame)
		bar:SetStatusBarTexture(bdCore.media.flat)
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
					-- bar:Hide()
				end				
			end
			
		end

		for i = 1, #frame.ClassPower do
			local bar = frame.ClassPower[i]
			bar:SetSize(maxWidth / max, config.resourceHeight)
			bar:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT', (index - 1) * bar:GetWidth(), 2)
		end
	end
	frame.ClassPower:SizeResources(0, 10, true)

	-- Any time resources update, run this function
	frame.ClassPower.PostUpdate = function(self, cur, max, hasMaxChanged, powerType)
		print("here")
		if (not config.trackResources) then
			frame.ClassPower:Hide()
			return
		end
		frame.ClassPower:Show()
		print("here")

		-- hide, resize, and reposition
		frame.ClassPower:SizeResources(cure, max, hasMaxChanged, powerType)

		-- todo custom colors?
		-- if (powerType == ) then

		-- end		
	end

end