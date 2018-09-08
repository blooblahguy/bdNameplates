local addon, bdNameplates = ...

-- populate configuration lists
local defaultwhitelist = {}
defaultwhitelist['Arcane Torrent'] = true
defaultwhitelist['War Stomp'] = true

local fixateMobs = {}
fixateMobs['Tormented Fragment'] = true
fixateMobs['Razorjaw Gladiator'] = true
fixateMobs['Sickly Tadpole'] = true
fixateMobs['Soul Residue'] = true
fixateMobs['Nightmare Ichor'] = true
fixateMobs['Atrigan'] = true

local specialMobs = {}
specialMobs["Fel Explosives"] = true
specialMobs["Fanatical Pyromancer"] = true
specialMobs["Felblaze Imp"] = true
specialMobs["Hungering Stalker"] = true
specialMobs["Fel-Powered Purifier"] = true
specialMobs["Fel-Infused Destructor"] = true
specialMobs["Fel-Charged Obfuscator"] = true
specialMobs["Ember of Taeshalach"] = true
specialMobs["Screaming Shrike"] = true


local defaults = {}

--------------
-- Positioning & Display
--------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="Sizing & Display"
}}
defaults[#defaults+1] = {friendnamealpha={
	type="slider",
	value=1,
	min=0,
	max=1,
	step=0.1,
	label="Friendly Name Opacity",
	callback=function() bdNameplates:configCallback() end
}}

defaults[#defaults+1] = {friendlyplates={
	type = "checkbox",
	value = false,
	label = "Show Friendly Health Plates",
	tooltip = "Enable this to show friendly health plates",
	callback = function() bdNameplates:configCallback() end
}}

defaults[#defaults+1] = {trackResources = {
	type = "checkbox",
	value = true,
	label = "Display class resources on nameplates.",
	callback = function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {resourceHeight={
	type="slider",
	value=12,
	min=2,
	max=50,
	step=2,
	label="Resource height",
	callback=function() bdNameplates:configCallback() end
}}

defaults[#defaults+1] = {highlightPurge = {
	type = "checkbox",
	value = false,
	label = "Highlist units who have auras that can be purged",
	callback = function() bdNameplates:configCallback() end
}}

defaults[#defaults+1] = {friendlynamehack = {
	type = "checkbox",
	value = false,
	label = "Friendly Names in Raid",
	tooltip = "This will disable friendly nameplates in raid while keeping the friendly name. Uncheck this before uninstalling bdNameplates. ",
	callback = function() bdNameplates:configCallback() end
}}

defaults[#defaults+1] = {width={
	type="slider",
	value=200,
	min=30,
	max=250,
	step=2,
	label="Nameplates Width",
	callback=function() bdNameplates:configCallback() end
}}

defaults[#defaults+1] = {height={
	type="slider",
	value=20,
	min=4,
	max=50,
	step=2,
	label="Nameplates Height",
	callback=function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {verticalspacing={
	type="slider",
	value=1.8,
	min=0,
	max=4,
	step=0.1,
	label="Vertical Spacing",
	callback=function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {castbarheight={
	type="slider",
	value=18,
	min=4,
	max=50,
	step=2,
	label="Castbar Height",
	callback=function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {nameplatedistance={
	type="slider",
	value=50,
	min=10,
	max=100,
	step=2,
	label="Nameplates Draw Distance",
	callback=function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {hidecasticon = {
	type = "checkbox",
	value = false,
	label = "Hide Castbar Icon",
	callback = function() bdNameplates:configCallback() end
}}
--[[
defaults[#defaults+1] = {nameplatemotion = {
	type = "dropdown",
	value = 1,
	options = {1,0},
	label = "Stacking: 1 for stacked, 0 for overlapping",
	callback = function() cvar_set() end
}}--]]

-------------
-- Text
-------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="Text"
}}
defaults[#defaults+1] = {hptext = {
	type = "dropdown",
	value = "HP - %",
	options = {"None","HP - %", "HP", "%"},
	label = "Nameplate Health Text",
	callback = function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {fixatealert = {
	type = "dropdown",
	value = "All",
	options = {"All","Always","Personal","None"},
	label = "Fixate Alert."
}}
defaults[#defaults+1] = {showhptexttargetonly = {
	type = "checkbox",
	value = false,
	label = "Show Health Text on target only",
	callback = function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {showenergy = {
	type = "checkbox",
	value = false,
	label = "Show energy value on healthbar",
	callback = function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {hidefriendnames = {
	type = "checkbox",
	value = false,
	label = "Hide Friendly Names",
	callback = function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {enemynamesize={
	type="slider",
	value=16,
	min=8,
	max=24,
	step=1,
	label="Enemy Name Font Size",
	callback=function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {friendlynamesize={
	type="slider",
	value=16,
	min=8,
	max=24,
	step=1,
	label="Friendly Name Font Size",
	callback=function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {markposition = {
	type = "dropdown",
	value = "TOP",
	options = {"LEFT","TOP","RIGHT"},
	label = "Raid Marker position",
	tooltip = "Where raid markers should be positioned on the nameplate.",
	callback = function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {raidmarkersize={
	type="slider",
	value=24,
	min=10,
	max=50,
	step=2,
	label="Raid Marker Icon Size",
	callback=function() bdNameplates:configCallback() end
}}

-------------
-- Colors
-------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="Colors"
}}
defaults[#defaults+1] = {kickable={
	type="color",
	value={.1, .4, .7, 1},
	name="Interruptable Cast Color"
}}
defaults[#defaults+1] = {nonkickable={
	type="color",
	value={.7, .7, .7, 1},
	name="Non-Interruptable Cast Color"
}}
defaults[#defaults+1] = {glowcolor={
	type="color",
	value={1,1,1,1},
	name="Target Glow Color"
}}
defaults[#defaults+1] = {threatcolor={
	type="color",
	value={.79, .3, .21, 1},
	name="Have Aggro Color"
}}
defaults[#defaults+1] = {nothreatcolor={
	type="color",
	value={0.3, 1, 0.3,1},
	name="No Aggro Color"
}}
defaults[#defaults+1] = {threatdangercolor={
	type="color",
	value={1, .55, 0.3,1},
	name="Danger Aggro Color"
}}
defaults[#defaults+1] = {executecolor={
	type="color",
	value={.1, .4, .7,1},
	name="Execute Range Color"
}}
defaults[#defaults+1] = {specialcolor={
	type="color",
	value={.8, .4, .7,1},
	name="Special Unit Color"
}}
defaults[#defaults+1] = {executerange = {
	type = "slider",
	value=20,
	min=0,
	max=40,
	step=5,
	label = "Execute range",
	callback = function() bdNameplates:configCallback() end
}}
defaults[#defaults+1] = {unselectedalpha={
	type="slider",
	value=0.5,
	min=0.1,
	max=1,
	step=0.1,
	label="Unselected nameplate alpha",
	callback=function() bdNameplates:configCallback() end
}}
-------------
-- Special Units
-------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="Special Units"
}}
defaults[#defaults+1] = {specialunits={
	type = "list",
	value = specialMobs,
	label = "Special Unit List",
	tooltip = "Units who's name are in this list will have their healthbar colored with the 'Special Unit Color' "
}}
defaults[#defaults+1] = {fixateMobs={
	type = "list",
	value = fixateMobs,
	label = "Fixate Unit List",
	tooltip = "Units who's name are in this list will have a fixate icon when they target you."
}}
-------------
-- Target
-------------
--[[defaults[#defaults+1] = {tab = {
	type="tab",
	value="Target"
}}



defaults[#defaults+1] = {showfriendlybar = {
	type = "checkbox",
	value = false,
	label = "Show health bar when targeting friendly.",
	callback = function() bdNameplates:configCallback() end
}}--]]

-------------
-- Your Debuffs
-------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="Your Debuffs"
}}
defaults[#defaults+1] = {automydebuff={
	type="checkbox",
	value=false,
	label="Automatically track debuffs cast by you."
}}
defaults[#defaults+1] = {selfwhitelist={
	type="list",
	value={},
	label="Enemy Debuffs (cast by you)",
	tooltip="Use to show a specified aura cast by you."
}}

-------------
-- Anyone's Auras
-------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="All Auras"
}}
defaults[#defaults+1] = {raidbefuffs={
	type="slider",
	value=50,
	min=20,
	max=100,
	step=2,
	label="Raid Debuff Size",
}}
defaults[#defaults+1] = {whitelist={
	type="list",
	value=defaultwhitelist,
	label="Friendly/Enemy Auras (cast by anyone)",
	tooltip="Use to show a specified aura cast by anyone."
}}

-------------
-- Blacklist
-------------
defaults[#defaults+1] = {tab = {
	type="tab",
	value="Blacklist"
}}
defaults[#defaults+1] = {disableauras={
	type="checkbox",
	value=false,
	label="Don't show any auras."
}}
defaults[#defaults+1] = {text = {
	type="text",
	value="Certain abilities are tracked by default, i.e. stuns / silences. You can stop these from showing up using the blacklist. "
}}
defaults[#defaults+1] = {blacklist={
	type="list",
	value={},
	label="Aura Blacklist",
	tooltip="Useful if you want to blacklist any auras that Blizzard tracks by default."
}}


bdCore:addModule("Nameplates", defaults)

