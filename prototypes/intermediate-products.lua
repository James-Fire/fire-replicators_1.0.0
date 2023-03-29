data:extend({
  {
    type = 'technology',
    name='dark-matter-scoop',
    icon = '__fire-replicators__/graphics/icons/dark-matter-scoop.png',
	icon_size = 32,
    effects = {{type = 'unlock-recipe', recipe='replication-lab'}},
    prerequisites = {},
	unit = {
		count = 200,
		ingredients = {
			{"automation-science-pack", 1},
		},
		time = 15,
	},
    order='a-f-a',
  },
  {
      type = "recipe",
      name = "dark-matter-scoop",
      enabled = "true",
      energy_required = 2,
      ingredients = {
        {'tenemut', 4},
        {'iron-plate', 1}
      },
      result = "dark-matter-scoop"
  },
  {
    type = "tool",
    name = "dark-matter-scoop",
	allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    icon = "__fire-replicators__/graphics/icons/dark-matter-scoop.png",
	icon_size = 32,
    flags = {},
    subgroup = "replication-resources",
    order = "a[matter-conduit]-a",
    stack_size = 200,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount"
  },
  {
    type = 'technology',
    name='dark-matter-transducer',
    icon = '__fire-replicators__/graphics/icons/dark-matter-transducer.png',
	icon_size = 32,
    effects = {{type = 'unlock-recipe', recipe='dark-matter-transducer'}},
    prerequisites = {"dark-matter-scoop", "steel-processing"},
	unit = {
		count = 200,
		ingredients = {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
		},
		time = 20,
	},
    order='a-f-a',
  },
  {
      type = "recipe",
      name = "dark-matter-transducer",
      enabled = "false",
      energy_required = 4,
      ingredients = {
        {'dark-matter-scoop', 4},
        {'steel-plate', 1}
      },
      result = "dark-matter-transducer"
  },
  {
    type = "tool",
    name = "dark-matter-transducer",
	allowed_effects = {"consumption", "speed", "productivity", "pollution"},
    icon = "__fire-replicators__/graphics/icons/dark-matter-transducer.png",
	icon_size = 32,
    flags = {},
    subgroup = "replication-resources",
    order = "a[matter-conduit]-b",
    stack_size = 200,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount"
  },
  {
    type = 'technology',
    name='matter-conduit',
    icon = '__fire-replicators__/graphics/icons/matter-conduit.png',
	icon_size = 32,
    effects = {{type = 'unlock-recipe', recipe='matter-conduit'}},
    prerequisites = {"dark-matter-transducer"},
	unit = {
		count = 200,
		ingredients = {
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
		},
		time = 25,
	},
    order='a-f-a',
  },
  {
      type = "recipe",
      name = "matter-conduit",
      enabled = "false",
      energy_required = 8,
      ingredients = {
        {'dark-matter-transducer', 4},
        {'dark-matter-scoop', 1}
      },
      result = "matter-conduit"
  },
  {
    type = "tool",
    name = "matter-conduit",
    icon = "__fire-replicators__/graphics/icons/matter-conduit.png",
	icon_size = 32,
    flags = {},
    subgroup = "replication-resources",
    order = "a[matter-conduit]-c",
    stack_size = 200,
    durability = 1,
    durability_description_key = "description.science-pack-remaining-amount"
  },
})