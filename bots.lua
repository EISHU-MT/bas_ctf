if bots then
	ctf.team_that_has_bot_to_attack_other = {
		red = {bot=nil,team="",botname=""},
		blue = {bot=nil,team="",botname=""},
		green = {bot=nil,team="",botname=""},
		yellow = {bot=nil,team="",botname=""},
	}
	ctf.bot_flag_token_up = {}
	local function get_available_teams_to_attack(self)
		local teams_available = {}
		local team_of_bot = bots.data[self.bot_name].team
		for team, data in pairs(bs.team) do
			if data.state == "alive" then
				if team ~= team_of_bot then
					table.insert(teams_available, team)
				end
			end
		end
		return teams_available
	end
	function BotsLogicFunction(self)
		if bs_match.match_is_started then
			-- Properties
			local botname = self.bot_name
			local object = self.object
			local team = bots.data[botname].team
			-- Check teams
			if not ctf.team_that_has_bot_to_attack_other[team].bot then
				-- Make this bot go get the enemy flag.
				local teams = get_available_teams_to_attack(self)
				if teams[1] then -- effective
					ctf.team_that_has_bot_to_attack_other[team] = {bot=self.object,team=teams[1],botname=botname}
					local phares = {"I'll cap "..TransformTextReadable(teams[1]), TransformTextReadable(teams[1]).." will be mine", "I'll get "..TransformTextReadable(teams[1]).." please help"}
					local phare = Randomise("", phares)
					bs.send_to_team(team, "### <"..botname.."> "..phare)
				end
			end
			-- Logic
			if ctf.team_that_has_bot_to_attack_other[team].botname == botname then
				-- Scan enemies in bot view
				local detected = {}
				for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), self.view_range+50)) do
					if Name(obj) and Name(obj) ~= self.bot_name then
						if obj:get_luaentity() and obj:get_luaentity().bot_name ~= self.bot_name then
							if bots.is_in_bot_view(self, obj) then
								if obj:get_luaentity() and obj:get_luaentity().bot_name then
									if bots.data[obj:get_luaentity().bot_name] and bots.data[self.bot_name] and bots.data[obj:get_luaentity().bot_name].team ~= bots.data[self.bot_name].team then
										table.insert(detected, obj)
									end
								end
							end
						elseif obj:is_player() and bs_old.get_player_team_css(obj) ~= "" then
							if bots.is_in_bot_view(self, obj) then
								if bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team then
									table.insert(detected, obj)
								end
							end
						end
					end
				end
				-- Shoot to they
				local name = self.bot_name
				for _, obj in pairs(detected) do
					if bots.path_finder_running[self.bot_name] then
						bots.data[name].object:set_animation(bots.bots_animations[name].walk_mine, bots.bots_animations[name].anispeed, 0)
					else
						bots.data[name].object:set_animation(bots.bots_animations[name].mine, bots.bots_animations[name].anispeed, 0)
					end
					local to_use = ""
					local weapon_type = "hand_weapon"
					if bots.data[name].weapons.hard_weapon ~= "" then
						to_use = bots.data[name].weapons.hard_weapon
						weapon_type = "hard_weapon"
					elseif bots.data[name].weapons.hand_weapon ~= "" then
						to_use = bots.data[name].weapons.hand_weapon
						weapon_type = "hand_weapon"
					end
					local itemstack = ItemStack(to_use)
					if itemstack and itemstack ~= "" and itemstack:get_name() ~= "" then
						if not bots.queue_shot[name] then
							bots.in_hand_weapon[self.bot_name] = to_use
							
							--local from = bots.to_2d(self.object:get_pos())
							--local to = bots.to_2d(obj:get_pos())
							--local offset_to = {
							--	x = to.x - from.x,
							--	y = to.y - from.y
							--}
							
							--local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
							
							local damage = itemstack:get_definition().RW_gun_capabilities.gun_damage
							local sound = itemstack:get_definition().RW_gun_capabilities.gun_sound
							local cooldown = itemstack:get_definition().RW_gun_capabilities.gun_cooldown
							local velocity = itemstack:get_definition().RW_gun_capabilities.gun_velocity or bots.default_gun_velocity
							bots.shoot(1, damage or {fleshy=5}, "bs_bots:bullet", sound, velocity, self, obj)
							if weapon_type == "hand_weapon" then
								bots.queue_shot[name] = 0.4
							else
								bots.queue_shot[name] = cooldown or 0.1
							end
							if bots.data[name].wield_item_obj then
								bots.data[name].wield_item_obj:set_properties({
									textures = {itemstack:get_name()},
										visual_size = {x=0.25, y=0.25},
								})
							end
							--self.object:set_yaw(dir)
						end
					end
				end
				-- Lookup for flag
				if (not ctf.bot_flag_token_up[botname]) and (not ctf.team_of_p_has_flag_of[team]) then
					local pos = BsEntities.GetStandPos(self)
					local opos = maps.current_map.teams[ctf.team_that_has_bot_to_attack_other[team].team]
					if vector.distance(pos, opos) > 2 then
						if BsEntities.Timer(self, 1) then
							local path_to_flag = bots.find_path_to(CheckPos(pos), CheckPos(opos))
							if path_to_flag then
								bots.assign_path_to(self, path_to_flag, 1.4)
							end
						end
					else
						if not ctf.team_of_p_has_flag_of[team] then
							ctf.get_flag_from(self.object, ctf.team_that_has_bot_to_attack_other[team].team)
							ctf.bot_flag_token_up[botname] = true
						end
					end
				else
					if not ctf.team_of_p_has_flag_of[team] then
						local pos = BsEntities.GetStandPos(self)
						local opos = maps.current_map.teams[team]
						if vector.distance(pos, opos) > 2 then
							if BsEntities.Timer(self, 1) then
								local path_to_flag = bots.find_path_to(CheckPos(pos), CheckPos(opos))
								if path_to_flag then
									bots.assign_path_to(self, path_to_flag, 1.4)
								end
							end
						else
							ctf.capture_the_flag(self.object, ctf.team_that_has_bot_to_attack_other[team].team, team)
							ctf.bot_flag_token_up[botname] = nil
						end
					else
						Logic.OldOnStep(self)
					end
				end
			else --bas_ctf:red_flag_taken
				if core.get_node(maps.current_map.teams[team]).name ~= "bas_ctf:"..team.."_flag_taken" then
					Logic.OldOnStep(self)
				else
					-- Find enemy
					--for team, data in pairs(ctf.team_that_has_bot_to_attack_other) do
					--	print(dump(data))
					--	if data and data.bot and data.team == team then
					--		bots.Hunt(self, data.bot, 1.7)
					--		core.chat_send_all("hunting "..Name(data.bot))
					--	end
					--end
					for teamA, obj in pairs(ctf.token_flags) do
						if teamA == team then
							bots.Hunt(self, obj, 1.8, true)
						end
					end
					-- Scan enemies in bot view
					local detected = {}
					for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), self.view_range+5)) do
						if Name(obj) and Name(obj) ~= self.bot_name then
							if obj:get_luaentity() and obj:get_luaentity().bot_name ~= self.bot_name then
								if bots.is_in_bot_view(self, obj) then
									if obj:get_luaentity() and obj:get_luaentity().bot_name then
										if bots.data[obj:get_luaentity().bot_name] and bots.data[self.bot_name] and bots.data[obj:get_luaentity().bot_name].team ~= bots.data[self.bot_name].team then
											table.insert(detected, obj)
										end
									end
								end
							elseif obj:is_player() and bs_old.get_player_team_css(obj) ~= "" then
								if bots.is_in_bot_view(self, obj) then
									if bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team then
										table.insert(detected, obj)
									end
								end
							end
						end
					end
					-- Shoot to they
					local name = self.bot_name
					for _, obj in pairs(detected) do
						if bots.path_finder_running[self.bot_name] then
							bots.data[name].object:set_animation(bots.bots_animations[name].walk_mine, bots.bots_animations[name].anispeed, 0)
						else
							bots.data[name].object:set_animation(bots.bots_animations[name].mine, bots.bots_animations[name].anispeed, 0)
						end
						local to_use = ""
						local weapon_type = "hand_weapon"
						if bots.data[name].weapons.hard_weapon ~= "" then
							to_use = bots.data[name].weapons.hard_weapon
							weapon_type = "hard_weapon"
						elseif bots.data[name].weapons.hand_weapon ~= "" then
							to_use = bots.data[name].weapons.hand_weapon
							weapon_type = "hand_weapon"
						end
						local itemstack = ItemStack(to_use)
						if itemstack and itemstack ~= "" and itemstack:get_name() ~= "" then
							if not bots.queue_shot[name] then
								bots.in_hand_weapon[self.bot_name] = to_use
								
								local from = bots.to_2d(self.object:get_pos())
								local to = bots.to_2d(obj:get_pos())
								local offset_to = {
									x = to.x - from.x,
									y = to.y - from.y
								}
								
								local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
								
								local damage = itemstack:get_definition().RW_gun_capabilities.gun_damage
								local sound = itemstack:get_definition().RW_gun_capabilities.gun_sound
								local cooldown = itemstack:get_definition().RW_gun_capabilities.gun_cooldown
								local velocity = itemstack:get_definition().RW_gun_capabilities.gun_velocity or bots.default_gun_velocity
								bots.shoot(1, damage or {fleshy=5}, "bs_bots:bullet", sound, velocity, self, obj)
								if weapon_type == "hand_weapon" then
									bots.queue_shot[name] = 0.4
								else
									bots.queue_shot[name] = cooldown or 0.1
								end
								if bots.data[name].wield_item_obj then
									bots.data[name].wield_item_obj:set_properties({
										textures = {itemstack:get_name()},
											visual_size = {x=0.25, y=0.25},
									})
								end
								self.object:set_yaw(dir)
							end
						end
					end
				end
			end
		end
	end
	BotsCallbacks.RegisterOnKillBot(function(self, killer)
		if self then
			local name = self.bot_name
			local team = bots.data[name].team
			if ctf.team_that_has_bot_to_attack_other[team].botname == name then
				ctf.drop_flag(self.object, ctf.team_that_has_bot_to_attack_other[team].team)
				ctf.team_that_has_bot_to_attack_other[team] = {bot=nil,team="",botname=""}
			end
		end
	end)
end










