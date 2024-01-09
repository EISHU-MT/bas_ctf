-- BlockAssault CaptureTheFlag API
function ctf.get_flag_from(player, flag)
	if bs_match.match_is_started then
		local player_team = bs.get_player_team_css(player)
		hud_events.new(player, {
			text = "(!) You got "..TransformTextReadable(flag).." flag\nRun for your life.",
			color = "success",
			quick = false
		})
		ctf.token_flags[flag] = player
		RunCallbacks(ctf.callbacks.OnTakeFlag, player, flag)
		core.set_node(maps.current_map.teams[flag], {name = "bas_ctf:"..flag.."_flag_taken"})
		for pname in pairs(bs.team[flag].players) do
			if Player(pname) then
				if not bs.spectator[pname] then
					hud_events.new(Player(pname), {
						text = "(!) "..Name(player).." has your flag!\nGo kill him!\nFrom: "..TransformTextReadable(flag),
						color = "warning",
						quick = false
					})
				end
			end
		end
		for pname in pairs(bs.team[player_team].players) do
			if Player(pname) then
				if not bs.spectator[pname] then
					hud_events.new(Player(pname), {
						text = "(!) "..Name(player).." has enemy flag!\nGo protect him!\nFrom: "..TransformTextReadable(flag),
						color = "success",
						quick = false
					})
				end
			end
		end
		if player_team ~= "" then
			for pname in pairs(bs.team[player_team].players) do
				if Player(pname) then
					core.sound_play({name = "ccm_trumpet_win"}, {to_player = pname, gain = 0.6})
				end
			end
		end
	else
		hud_events.new(player, {
			text = "Its prepare time!",
			color = "warning",
			quick = false
		})
	end
end
function ctf.capture_the_flag(player, flag, player_team)
	if bs_match.match_is_started then
		if ctf.token_flags[flag] then
			local i = ctf.token_flags[flag]
			if Name(i) and Name(i) == Name(player) then
				hud_events.new(player, {
					text = "(!) You got "..TransformTextReadable(flag)..".",
					color = "success",
					quick = false
				})
				ctf.token_flags[flag] = nil
				bs.team[flag].state = "neutral"
				RunCallbacks(ctf.callbacks.OnWinFlag, player, flag)
				for pname in pairs(bs.team[flag].players) do
					if Player(pname) then
						core.sound_play({name = "ccm_trumpet_lose"}, {to_player = pname})
					end
				end
				for pname in pairs(bs.team[player_team].players) do
					if Player(pname) then
						core.sound_play({name = "ccm_trumpet_win"}, {to_player = pname, gain = 0.6})
					end
				end
				
				-- Misc
				
				-- Check if theres not other team than this team.
				local theres_other = false
				for team, val in pairs(bs.team) do
					if team ~= player_team then
						if val.state ~= "neutral" then
							theres_other = true
						end
					end
				end
				
				-- Validate exit value
				if theres_other then
					for pname in pairs(bs.team[player_team].players) do
						if Player(pname) then
							core.chat_send_player(pname, "["..TransformTextReadable(player_team).."] Go for those free team(s)!")
						end
					end
				else
					bs_match.finish_match(player_team)
				end
			end
		end
	else
		hud_events.new(player, {
			text = "Its prepare time!",
			color = "warning",
			quick = false
		})
	end
end
function ctf.drop_flag(player, flag)
	local name = Name(player)
	player = Player(player)
	if name then
		if ctf.token_flags[flag] and Name(ctf.token_flags[flag]) == name then
			RunCallbacks(ctf.callbacks.OnDropFlag, player, flag)
			core.set_node(maps.current_map.teams[flag], {name = "bas_ctf:"..flag.."_flag"})
			for pname in pairs(bs.team[flag].players) do
				if not bs.spectator[pname] then
					hud_events.new(Player(pname), {
						text = "Your flag have been recovered",
						color = "success",
						quick = false
					})
				end
			end
			ctf.token_flags[flag] = nil
		end
	end
end

local function set_flags()
	for i, team in pairs({"red", "blue", "yellow", "green"}) do
		if bs.team[team].state == "alive" then
			local coords = table.copy(maps.current_map.teams[team])
			coords.y = coords.y - 1
			core.set_node(coords, {name = "bas_ctf:flag_center"})
			local coords2 = table.copy(coords)
			coords2.y = coords2.y + 1
			core.set_node(coords2, {name = "bas_ctf:"..team.."_flag"})
		end
	end
	-- Clear players
	for team, p in pairs(ctf.token_flags) do
		if Name(p) and Player(p) then
			Player(p):set_nametag_attributes({text=""})
		end
		ctf.token_flags[team] = nil
	end
end

bs_match.register_OnEndMatch(set_flags)
bs_match.register_OnMatchStart(set_flags)
maps.register_on_load(set_flags)

local function get_flags_of(player)
	local name = Name(player)
	local flags = {}
	for team, p in pairs(ctf.token_flags) do
		local pname = Name(p)
		if pname == name then
			table.insert(flags, TransformTextReadable(team))
		end
	end
	return table.concat(flags, ", ")
	--local str = ""
	--for _, t in pairs(flags) do
	--	str = str .. ""
	--end
end

CtfCallbacks.register_OnTakeFlag(function(player, flag)
	if Player(player) then
		Player(player):set_nametag_attributes({
			text = Name(player),
			color = bs.get_player_team_css(player),
		})
	end
end)
CtfCallbacks.register_OnDropFlag(function(player, flag)
	if Player(player) then
		Player(player):set_nametag_attributes({
			text = "",
			color = "",
		})
	end
end)
CtfCallbacks.register_OnWinFlag(function(player, flag)
	if Player(player) then
		Player(player):set_nametag_attributes({
			text = "",
			color = "",
		})
	end
end)

PvpCallbacks.RegisterFunction(function(data)
	local dead_player = Player(data.died)
	local pdead_player = Name(data.died)
	for team, player in pairs(ctf.token_flags) do
		if player and Name(player) then
			if pdead_player == Name(player) then
				ctf.drop_flag(dead_player, team)
			end
		else
			if player then
				ctf.token_flags[team] = nil
			end
		end
	end
end, "CTF Control Function")




