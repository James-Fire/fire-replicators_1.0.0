local stdlib = require('__stdlib__/stdlib/utils/string')

local BaseMatterCost = 5 --How much matter is used to make 1 piece of ore  --settings.startup["tiberium-damage"].value
local AddedMatterCostDivisor = 1.5 --How much to divide ingredient values by. It's easier to make the final product directly?
local BaseTimeCost = 2 --How much time is used to make 1 piece of ore, also the tech research time.  --settings.startup["tiberium-damage"].value
local TierTimeFactor = 2 --How much the research time is increased per tier
local ItemTimeFactor = 1.2 --How much the time is increased per unique ore used to make the product normally, unused right now
local MaxTier = 5 --The max tier that we can generate. Anything above this is rounded down to this.
local TierDivisor = 1 --How many tiers of items are in each tier band
local TierBands = { 1, 2, 3, 4, 5 }

local RepliOres = { }
local RepliItems = { }
local ProcessedRepliItems = { }
local RepliTableTable = { }
local BadItemList = { "loader", "fast-loader", "express-loader", "rocket-part", "infinity-chest", "electric-energy-interface", "infinity-pipe" }
local BadRecipePreList = { "loader", "fast-loader", "express-loader", "rocket-part", "infinity-chest", "electric-energy-interface", "infinity-pipe" }
local BadRecipeList = { }
local BadRecipeNameList = { }
local BadRecipeCategories = { "forcefield-crafter" }

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.ceil(num * mult + 0.5) / mult
end

local function CheckTableValue(Value,Table,SubTableIndex)
	for i, v in pairs(Table) do
		if type(v) == "table" then
			if Value == v[SubTableIndex] then
				return true
			end
		else
			if Value == v then
				return true
			end
		end
	end
	return false
end
local function NotBannedRecipe(Recipe)
	if CheckTableValue(Recipe,BadRecipeList) == true then
		return false
	end
	if CheckTableValue(Recipe.category,BadRecipeCategories) == true then
		return false
	end
	if CheckTableValue(Recipe.name,BadRecipeNameList) == true then
		return false
	end
	return true
end
local function CheckRecipeResultTableValue(Item)
	if Item == "item-unknown" then
	else
		if data.raw.recipe[Item] then
			return true
		else
			--log("Checking for recipe for "..Item)
			for i, recipe in pairs(data.raw.recipe) do
				--log("Check if recipe "..recipe.name.." is banned")
				if NotBannedRecipe(recipe) == true then
					--log("Recipe "..recipe.name.." isn't banned")
					if recipe.results then
						--log("Recipe "..recipe.name.." has a result table")
						for j, result in pairs(recipe.results) do
							if Item == result.name then
								--log("Found result table production recipe for "..Item)
								return true
							end
						end
					elseif recipe.result then
						--log("Recipe "..recipe.name.." has a single result")
						if Item == recipe.result.name then
							--log("Found single-result production recipe for "..Item)
							return true
						end
					end
				end
			end
		end
	end
	return false
end
--Insert bad recipes
for i, recipe in pairs(BadRecipePreList) do
	table.insert(BadRecipeList, data.raw.recipe[recipe])
	table.insert(BadRecipeNameList, recipe)
end

local function FluidBarrelMatch(Fluid)
	for j, Item in pairs(data.raw.item) do
		if stdlib.contains(Item.name, "barrel") then
			--log("Checking for barrels with "..Fluid.." in "..Item.name)
			if stdlib.contains(Fluid, "-") then
				if stdlib.contains(Item.name, stdlib.split(Fluid, "-")[1]) and stdlib.contains(Item.name, stdlib.split(Fluid, "-")[2]) then
					--log("Found Bad Item "..Item.name)
					return Item.name
				end
			else
				if stdlib.contains(Item.name, Fluid) then
					--log("Found Bad Item "..Item.name)
					return Item.name
				end
			end
		end
	end
end

--Use string matching to grab full barrels
for i, Fluid in pairs(data.raw.fluid) do
	--log("Checking for barrels with "..Fluid.name)
	local FluidBarrel = FluidBarrelMatch(Fluid.name)
	table.insert(BadItemList, FluidBarrel)
end

local function RecipeStringMatch(RecipeName)
	--log("String Match Recipe "..RecipeName)
	if stdlib.contains(RecipeName, "barrel") or stdlib.contains(RecipeName, "canister") then
		if stdlib.contains(RecipeName, "fill") or stdlib.contains(RecipeName, "empty") then
			if RecipeName == "empty-barrel" then
			else
				if CheckTableValue(RecipeName,BadRecipeNameList) == false then
					return true
				end
			end
		end
	end
	if RecipeName:find("reforming", 1, true) or RecipeName:find("cracking", 1, true) then
		--log("Found cracking recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	end
	if RecipeName:find("liquefaction", 1, true) or RecipeName:find("request", 1, true) then
		--log("Found liquefaction recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	end
	if RecipeName:find("scrap", 1, true) then
		--log("Found scrap recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	end
	if RecipeName:find("coolant", 1, true) and RecipeName:find("hot", 1, true) or RecipeName:find("cold", 1, true) then
		--log("Found scrap recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	end
	return false
end
local function ItemStringMatch(ItemName)
	if ItemName:find("scrap", 1, true) or ItemName:find("person", 1, true) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	end
	if ItemName:find("joule", 1, true) or ItemName:find("interface", 1, true) or ItemName:find("infinity", 1, true) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	end
	if ItemName:find("recycle", 1, true) or ItemName:find("recycling", 1, true) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	end
	if ItemName:find("coolant", 1, true) and ItemName:find("hot", 1, true) or ItemName:find("cold", 1, true) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	end
	return false
end

for i, Item in pairs(data.raw.item) do
	if ItemStringMatch(Item.name) then
		table.insert(BadItemList, Item.name)
	end
end
for i, Fluid in pairs(data.raw.fluid) do
	if ItemStringMatch(Fluid.name) then
		table.insert(BadItemList, Fluid.name)
	end
end
for i, Recipe in pairs(data.raw.recipe) do
	local PotentialBadIngredients = { }
	local PotentialBadResults = { }
	local recipe_data = Recipe
	
	if RecipeStringMatch(Recipe.name) then
		table.insert(BadRecipeList, Recipe)
		table.insert(BadRecipeNameList, Recipe.name)
	end
	
	--Use string matching to grab likely recipe categories
	if Recipe.category then
		if Recipe.category:find("deep", 1, true) and Recipe.category:find("mining", 1, true) or Recipe.category:find("mine", 1, true) then
			if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
				table.insert(BadRecipeCategories, Recipe.category)
			end
		end
		if Recipe.category:find("recycle", 1, true) or Recipe.category:find("recycling", 1, true) then
			if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
				table.insert(BadRecipeCategories, Recipe.category)
			end
		end
		if Recipe.category:find("person", 1, true) then
			if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
				table.insert(BadRecipeCategories, Recipe.category)
			end
		end
	end
	if Recipe.normal then
		recipe_data = Recipe.normal
	else
		recipe_data = Recipe
	end
	if recipe_data.ingredients then
		for i, ingredient in pairs(recipe_data.ingredients) do
			local ingredientindex = nil
			if ingredient.name then
				ingredientindex = ingredient.name
			else
				ingredientindex = ingredient[1]
			end
			if "barrel" == ingredientindex then
				table.insert(PotentialBadIngredients, recipe_data)
			end
		end
	end
	if Recipe.category then
		if CheckTableValue(Recipe.category,BadRecipeCategories) == true then
			if CheckTableValue(Recipe,BadRecipeList) == false then
				table.insert(BadRecipeList, Recipe)
				table.insert(BadRecipeNameList, Recipe.name)
			end
		end
	end
	if recipe_data.results then
		--CheckTableValue("barrel",recipe_data.ingredients)
		--table.insert(PotentialBadResults, Recipe)
		
	end
	if recipe_data.result then
		--CheckTableValue("barrel",recipe_data.ingredients)
		--table.insert(PotentialBadResults, Recipe)
		
	end
	for i, Bads in pairs(PotentialBadIngredients) do 
		if CheckTableValue(Bads,PotentialBadResults) == true then
			table.insert(BadRecipeList, Bads)
			table.insert(BadRecipeNameList, Bads.name)
		end
	end
end

--log("Bad Recipe Table: "..serpent.block(BadRecipeList))
--log("Bad Recipe Name Table: "..serpent.block(BadRecipeNameList))
--log("Bad Category Table: "..serpent.block(BadRecipeCategories))
--log("Bad Item Table: "..serpent.block(BadItemList))

--[[for name, proto in pairs(data.raw.recipe) do
	if proto.results then
		for result in pairs(proto.results) do
			if CheckTableValue(result.name,RepliItems) == false then
				return true
			end
		end
	elseif recipe_data.result then
		if CheckTableValue(result.name,RepliItems) == false then
			return true
		end
	end
end]]

local function FindItemRecipe(Item)
	local RecipeTable = { }
	if data.raw.recipe[Item] then
		if NotBannedRecipe(data.raw.recipe[Item]) == true then
			if CheckTableValue(data.raw.recipe[Item],RecipeTable) == false then
				table.insert(RecipeTable,data.raw.recipe[Item])
			end
		end
	end
	for i, recipe in pairs(data.raw.recipe) do
		if NotBannedRecipe(recipe) == true then
			if CheckTableValue(recipe,RecipeTable) == false then
				if recipe.main_product == Item then
						table.insert(RecipeTable,recipe)
				elseif recipe.main_product == nil then
					if recipe.results then
						for i, result_data in pairs(recipe.results) do
							if (result_data.name or result_data[1]) == Item then
								table.insert(RecipeTable,recipe)
							end
						end
					elseif recipe.result then
						if recipe.result == Item then
							table.insert(RecipeTable,recipe)
						end
					end
				end
			end
		end
	end
	for i, r1 in pairs(RecipeTable) do
		for j, r2 in pairs(RecipeTable) do
			if i == j then
			else
				if r1 == r2 then
					RecipeTable[j] = nil
				end
			end
		end
	end
	return RecipeTable
end

local function CheckMasterTable(Item, ReturnValue) --1 returns the item string, 2 returns the tier integer, 3 returns the value integer, 4 returns the prereq table, 5 returns the unlock tech
	for i, entry in pairs(RepliTableTable) do
		if Item == entry[1] then
			return entry[ReturnValue]
		end
	end
end

local function addMatterRecipe(ore)
	local recipeName = ore.."-to-liquid-matter"
	local oreAmount = 1
	local itemOrFluid = data.raw.fluid[ore] and "fluid" or "item"
	local energy = 2.5
	local order = 1
	
	if ore:find("water", 1, true) then
		oreAmount = 5
		energy = 5
	end
	if ore:find("eridium", 1, true) then
		recipeName = "regenerative-matter"
		oreAmount = 4
		energy = 2
	end
	
	LSlib.recipe.create(recipeName)
	if ore == "fluid" then
		LSlib.recipe.addIngredient(recipeName, ore, 25, itemOrFluid)
	else
		LSlib.recipe.addIngredient(recipeName, ore, oreAmount, itemOrFluid)
	end
	LSlib.recipe.addResult(recipeName, "eridium", BaseMatterCost, "fluid")
	LSlib.recipe.setMainResult(recipeName, "eridium")
	LSlib.recipe.setEnergyRequired(recipeName, energy)
	LSlib.recipe.setOrderstring(recipeName, order)
	LSlib.recipe.enable(recipeName)
	LSlib.recipe.setSubgroup(recipeName, "replication-resources")
	LSlib.recipe.setShowMadeIn(recipeName, true)
	data.raw.recipe[recipeName].category = "Matter-Converter"
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
        base_area = 2,
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

--Basically just determine how many steps from ore the item is by following its ingredients. Look for the shortest appearance of ore.
--Make sure to save it somewhere so we aren't repeating this, cause this is expensive.
local function GetRecipeIngredientBreakdown(Item, PrevRecipeTable)
	local Recipe = FindItemRecipe(Item)[1]
	if Recipe then --Check if the recipe exists, cause it might not for whatever reason
		--log("Master Table before "..Recipe.name.." breakdown "..serpent.block(RepliTableTable))
		local ItemTier = 0 --Item tier determines some multiplicative stuff.
		local IngredientsValue = 0 --How much liquid Matter you need to replicate the item
		local UniqueIngredients = { 0 } --How many unique resources make up the item, unused right now.
		local FoundOre = false
		local recipe_data = Recipe
		if Recipe.normal then
			recipe_data = Recipe.normal
		else
			recipe_data = Recipe
		end
		--log(Recipe.name.." started")
		--log("Previous Recipes:"..serpent.block(PrevRecipeTable))
		if recipe_data.ingredients then
			table.insert(PrevRecipeTable,Recipe.name)
			--log("ingredients for "..Recipe.name.." "..serpent.block(recipe_data.ingredients))
			local resultcount = 1
			local ingreditentstable = { }
			if recipe_data.results then
				for i, result in pairs(recipe_data.results) do
					if result.count then
						resultcount = resultcount + result.count
					elseif result.amount then
						resultcount = resultcount + result.amount
					end
				end
			elseif recipe_data.result then
				if recipe_data.result.count then
					resultcount = recipe_data.result.count
				end
			end
			for i, ingredient in pairs(recipe_data.ingredients) do
				local ingredientindex = nil
				local ingredientcount = nil
				if ingredient.name then
					ingredientindex = ingredient.name
				else
					ingredientindex = ingredient[1]
				end
				if ingredient.count then
					ingredientcount = ingredient.count
				elseif ingredient.amount then
					ingredientcount = ingredient.amount
				else
					ingredientcount = ingredient[2]
				end
				if ingredient.probability then
					--ingredientcount = ingredientcount*ingredient/probability
				end
				table.insert(ingreditentstable,ingredientindex)
				--log(ingredientindex.." for "..Recipe.name)
				if CheckMasterTable(ingredientindex, 1) then
					--log(ingredientindex.." present on masterlist")
					ItemTier = ItemTier + CheckMasterTable(ingredientindex, 2)
					IngredientsValue = IngredientsValue + ingredientcount/AddedMatterCostDivisor*CheckMasterTable(ingredientindex, 3)
				elseif CheckTableValue(ingredientindex,RepliOres) == true then
					--log(ingredientindex.." not present on masterlist, and is ore")
					FoundOre = true
					ItemTier = CheckMasterTable(ingredientindex, 2) + 1
					IngredientsValue = IngredientsValue + ingredientcount/AddedMatterCostDivisor
				else
					--log(ingredientindex.." not present on masterlist, and isn't ore")
					local IngredRecipe = FindItemRecipe(ingredientindex)
					local IngredRecipeName = { }
					for j, ingredientrecipe in pairs(IngredRecipe) do
						table.insert(IngredRecipeName,ingredientrecipe.name)
					end
					--log("All recipes that make "..ingredientindex..serpent.block(IngredRecipeName))
					local FoundRecipe = false
					for j, ingredientrecipe in pairs(IngredRecipe) do
						if ingredientrecipe and FoundRecipe == false then
							--log(ingredientrecipe.name.." ingredient for "..Item)
							if CheckTableValue(ingredientrecipe.name,PrevRecipeTable) == false then
								local ReplicationValues = GetRecipeIngredientBreakdown(ingredientindex, PrevRecipeTable)
								if FoundOre == false and i == 1 then
									ItemTier = ItemTier + ReplicationValues[2]
								end
								IngredientsValue = IngredientsValue + ReplicationValues[3]/AddedMatterCostDivisor
								FoundRecipe = true
							else
								--log("Recipe Loop, aborting")
							end
						else
						end
					end
					if FoundRecipe == false then
						--log(ingredientindex.." has no recipe to make it")
						IngredientsValue = IngredientsValue*2 --For now
					end
				end
			end
			--log("Recipe ingredients name table for "..Recipe.name.." "..serpent.block(ingreditentstable))
			--log(Recipe.name.." completed")
			--log(Item.." matter cost: "..(IngredientsValue/resultcount))
			if CheckTableValue( Item,RepliTableTable,1 ) == false then
				table.insert(RepliTableTable,{ Item, ItemTier+1, IngredientsValue/resultcount, ingreditentstable })
			end
			return { Item, ItemTier+1, IngredientsValue }
		end
	end
	--[[else
		log("GetRecipeIngredientBreakdown was passed "..Item.." that isn't in RepliItems")
	end]]
end

local function LogAllItemValues()
	for _, entry in pairs(RepliTableTable) do
		log("Master Table: "..serpent.line(entry))
	end
end

local function GetReplicationTier(Item)
	local ReplicationTier = CheckMasterTable(Item, 2)
	if ReplicationTier <= TierBands[1] then
		ReplicationTier = 1
	elseif ReplicationTier <= TierBands[2] then
		ReplicationTier = 2
	elseif ReplicationTier <= TierBands[3] then
		ReplicationTier = 3
	elseif ReplicationTier <= TierBands[4] then
		ReplicationTier = 4
	else
		ReplicationTier = 5
	end
	return ReplicationTier
end

local function GetItemBorder(Item)
	return "repl-"..GetReplicationTier(Item)
end

local function GetTechBorder(Item)
	return "tech-repl-"..GetReplicationTier(Item)
end

local function GetBorderSizeScale(IconSize)
	if IconSize == 64 then
		return 2
	end
	if IconSize == 32 then
		return 1
	end
	if IconSize == 16 then
		return 1/2
	end
	if IconSize == 1 then
		return 1/32
	end
end

local function GenerateRepliRecipeAndTech(Item)
	--log("Generate recipe and tech for "..Item.name)
	if CheckMasterTable(Item.name, 1) == Item.name then
		table.insert(ProcessedRepliItems, Item) --Place the item in the "finished" table, so it's easier to keep track of what's been processed.
		local ItemType = nil
		local ItemIcon = "__core__/graphics/empty.png"
		local ItemIconSize = 1
		local ItemMipMaps = 1
		if Item.type == "fluid" then
			ItemType = "fluid"
		else
			ItemType = "item"
		end
		if Item.icon then
			ItemIcon = Item.icon
		elseif Item.sprite then
			if Item.sprite.hr_version.filename then
				ItemIcon = Item.sprite.hr_version.filename
			elseif Item.sprite.filename then
				ItemIcon = Item.sprite.filename
			end
		end
		if Item.icon_size then
			ItemIconSize = Item.icon_size
		elseif Item.sprite then
			if Item.sprite.hr_version.width then
				ItemIconSize = Item.sprite.hr_version.width
			else
				ItemIconSize = Item.sprite.width
			end
		end
		if ItemIcon == "__core__/graphics/empty.png" then
			ItemIconSize = 1
		end
		--log("Replication Value for "..Item.name..": "..tostring(CheckMasterTable(Item.name, 3)))
		--log("Tech cost for "..Item.name..": "..tostring(round(CheckMasterTable(Item.name, 3)/4)))
		--log("Icon String for "..Item.name..": "..ItemIcon)
		data:extend({
			{
				type = "recipe",
				name = Item.name.."-replication",
				icons = {
					{
						icon = ItemIcon,
						icon_size = ItemIconSize,
					},
					{
						icon = "__fire-replicators__/graphics/icons/borders/"..GetItemBorder(Item.name)..".png",
						icon_size = 32,
						scale = GetBorderSizeScale(ItemIconSize),
						shift = {0, 0},
					},
				},
				category = "replication-"..tostring(GetReplicationTier(Item.name)),
				enabled = false,
				energy_required = BaseTimeCost*TierTimeFactor^CheckMasterTable(Item.name, 2),
				ingredients = {
					{type = "fluid", name = "eridium", amount = round(BaseMatterCost*CheckMasterTable(Item.name, 3)) },
				},
				results = {
					{ name = Item.name, amount = 1, type = ItemType },
				},
				subgroup = "replication-"..tostring(GetReplicationTier(Item.name)),
				order = "a",
			},
			{
				type = "technology",
				name = Item.name.."-replication-research",
				icons = {
					{
						icon = ItemIcon,
						icon_size = ItemIconSize,
					},
					{
						icon = "__fire-replicators__/graphics/icons/borders/"..GetTechBorder(Item.name)..".png",
						icon_size = 128,
						scale = ItemIconSize/128,
						shift = {0, 0},
					},
				},
				
				effects = {
					{
						type = "unlock-recipe",
						recipe = Item.name.."-replication"
					},
				},
				unit = {
					count = GetReplicationTier(Item.name)*10,
					ingredients = {
						{"tenemut", 4},
					},
					time = round(BaseTimeCost*TierTimeFactor^GetReplicationTier(Item.name))*GetReplicationTier(Item.name),
				},
				order = "a",
			},
		})
		LSlib.technology.addPrerequisite(Item.name.."-replication-research", "replication-1")
		if CheckMasterTable(Item.name, 2) > TierBands[1] then
			LSlib.technology.addIngredient(Item.name.."-replication-research", 3, "dark-matter-scoop")
			LSlib.technology.movePrerequisite(Item.name.."-replication-research", "replication-1", "replication-2")
		end
		if CheckMasterTable(Item.name, 2) > TierBands[2] then
			LSlib.technology.addIngredient(Item.name.."-replication-research", 2, "dark-matter-transducer")
			LSlib.technology.movePrerequisite(Item.name.."-replication-research", "replication-2", "replication-3")
		end
		if CheckMasterTable(Item.name, 2) > TierBands[3] then
			LSlib.technology.removeIngredient(Item.name.."-replication-research", "tenemut")
			LSlib.technology.addIngredient(Item.name.."-replication-research", 1, "matter-conduit")
			LSlib.technology.movePrerequisite(Item.name.."-replication-research", "replication-3", "replication-4")
		end
		if CheckMasterTable(Item.name, 2) > TierBands[4] then
			LSlib.technology.addIngredient(Item.name.."-replication-research", 2, "dark-matter-scoop")
			LSlib.technology.addIngredient(Item.name.."-replication-research", 2, "dark-matter-transducer")
			LSlib.technology.addIngredient(Item.name.."-replication-research", 2, "matter-conduit")
			LSlib.technology.movePrerequisite(Item.name.."-replication-research", "replication-4", "replication-5")
		end
		--log("Recipe: "..serpent.block(Item.name.."-replication").."  Tech: "..serpent.block(Item.name.."-replication-research"))
		--log("Generate recipe and tech completed for "..Item.name)
	end
end

--Apply prereqs so things like Steel replication need iron replication
local function ApplyRecipePrereqs(Item)
	local prereqtable = { }
	prereqtable = CheckMasterTable(Item, 4)
	if prereqtable then
		for i, prereq in pairs(prereqtable) do
			if data.raw.technology[prereq.."-replication-research"] then
				LSlib.technology.addPrerequisite(Item.."-replication-research", prereq.."-replication-research")
			end
		end
	end
end

--Start by documenting all items, fluids, modules, and tools, and ensuring there's a recipe that makes it. Or if it's a resource.
local Items = { "item", "fluid", "module", "tool", "ammo", "capsule", "armor", "gun", "rail-planner" }
for i, ItemType in pairs(Items) do
	for j, Item in pairs(data.raw[ItemType]) do
		if CheckRecipeResultTableValue(Item.name) == true and CheckTableValue(Item.name, BadItemList) == false then
			table.insert(RepliItems,Item.name)
		end
	end
end

for _, resourceData in pairs(data.raw.resource) do
	--Exclude infinite mining stuff. RecipeName:"liquefaction")
	if resourceData.category and (resourceData.category:find("deep", 1, true) or resourceData.category:find("core", 1, true)) and (resourceData.category:find("mining", 1, true) or resourceData.category:find("mine", 1, true)) then

	elseif resourceData.autoplace and resourceData.minable then
		table.insert(RepliOres,resourceData.minable.result)
		if resourceData.minable.results then
			for _, result in pairs(resourceData.minable.results) do 
				table.insert(RepliOres,result.name)
			end
		end
	end
end
--Insert wood manually, if it's not already there
if CheckTableValue("wood",RepliOres) == false then
	table.insert(RepliOres, "wood")
	if CheckTableValue("wood",RepliItems) == true then
		for _, result in pairs(RepliItems) do
			if result == "wood" then
				table.remove(RepliItems,_)
			end
		end
	end
end
--Insert water manually, if it's not already there
if CheckTableValue("water",RepliOres) == false then
	table.insert(RepliOres, "water")
	if CheckTableValue("water",RepliItems) == true then
		for _, result in pairs(RepliItems) do
			if result == "water" then
				table.remove(RepliItems,_)
			end
		end
	end
end
--Make sure no ores are in the item table
for i, Item in pairs(RepliItems) do
	if CheckTableValue(Item,RepliOres) == true then
		RepliItems[i] = nil
	end
end
log("Items Table: "..serpent.block(RepliItems))
log("Ores Table: "..serpent.block(RepliOres))

--Create matter converters, and replicators
local AssemMach = { }
for i, Item in pairs(data.raw.item) do
	if Item.name:find("assembling", 1, true) and Item.name:find("machine", 1, true) then
		table.insert(AssemMach, Item.name)
	end
end

for i, Item in pairs(AssemMach) do
	addMatterConverter(i, table_size(AssemMach) )
end
--log("Matter Converters Completed")

--Start recipe generation with ores
for i, Item in pairs(RepliOres) do
	table.insert(RepliTableTable,{ Item, 0, 1 })
end
for i, Item in pairs(RepliOres) do
	addMatterRecipe(Item)
end
addMatterRecipe("eridium")
--log("Matter Conversion Recipes Completed")
--Calculate item values
for i, Item in pairs(RepliItems) do
	local PrevRecipeTable = { }
	GetRecipeIngredientBreakdown(Item, PrevRecipeTable)
end
--log("Item cost breakdown completed")

--After calculating stuff, extract all the tier values
local function Mean(Table)
	local MeanValue = 0
	for i, entry in pairs(Table) do
		MeanValue = MeanValue + entry
	end
	MeanValue = MeanValue/table_size(Table)
	return MeanValue
end
local function Median(Table)
	local MedianIndex = round(table_size(Table)/2)
	return Table[MedianIndex]
end

local HighestTier = { 0 }
local CalculatedTier = MaxTier
local TierCount = { 0, 0, 0, 0, 0 } --Count how many recipes we find for each tier band
local TierTable = { } --Count how many recipes we find for each tier band
log("Tier calculation variables declared")
for i, entry in pairs(RepliTableTable) do
	table.insert(TierTable, entry[2])
	if entry[2] > HighestTier[1] then
		table.insert(HighestTier, 1, entry[2])
	--[[elseif CheckTableValue(entry[2],HighestTier) == false then
		for j, TierEntry in pairs(HighestTier) do
			if entry[2] > TierEntry then
				table.insert(HighestTier, j+1, entry[2])
				break
			end
		end]]
	end
end
log("Item tiers extracted and sorted")
--log("Highest Tiers:")
--for _, entry in pairs(HighestTier) do
--	log(serpent.line(entry))
--end
--log("Highest Tiers Mean:"..serpent.line(Mean(HighestTier)))
--log("Highest Tiers Median:"..serpent.line(Median(HighestTier)))
--log("All recipe tier Mean:"..serpent.line(Mean(TierTable)))
--log("All recipe tier Median:"..serpent.line(Median(TierTable)))

--Prune the highest tier if it's too high
for i, Tier in pairs(HighestTier) do
	if Tier > (2*Median(TierTable)) then
		log("Tier "..Tier.." is more than 2x higher than "..tostring(Median(HighestTier))..", tossing")
	else
		log("Tier "..Tier.." is not too high, continuing")
		CalculatedTier = Tier
		break
	end
end

--Calculate stuff so that the top tier bands aren't extremely sparsely populated
TierDivisor = round(CalculatedTier/MaxTier)
TierBands[1] = TierDivisor
TierBands[2] = TierDivisor*2
TierBands[3] = TierDivisor*3
TierBands[4] = TierDivisor*4
TierBands[5] = TierDivisor*5

for i, entry in pairs(TierTable) do
	if entry <= TierBands[1] then
		TierCount[1] = TierCount[1] + 1
	elseif entry <= TierBands[2] then
		TierCount[2] = TierCount[2] + 1
	elseif entry <= TierBands[3] then
		TierCount[3] = TierCount[3] + 1
	elseif entry <= TierBands[4] then
		TierCount[4] = TierCount[4] + 1
	else
		TierCount[5] = TierCount[5] + 1
	end
end

log("Tier Band Width: "..tostring(TierDivisor))
log("Highest non-outlier Tier: "..tostring(CalculatedTier))
log("Calculated tier bands: "..serpent.block(TierBands))
log("Tier band recipe count: "..serpent.block(TierCount))


--Recipe and tech generation with ores
for i, Item in pairs(RepliOres) do
	if data.raw.item[Item] then
		GenerateRepliRecipeAndTech(data.raw.item[Item])
	elseif data.raw.fluid[Item] then
		GenerateRepliRecipeAndTech(data.raw.fluid[Item])
	elseif data.raw.module[Item] then
		GenerateRepliRecipeAndTech(data.raw.module[Item])
	elseif data.raw.tool[Item] then
		GenerateRepliRecipeAndTech(data.raw.tool[Item])
	elseif data.raw.ammo[Item] then
		GenerateRepliRecipeAndTech(data.raw.ammo[Item])
	elseif data.raw.capsule[Item] then
		GenerateRepliRecipeAndTech(data.raw.capsule[Item])
	elseif data.raw.gun[Item] then
		GenerateRepliRecipeAndTech(data.raw.gun[Item])
	elseif data.raw.armor[Item] then
		GenerateRepliRecipeAndTech(data.raw.armor[Item])
	elseif data.raw["rail-planner"][Item] then
		GenerateRepliRecipeAndTech(data.raw["rail-planner"][Item])
	end
end
--Recipe and tech generation with everything else
for i, Item in pairs(RepliItems) do
	if data.raw.item[Item] then
		GenerateRepliRecipeAndTech(data.raw.item[Item])
	elseif data.raw.fluid[Item] then
		GenerateRepliRecipeAndTech(data.raw.fluid[Item])
	elseif data.raw.module[Item] then
		GenerateRepliRecipeAndTech(data.raw.module[Item])
	elseif data.raw.tool[Item] then
		GenerateRepliRecipeAndTech(data.raw.tool[Item])
	elseif data.raw.ammo[Item] then
		GenerateRepliRecipeAndTech(data.raw.ammo[Item])
	elseif data.raw.capsule[Item] then
		GenerateRepliRecipeAndTech(data.raw.capsule[Item])
	elseif data.raw.gun[Item] then
		GenerateRepliRecipeAndTech(data.raw.gun[Item])
	elseif data.raw.armor[Item] then
		GenerateRepliRecipeAndTech(data.raw.armor[Item])
	elseif data.raw["rail-planner"][Item] then
		GenerateRepliRecipeAndTech(data.raw["rail-planner"][Item])
	end
end
--Now that all techs are generated, apply prereqs
for i, Item in pairs(RepliItems) do
	ApplyRecipePrereqs(Item)
end

LogAllItemValues()