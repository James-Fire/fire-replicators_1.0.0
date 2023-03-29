data:extend({
	{ --Recipe
		type = "recipe",
		name = "replication-lab",
		enabled = "false",
		ingredients = {
			{"dark-matter-scoop", 5},
			{"electronic-circuit", 10},
			{"copper-plate", 10}
		},
		result = "replication-lab",
		subgroup = "replicators",
		order = "a"
	},
	
	{ --Item
		type = "item",
		name = "replication-lab",
		icon = "__fire-replicators__/graphics/icons/replication-lab.png",
		icon_size = 64,
		flags = {},
		subgroup = "replicators",
		order = "a",
		place_result = "replication-lab",
		stack_size = 50
	}, { --Entity
		type = "lab",
		name = "replication-lab",
		icon = "__fire-replicators__/graphics/icons/replication-lab.png",
		icon_size = 64,
		flags = {"placeable-player", "player-creation"},
		minable = {mining_time = 1, result = "replication-lab"},
		max_health = 150,
		corpse = "big-remnants",
		dying_explosion = "big-explosion",
		collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		light = {intensity = 0.75, size = 8},
		on_animation = {
			filename = "__fire-replicators__/graphics/entity/replication-lab.png",
			width = 224,
			height = 224,
			frame_count = 32,
			line_length = 8,
			animation_speed = 1/4,
			shift = {0.2, 0.15},
			scale = 0.5
		},
		off_animation = {
			filename = "__fire-replicators__/graphics/entity/replication-lab-off.png",
			width = 224,
			height = 224,
			frame_count = 1,
			shift = {0.2, 0.15},
			scale = 0.5
		},
		working_sound = {
			sound = {
				filename = "__base__/sound/lab.ogg",
				volume = 0.7
			},
			apparent_volume = 1.5
		},
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage = "60kW",
		inputs = {
			"tenemut",
			"dark-matter-scoop",
			"dark-matter-transducer",
			"matter-conduit"
		},
		module_specification = {module_slots = 2},
		allowed_effects = {"consumption", "speed", "productivity", "pollution"}
	}
})