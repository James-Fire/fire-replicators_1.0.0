data:extend(
{
{
	type = "tool",
	name = "tenemut",
	icon = "__fire-replicators__/graphics/icons/tenemut.png",
	icon_size = 32,
	flags = {},
	subgroup = "raw-resource",
	order = "f[tenemut]",
	stack_size = 200,
	durability = 1,
	durability_description_key = "description.science-pack-remaining-amount"
},
{
	type = "resource",
	name = "tenemut",
	icon = "__fire-replicators__/graphics/icons/tenemut.png",
	icon_size = 32,
	flags = {"placeable-neutral"},
	order = "b-rep",
	tree_removal_probability = 0.2,
	tree_removal_max_distance = 32 * 32,
	minable = {
		hardness = 0.5,
		mining_particle = "tenemut-particle",
		mining_time = 2.5,
		result = "tenemut"
	},
	collision_box = {{ -0.1, -0.1}, {0.1, 0.1}},
	selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
	autoplace = {
		order = "b-rep",
		control = "tenemut",
		sharpness = 15/16,
		richness_multiplier = 25000,
		richness_multiplier_distance_bonus = 2,
		richness_base = 10,
		coverage = 0.002 / 3,
		peaks = {
			{
				influence = 0.65,
				noise_layer = "tenemut",
				noise_octaves_difference = -0.85,
				noise_persistence = 0.4,
			}
		},
		starting_area_size = 5500 * 0.002 / 3,
		starting_area_amount = 16000
	},
	stage_counts = {2500, 2000, 1500, 1000, 500, 250, 100, 40},
	stages = {
		sheet = {
			filename = "__fire-replicators__/graphics/entity/tenemut.png",
			priority = "extra-high",
			width = 64,
			height = 64,
			frame_count = 8,
			variation_count = 8,
			hr_version = {
				filename = "__fire-replicators__/graphics/entity/hr-tenemut.png",
				priority = "extra-high",
				width = 128,
				height = 128,
				frame_count = 8,
				variation_count = 8,
				scale = 0.5
			}
		}
	},
	map_color = {r=0.550, g=0.392, b=0.550}
},
{
	type = "noise-layer",
	name = "tenemut"
},
{
	type = "autoplace-control",
	name = "tenemut",
	richness = true,
	order = "b-rep",
    category = "resource"
},
{
	type = "optimized-particle",
	name = "tenemut-particle",
	flags = {"not-on-map"},
	life_time = 180,
	pictures =
	{
		{
			filename = "__fire-replicators__/graphics/entity/tenemut-particle-1.png",
			priority = "extra-high",
			width = 5,
			height = 5,
			frame_count = 1
		},
		{
			filename = "__fire-replicators__/graphics/entity/tenemut-particle-2.png",
			priority = "extra-high",
			width = 6,
			height = 4,
			frame_count = 1
		},
		{
			filename = "__fire-replicators__/graphics/entity/tenemut-particle-3.png",
			priority = "extra-high",
			width = 7,
			height = 8,
			frame_count = 1
		},
		{
			filename = "__fire-replicators__/graphics/entity/tenemut-particle-4.png",
			priority = "extra-high",
			width = 6,
			height = 5,
			frame_count = 1
		}
	},
	shadows =
	{
		{
			filename = "__fire-replicators__/graphics/entity/tenemut-particle-shadow-1.png",
			priority = "extra-high",
			width = 5,
			height = 5,
			frame_count = 1
		},
		{
			filename = "__fire-replicators__/graphics/entity/tenemut-particle-shadow-2.png",
			priority = "extra-high",
			width = 6,
			height = 4,
			frame_count = 1
		},
		{
			filename = "__fire-replicators__/graphics/entity/tenemut-particle-shadow-3.png",
			priority = "extra-high",
			width = 7,
			height = 8,
			frame_count = 1
		},
		{
			filename = "__fire-replicators__/graphics/entity/tenemut-particle-shadow-4.png",
			priority = "extra-high",
			width = 6,
			height = 5,
			frame_count = 1
		}
	}
},
})