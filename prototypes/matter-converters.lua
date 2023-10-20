local Height = 1
local BaseArea = 2

if settings.startup["item-breakdown-recipes"].value then
	Height = 10000
	BaseArea = 2000
end

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.ceil(num * mult + 0.5) / mult
end

local function MatterConverterIngredients(tier, NumTiers)
	local DMItem = { {"assembling-machine-"..tostring(tier),1} }
	if (tier) > 1 then
		table.insert(DMItem,{"Matter-Converter-"..tostring(tier-1),1})
	end
	
	table.insert(DMItem,{ "dark-matter-scoop", tier })
	if (tier/NumTiers) > 0.25 then
		table.insert(DMItem,{ "dark-matter-transducer", round(tier/2) })
	end
	if (tier/NumTiers) > 0.5 then
		table.insert(DMItem,{ "matter-conduit", round(tier/4) })
	end
	if (tier/NumTiers) > 0.75 then
		DMItem[3][2] = tier*2
		DMItem[4][2] = tier
	end
	if tier == NumTiers then
		DMItem[5][2] = tier/2
	end
	return DMItem
end
local function addMatterConverter(tier, NumTiers)
	local Matter_converter = table.deepcopy(data.raw["furnace"]["electric-furnace"])
	Matter_converter.name = "Matter-Converter-"..tostring(tier)
	Matter_converter.energy_usage = tostring((2*tier)).."MW"
	Matter_converter.energy_source.emissions_per_minute = 0
	Matter_converter.crafting_speed = tier
	--Matter_converter.source_inventory_size = 5
	Matter_converter.minable.result = "Matter-Converter-"..tostring(tier)
	Matter_converter.fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 2,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0, -2} }},
        secondary_draw_orders = { north = -1 }
      },
      {
        production_type = "output",
        pipe_picture = assembler3pipepictures(),
        pipe_covers = pipecoverspictures(),
		height = Height,
        base_area = BaseArea,
        base_level = 1,
        pipe_connections = {{ type="output", position = {0, 2} }},
        secondary_draw_orders = { north = -1 }
      },
      off_when_no_fluid_recipe = false
    }
	Matter_converter.crafting_categories = {"Matter-Converter"}
	Matter_converter.allowed_effects = {"speed", "consumption", "pollution"}
	Matter_converter.module_specification = {
		module_slots = tier
	}
	data:extend({Matter_converter})
	data:extend({
		{
			type = "item",
			name = "Matter-Converter-"..tostring(tier),
			icon = "__base__/graphics/icons/assembling-machine-3.png",
			icon_size = 64,
			subgroup = "replicators",
			place_result = "Matter-Converter-"..tostring(tier),
			order = "q",
			stack_size = 20
		},
		{
			type = "recipe",
			name = "Matter-Converter-"..tostring(tier),
			enabled = true,
			energy_required = 3*tier,
			ingredients = MatterConverterIngredients(tier, NumTiers),
			results = {{"Matter-Converter-"..tostring(tier),1}},
		},
	})
	
	--log("Matter Converter "..tier..": "..serpent.block(Matter_converter))
	--log("Matter Converter "..tier.." Recipe: "..serpent.block(data.raw.recipe["Matter-Converter-"..tostring(tier)]))
	--log("Matter Converter "..tier.." Item: "..serpent.block(data.raw.item["Matter-Converter-"..tostring(tier)]))
end

--Create matter converters, and replicators
if settings.startup["replication-steps-logging"].value then
	log("Starting Matter Converters and Replicators")
end
local AssemMach = { }
for i, Item in pairs(data.raw.item) do
	if Item.name:find("assembling", 1, true) and Item.name:find("machine", 1, true) then
		table.insert(AssemMach, Item.name)
	end
end

for i, Item in pairs(AssemMach) do
	addMatterConverter(i, table_size(AssemMach) )
end