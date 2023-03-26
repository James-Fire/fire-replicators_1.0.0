local resource_autoplace = require("resource-autoplace")

data:extend(
{  
  {
    type = "fluid",
    name = "eridium",
    default_temperature = 18,
    heat_capacity = "0.1KJ",
    base_color = {r=0.5, g=0, b=0.5},
    flow_color = {r=0.5, g=0, b=0.5},
    max_temperature = 100,
    icon = "__fire-replicators__/graphics/icons/eridium.png",
    icon_size = 32,
    order = "a[fluid]-b[crude-oil]"
  },
  --[[{
    type = "resource",
    name = "eridium",
    icon = "__fire-replicators__/graphics/icons/eridium.png",
    icon_size = 32,
    flags = {"placeable-neutral"},
    category = "basic-fluid",
    order="a-b-a",
    infinite = true,
    highlight = true,
    minimum = 60000,
    normal = 300000,
    infinite_depletion_amount = 10,
    resource_patch_search_radius = 12,
    tree_removal_probability = 0.7,
    tree_removal_max_distance = 32 * 32,
    minable =
    {
      mining_time = 0.5,
      results =
      {
        {
          type = "fluid",
          name = "eridium",
          amount_min = 50,
          amount_max = 100,
          probability = 1
        }
      }
    },
    collision_box = {{ -1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
    -- autoplace = oil_old_autoplace,
    autoplace = resource_autoplace.resource_autoplace_settings{
      name = "eridium",
      order = "c", -- Other resources are "b"; oil won't get placed if something else is already there.
      base_density = 8.2,
      base_spots_per_km2 = 5.8,
      random_probability = 1/48,
      random_spot_size_minimum = 1,
      random_spot_size_maximum = 1, -- don't randomize spot size
      additional_richness = 220000, -- this increases the total everywhere, so base_density needs to be decreased to compensate
      has_starting_area_placement = true,
      regular_rq_factor_multiplier = 1
    },
    stage_counts = {0},
    stages =
    {
      sheet =
      {
        filename = "__fire-replicators__/graphics/entity/eridium.png",
        priority = "extra-high",
        width = 75,
        height = 61,
        frame_count = 4,
        variation_count = 1
      }
    },
    map_color = {r=0.5, g=0, b=0.5},
    map_grid = false
  },
  {
    type = "autoplace-control",
    name = "eridium",
    richness = true,
    order = "b-f",
    category = "resource"
  },]]
})