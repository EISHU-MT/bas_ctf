local cfg = minetest.settings
local ctfcfg = {}

local function GetBoolean(config, fallback)
	local from_cfg = cfg:get_bool(config, fallback)
	if from_cfg == nil then
		from_cfg = fallback
	end
	return from_cfg
end

local function Get(config, fallback)
	local from_cfg = cfg:get(config)
	if not from_cfg or from_cfg == "" then
		from_cfg = fallback
	end
	return from_cfg
end

local function GetNumber(config, fallback)
	local from_cfg = tonumber(cfg:get(config))
	if not from_cfg  then
		from_cfg = fallback
	end
	return from_cfg
end

-- Strings

ctfcfg.PlayerNameTagColor = Get("bctf_PlayerNameTagColor", "#00FFFF")

-- Return Data

return ctfcfg