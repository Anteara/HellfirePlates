
-- The default colour used for when the game cannot determine the class type of a player or NPC.
local defaultNameplateColour = 
{ 
	r = 0.541,
	g = 0.122, 
	b = 0.184, 
	hex = "ff8a1f2f" 
}

--The class colours for each class, to be shown on the nameplates.
local classColours =
{
	["shaman"] = 
	{ 
		r = 0,
		g = 0.439, 
		b = 0.871, 
		hex = "ff0070de" 
	},
	["mage"] = 
	{ 
		r = 0.412, 
		g = 0.8, 
		b = 0.941, 
		hex = "ff69ccf0" 
	},
	["warlock"] = 
	{ 
		r = 0.58, 
		g = 0.51, 
		b = 0.788, 
		hex = "ff9482c9" 
	},
	["priest"] = 
	{ 
		r = 1, 
		g = 1, 
		b = 1, 
		hex = "ffffffff" 
	},
	["rogue"] = 
	{ 
		r = 1, 
		g = 0.961, 
		b = 0.412, 
		hex = "fffff569" 
	},
	["hunter"] = 
	{ 
		r = 0.671, 
		g = 0.831, 
		b = 0.451, 
		hex = "ffabd473" 
	},
	["paladin"] = 
	{ 
		r = 0.961, 
		g = 0.549, 
		b = 0.729, 
		hex = "fff58cba" 
	},
	["warrior"] = 
	{ 
		r = 0.78, 
		g = 0.612,
		b = 0.431, 
		hex = "ffc79c6e" 
	},
	["druid"] = 
	{ 
		r = 1, 
		g = 0.49,
		b = 0.039, 
		hex = "ffff7d0a" 
	}
}

--The various slash commands that can be used to access the configuration frame.
SLASH_SHAGUPLATES1 = '/hellfireplates'
SLASH_SHAGUPLATES2 = '/hellfire'
SLASH_SHAGUPLATES3 = '/hf'
SLASH_SHAGUPLATES4 = '/hp'
SLASH_SHAGUPLATES5 = '/hfp'
SLASH_SHAGUPLATES6 = '/plates'
SLASH_SHAGUPLATES7 = '/nameplates'
--Function that will show or hide the configuration frame.
function SlashCmdList.SHAGUPLATES(msg)
  if Hellfire_Options:IsShown() then
	Hellfire_Options:Hide() --new
  else
	Hellfire_Options:Show(); --new
  end
end