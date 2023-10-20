--Now that Factorio supports in-game settings, the DMR mod is no longer configured by editing the start of this file.

--Stats for the first tier of replicators
local speed_base = settings.startup["replstats-speed-base"].value
local energy_base = settings.startup["replstats-energy-base"].value
local pollution_base = settings.startup["replstats-pollution-base"].value
local size_base = settings.startup["replstats-size-base"].value
local module_slots_base = settings.startup["replstats-modules-base"].value

--Every time the replictor tier increases by 1 its stats are multiplied by these numbers
local speed_factor = settings.startup["replstats-speed-factor"].value
local energy_factor = settings.startup["replstats-energy-factor"].value
local pollution_factor = settings.startup["replstats-pollution-factor"].value

--Every time the replictor tier increases by 1 its stats are added to these numbers
--Both of these are rounded down after addition
local size_addend = settings.startup["replstats-size-addend"].value 
local module_slots_addend = settings.startup["replstats-modules-addend"].value

--Research settings
local reps_multiplier = settings.startup["replresearch-tier-multiplier"].value
local research_time = settings.startup["replresearch-tier-time"].value


function make_replicator(tier, research_prerequisites, ingredients)
	--Create a table containing the research cost for this tier of replication
	local research_cost = repl_research(tier, reps_multiplier, research_time)
	
	--Add the previous tier of replication as a requried prerequisites
	if tier > 1 then
		research_prerequisites[#research_prerequisites + 1] = 'replication-'..(tier-1)
	end
	
	--Add the previous tier of replicator as a requried ingredient
	if tier > 1 then
		ingredients[#ingredients + 1] = {'replicator-'..(tier-1), 1}
	end
	
	--Calculate how much energy this replicator uses
	local power_consumption = (energy_base * energy_factor^(tier-1))
	
	--Calculate the size values
	local entity_corner = math.max(1, math.floor(size_base + size_addend * (tier-1))) / 2
	local hitbox_corner = entity_corner - 0.2
	local pipe_connector_offset = 0
	--You can't center a fluid pipe on an even-sized edge, so nudge the connection point half a square to the left if that's the case
	if math.floor(entity_corner) == entity_corner then
		pipe_connector_offset = -0.5
	end
	
	--Create the list of recipe categories that this replicator can replicate
	local categories = {}
	for currentAndLowerTiers=0,tier do
		categories[#categories+1] = 'replication-'..currentAndLowerTiers
	end
	
	--Now that all the appropriate calculations have been performed, create the prototypes for the actual replicator
	data:extend({
		--Create the prototype for the replicator's technology
		{
			type = "technology",
			name = "replication-"..tier,
			icon = "__fire-replicators__/graphics/icons/replicator-"..tier..".png",
			icon_size = 32,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "replicator-"..tier
				}
			},
			prerequisites = research_prerequisites,
			unit = research_cost,
			upgrade = true,
			order = "a-r-"..tier
		},
		
		--Create the prototype for the replicator's recipe
		{
			type = "recipe",
			name = "replicator-"..tier,
			enabled = "false",
			ingredients = ingredients,
			result = "replicator-"..tier,
			subgroup = "replicators",
			order = "b"..tier,
		},
		
		--Create the replicator's item form
		{
			type = "item",
			name = "replicator-"..tier,
			icon = "__fire-replicators__/graphics/icons/replicator-"..tier..".png",
			icon_size = 32,
			flags = {},
			subgroup = "production-machine",
			order = "b"..tier,
			place_result = "replicator-"..tier,
			stack_size = 50
		},
		
		--Create the crafting catagory for recipes of this replicator's tier
		{
			type = "recipe-category",
			name = "replication-"..tier
		},
		
		--Create the replicator's placed machine form
		{
			--Basic stuff
			type = "assembling-machine",
			name = "replicator-"..tier,
			icon = "__fire-replicators__/graphics/icons/replicator-"..tier..".png",
			icon_size = 32,
			
			--Placement data
			flags = {"placeable-neutral", "placeable-player", "player-creation"},
			minable = {hardness = 0.2, mining_time = 0.5, result = "replicator-"..tier},
			fast_replaceable_group = "replicator",
			
			--Taking damage and dying
			max_health = 200,
			resistances = {
				{
					type = "fire",
					percent = 70
				}
			},
			dying_explosion = "big-explosion",
			corpse = "big-remnants",
			
			--Hitbox data
			collision_box = {{-hitbox_corner, -hitbox_corner}, {hitbox_corner, hitbox_corner}},
			selection_box = {{-entity_corner, -entity_corner}, {entity_corner, entity_corner}},
			
			--Pipe connections
			
			fluid_boxes =
			{
				{
					production_type = "input",
					pipe_picture = assembler2pipepictures(),
					pipe_covers = pipecoverspictures(),
					base_area = 10,
					base_level = -1,
					pipe_connections = {{type="input", position = {pipe_connector_offset + entity_corner, entity_corner + 0.5}}},
					secondary_draw_orders = { north = -1 }
				},
				{
					production_type = "output",
					pipe_picture = assembler2pipepictures(),
					pipe_covers = pipecoverspictures(),
					base_area = 10,
					base_level = 1,
					pipe_connections = {{type="output", position = {pipe_connector_offset, entity_corner + 0.5}}},
					secondary_draw_orders = {north = -1}
				},
				off_when_no_fluid_recipe = true
			},
			
			--Graphics
			animation =
			{
				filename = "__fire-replicators__/graphics/entity/replicator-"..tier..".png",
				priority="high",
				width = 113,
				height = 91,
				frame_count = 33,
				line_length = 11,
				animation_speed = 1/3,
				shift = {entity_corner * 0.4 / 3, entity_corner * 0.1},
				scale = entity_corner * 2 / 3
			},
			
			--Sounds
			open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
			close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
			working_sound = {
				sound = {
					{
					filename = "__base__/sound/lab.ogg",
					volume = 0.7
					},
				},
				idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
				apparent_volume = 1.5,
			},
			
			--What this machine actually does (which in this case is crafting, albeit with a set of recipes which do not require any ingredients)
			crafting_categories = categories,
			crafting_speed = speed_base * speed_factor^(tier-1),
			energy_source =
			{
				type = "electric",
				usage_priority = "secondary-input",
				emissions_per_minute = pollution_base * pollution_factor^(tier-1) / power_consumption
			},
			energy_usage = power_consumption .. "kW",
			ingredient_count = 1, --Haha no ingredients
			
			--Module slots
			module_specification =
			{
				module_slots = math.max(0, math.floor(module_slots_base + module_slots_addend * (tier-1)))
			},
			allowed_effects = {"consumption", "speed", "pollution"}
		}
	})
end


--Create the replicators using the above function
make_replicator(1,
	{"dark-matter-scoop"},
	{
		{"iron-plate", 4},
		{"electronic-circuit", 2},
		{"dark-matter-scoop", 4},
	}
)
make_replicator(2,
	{"dark-matter-transducer"},
	{
		{"electronic-circuit", 4},
		{"dark-matter-transducer", 2},
	}
)
make_replicator(3,
	{"advanced-electronics"},
	{
		{"advanced-circuit", 2},
		{"dark-matter-transducer", 4},
	}
)
make_replicator(4,
	{"matter-conduit"},
	{
		{"advanced-circuit", 4},
		{"matter-conduit", 2},
	}
)
make_replicator(5,
	{"advanced-electronics-2"},
	{
		{"processing-unit", 2},
		{"matter-conduit", 4},
	}
)
