-- BlockAssault Capture The Flag
ctf = {
	modpath = core.get_modpath(core.get_current_modname()),
	token_flags = {},
	callbacks = {
		OnTakeFlag = {},
		OnDropFlag = {},
		OnWinFlag = {},
	}
}
-- Touch BAS config
core.log("action", "Initializing CTF")
config.IsDefaultGame = false
config.EnableShopTable = false
config.GameClass = "BA Capture The Flag"
PvpMode.Mode = 2
-- Generate Callbacks
CtfCallbacks = {}
CtfCallbacks["register_OnTakeFlag"] = function(function_to_run) table.insert(ctf.callbacks.OnTakeFlag, function_to_run) core.log("action", "Registered OnTakeFlag function") end
CtfCallbacks["register_OnDropFlag"] = function(function_to_run) table.insert(ctf.callbacks.OnDropFlag, function_to_run) core.log("action", "Registered OnDropFlag function") end
CtfCallbacks["register_OnWinFlag"] = function(function_to_run) table.insert(ctf.callbacks.OnWinFlag, function_to_run) core.log("action", "Registered OnWinFlag function") end
-- Check Engine if available
if not bs then
	error("BlockAssault Engine is not found.")
end
-- Load config
ctf.config = dofile(ctf.modpath.."/config.lua")
-- Load API
dofile(ctf.modpath.."/api.lua")
dofile(ctf.modpath.."/bots.lua")
-- Register nodes
minetest.register_node("bas_ctf:red_flag", {
	drawtype = "mesh",
	mesh = "ccm_flag.obj",
	tiles = {"ccm_red_flag.png"},
	visual_scale = 0.4,
	pointable = true,
	sunlight_propagates = true,
	diggable = true,
	light_source = 14,
	buildable_to = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" then
			if bs.get_player_team_css(name) == "red" then
				if bs_match.match_is_started == false or not bs_match.match_is_started then
					core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
				else
					hud_events.new(player, {
						text = "You cant trade at this moment!\nOnly in build time",
						color = "warning",
						quick = true,
					})
				end
			else
				local exit_value = false
				for flag, person in pairs(ctf.token_flags) do
					if person and Name(person) == name then
						local ev = ctf.capture_the_flag(clicker, flag, "red")
						if ev then
							exit_value = true
						end
					end
				end
				if not exit_value then
					hud_events.new(clicker, {
						text = "(!) No flag to capture!",
						color = "warning",
						quick = false
					})
				end
			end
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local player = Player(puncher)
		local name = Name(puncher)
		if bs.get_player_team_css(name) ~= "" then
			if bs.get_player_team_css(name) == "red" then
				local exit_value = false
				for flag, person in pairs(ctf.token_flags) do
					if person and Name(person) == name then
						local ev = ctf.capture_the_flag(player, flag, "red")
						if ev then
							exit_value = true
						end
					end
				end
				if not exit_value then
					hud_events.new(player, {
						text = "(!) No flag to capture!",
						color = "warning",
						quick = false
					})
				end
			else
				ctf.get_flag_from(player, "red")
			end
		end
	end,
})

minetest.register_node("bas_ctf:blue_flag", {
	drawtype = "mesh",
	mesh = "ccm_flag.obj",
	tiles = {"ccm_blue_flag.png"},
	visual_scale = 0.4,
	pointable = true,
	light_source = 14,
	sunlight_propagates = true,
	diggable = true,
	buildable_to = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" then
			if bs.get_player_team_css(name) == "blue" then
				if bs_match.match_is_started == false or not bs_match.match_is_started then
					core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
				else
					hud_events.new(player, {
						text = "You cant trade at this moment!\nOnly in build time",
						color = "warning",
						quick = true,
					})
				end
			else
				local exit_value = false
				for flag, person in pairs(ctf.token_flags) do
					if person and Name(person) == name then
						local ev = ctf.capture_the_flag(clicker, flag, "blue")
						if ev then
							exit_value = true
						end
					end
				end
				if not exit_value then
					hud_events.new(clicker, {
						text = "(!) No flag to capture!",
						color = "warning",
						quick = false
					})
				end
			end
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local player = Player(puncher)
		local name = Name(puncher)
		if bs.get_player_team_css(name) ~= "" then
			if bs.get_player_team_css(name) == "blue" then
				local exit_value = false
				for flag, person in pairs(ctf.token_flags) do
					if person and Name(person) == name then
						local ev = ctf.capture_the_flag(player, flag, "blue")
						if ev then
							exit_value = true
						end
					end
				end
				if not exit_value then
					hud_events.new(player, {
						text = "(!) No flag to capture!",
						color = "warning",
						quick = false
					})
				end
			else
				ctf.get_flag_from(player, "blue")
			end
		end
	end,
})

minetest.register_node("bas_ctf:green_flag", {
	drawtype = "mesh",
	mesh = "ccm_flag.obj",
	tiles = {"ccm_red_flag.png"},
	visual_scale = 0.4,
	pointable = true,
	light_source = 14,
	sunlight_propagates = true,
	diggable = true,
	buildable_to = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" then
			if bs.get_player_team_css(name) == "green" then
				if bs_match.match_is_started == false or not bs_match.match_is_started then
					core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
				else
					hud_events.new(player, {
						text = "You cant trade at this moment!\nOnly in build time",
						color = "warning",
						quick = true,
					})
				end
			else
				local exit_value = false
				for flag, person in pairs(ctf.token_flags) do
					if person and Name(person) == name then
						local ev = ctf.capture_the_flag(clicker, flag, "green")
						if ev then
							exit_value = true
						end
					end
				end
				if not exit_value then
					hud_events.new(clicker, {
						text = "(!) No flag to capture!",
						color = "warning",
						quick = false
					})
				end
			end
		end
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local player = Player(puncher)
		local name = Name(puncher)
		if bs.get_player_team_css(name) ~= "" then
			if bs.get_player_team_css(name) == "green" then
				local exit_value = false
				for flag, person in pairs(ctf.token_flags) do
					if person and Name(person) == name then
						local ev = ctf.capture_the_flag(player, flag, "green")
						if ev then
							exit_value = true
						end
					end
				end
				if not exit_value then
					hud_events.new(player, {
						text = "(!) No flag to capture!",
						color = "warning",
						quick = false
					})
				end
			else
				ctf.get_flag_from(player, "green")
			end
		end
	end,
})

-- Taken Flags

minetest.register_node("bas_ctf:green_flag_taken", {
	drawtype = "mesh",
	mesh = "ccm_flag_taken.obj",
	tiles = {"ccm_green_flag.png"},
	visual_scale = 0.4,
	pointable = true,
	light_source = 14,
	sunlight_propagates = true,
	diggable = true,
	buildable_to = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" and bs.get_player_team_css(name) == "green" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
	on_punch = function(pos, node, clicker, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" and bs.get_player_team_css(name) == "green" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
})

minetest.register_node("bas_ctf:yellow_flag_taken", {
	drawtype = "mesh",
	mesh = "ccm_flag_taken.obj",
	tiles = {"ccm_yellow_flag.png"},
	visual_scale = 0.4,
	pointable = true,
	light_source = 14,
	sunlight_propagates = true,
	diggable = true,
	buildable_to = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" and bs.get_player_team_css(name) == "yellow" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
	on_punch = function(pos, node, clicker, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" and bs.get_player_team_css(name) == "yellow" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
})

minetest.register_node("bas_ctf:blue_flag_taken", {
	drawtype = "mesh",
	mesh = "ccm_flag_taken.obj",
	tiles = {"ccm_red_flag.png"},
	visual_scale = 0.4,
	light_source = 14,
	pointable = true,
	sunlight_propagates = true,
	diggable = true,
	buildable_to = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" and bs.get_player_team_css(name) == "blue" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
	on_punch = function(pos, node, clicker, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" and bs.get_player_team_css(name) == "blue" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
})

minetest.register_node("bas_ctf:red_flag_taken", {
	drawtype = "mesh",
	mesh = "ccm_flag_taken.obj",
	tiles = {"ccm_red_flag.png"},
	light_source = 14,
	visual_scale = 0.4,
	pointable = true,
	sunlight_propagates = true,
	diggable = true,
	buildable_to = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" and bs.get_player_team_css(name) == "red" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
	on_punch = function(pos, node, clicker, pointed_thing)
		local player = Player(clicker)
		local name = Name(clicker)
		if bs.get_player_team_css(name) ~= "" and bs.get_player_team_css(name) == "red" then
			if (bs_match.match_is_started == false or not bs_match.match_is_started) or config.AlwaysShopOpen then
				core.show_formspec(name, "shop:main", Shop.ShowFormspec(bank.return_val(name)))
			else
				hud_events.new(player, {
					text = "You cant trade at this moment!\nOnly in build time",
					color = "warning",
					quick = true,
				})
			end
		end
	end,
})

-- Center

minetest.register_node("bas_ctf:flag_center", {
	description = "Under Flag Center",
	paramtype = "light",
	tiles = {"ccm_under_flag_center.png", "ccm_under_flag_center_side.png", "ccm_under_flag_center_side.png", "ccm_under_flag_center_side.png", "ccm_under_flag_center_side.png", "ccm_under_flag_center_side.png"},
	sunlight_propagates = false,
	walkable = true,
	pointable = false,
	diggable = false,
	light_source = 14,
	buildable_to = false,
	floodable = true,
	air_equivalent = false,
	drop = "",
	groups = {immortal=1},
})













































