local stdlib = require('__stdlib__/stdlib/utils/string')

local BaseMatterCost = 5 --How much matter is used to make 1 piece of ore  --settings.startup["tiberium-damage"].value
local BaseTimeCost = 5 --How much time is used to make 1 piece of ore, also the tech research time.  --settings.startup["tiberium-damage"].value
local TierTimeFactor = 1.2 --How much the time is increased per tier
local ItemTimeFactor = 1.2 --How much the time is increased per unique ore used to make the product normally, unused right now

local RepliOres = { }
local RepliOresFluids = { }
local RepliItems = { }
local ProcessedRepliItems = { }
local RepliTableTable = { }
local BadRecipePreList = { "loader", "fast-loader", "express-loader", "rocket-part", "infinity-chest", "electric-energy-interface", "infinity-pipe" }
local BadRecipeList = { }
local BadRecipeNameList = { }
local BadRecipeCategories = { }

local function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.ceil(num * mult + 0.5) / mult
end

local function CheckTableValue(Value,Table)
	for i, v in pairs(Table) do
		if Value == v then
			return true
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

for i, Recipe in pairs(data.raw.recipe) do
	local PotentialBadIngredients = { }
	local PotentialBadResults = { }
	local recipe_data = Recipe
	--Use string matching to grab likely recipes
	if stdlib.contains(Recipe.name, "barrel") or stdlib.contains(Recipe.name, "canister") and stdlib.contains(Recipe.name, "fill") or stdlib.contains(Recipe.name, "empty") then
		if Recipe.name == "empty-barrel" then
		else
			table.insert(BadRecipeList, Recipe)
			table.insert(BadRecipeNameList, Recipe.name)
		end
	end
	--Use string matching to grab likely recipe categories
	if stdlib.contains(Recipe.category, "deep") and stdlib.contains(Recipe.category, "mining") or stdlib.contains(Recipe.category, "mine") then
		if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
			table.insert(BadRecipeCategories, Recipe.category)
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
	if data.raw.recipe[Item] and NotBannedRecipe(data.raw.recipe[Item]) == true then
		return data.raw.recipe[Item]
	else
		for i, recipe in pairs(data.raw.recipe) do
			if NotBannedRecipe(recipe) == true then
				if recipe.mainproduct == Item then
					return recipe
				elseif recipe.mainproduct == nil then
					if recipe.results then
						for i, result_data in pairs(recipe.results) do
							if result_data.name == Item then
								return recipe
							end
						end
					elseif recipe.result then
						if recipe.result.name == Item then
							return recipe
						end
					end
				else
					return nil
				end
			end
		end
	end
end

local function itemPrototypesFromTable(prototypeTable)
	local out = {}
	if type(prototypeTable) ~= "table" then
		return out
	end
	for _, item in pairs(prototypeTable) do
		if item[1] then
			local amount = tonumber(item[2])
			if amount and amount >= 1 then
				out[item[1]] = math.floor(amount)
			end
		elseif item.name then
			local amount = tonumber(item.amount)
			if amount then
				amount = math.floor(amount)
			else
				local min = tonumber(item.amount_min) or 1  -- I don't think the "or 1"s will ever be reached, but playing it safe 
				local max = tonumber(item.amount_max) or 1
				amount = (min + math.max(min, max)) / 2
			end
			local probability = tonumber(item.probability)
			if probability then
				probability = math.max(0, math.min(1, probability))  -- Clamp to actual 0 to 1 range
				amount = amount * probability
			end
			if amount > 0 then
				out[item.name] = amount
			end
		end
	end
	return out
end

local function resultsToTable(prototypeTable)
	if type(prototypeTable) ~= "table" then	return {} end
	local out = itemPrototypesFromTable(prototypeTable.results)
	if LSlib.utils.table.isEmpty(out) and prototypeTable.result then
		out[prototypeTable.result] = tonumber(prototypeTable.result_count) or tonumber(prototypeTable.count) or 1
	end
	return out
end

local function CheckMasterTable(Item, ReturnValue) --1 returns the item string, 2 returns the tier integer, 3 returns the value integer, 4 returns the prereq table
	for i, entry in pairs(RepliTableTable) do
		if Item == entry[1] then
			return entry[ReturnValue]
		end
	end
end


--Basically just determine how many steps from ore the item is by following its ingredients. Look for the shortest appearance of ore.
--Make sure to save it somewhere so we aren't repeating this, cause this is expensive.
local function GetRecipeIngredientBreakdown(Item)
	local Recipe = FindItemRecipe(Item)
	if Recipe then --Check if the recipe exists, cause it might not for whatever reason
		log("Master Table before "..Recipe.name.." breakdown "..serpent.block(RepliTableTable))
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
		log("Recipe ingredients table for "..Recipe.name.." "..serpent.block(recipe_data.ingredients))
		if recipe_data.ingredients then
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
				table.insert(ingreditentstable,ingredientindex)
				log(ingredientindex.." for "..Recipe.name)
				if CheckMasterTable(ingredientindex, 1) then
					log(ingredientindex.." present on masterlist")
					ItemTier = ItemTier + CheckMasterTable(ingredientindex, 2)
					IngredientsValue = IngredientsValue + ingredientcount*CheckMasterTable(ingredientindex, 3)
				elseif CheckTableValue(ingredientindex,RepliOres) == true then
					log(ingredientindex.." not present on masterlist, and is ore")
					FoundOre = true
					ItemTier = CheckMasterTable(ingredientindex, 2) + 1
					IngredientsValue = IngredientsValue + ingredientcount
				else
					log(ingredientindex.." not present on masterlist, and isn't ore")
					local ReplicationValues = GetRecipeIngredientBreakdown(ingredientindex)
					if FoundOre == false and i == 1 then
						ItemTier = ItemTier + ReplicationValues[2]
					end
					IngredientsValue = IngredientsValue + ReplicationValues[3]
				end
			end
			log("Recipe ingredients name table for "..Recipe.name.." "..serpent.block(ingreditentstable))
			log(Recipe.name.." completed")
			if CheckTableValue({ Item, ItemTier+1, IngredientsValue },RepliTableTable) == false then
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
	log("Master Table: "..serpent.block(RepliTableTable))
end

local function GetReplicationTier(Item)
	local ReplicationTier = math.min(CheckMasterTable(Item, 2),5,5)
	return ReplicationTier
end

local function GetItemBorder(Item)
	return "repl-"..GetReplicationTier(Item)
end

local function GetTechBorder(Item)
	return "tech-repl-"..GetReplicationTier(Item)
end

local function GenerateRepliRecipeAndTech(Item)
	log("Generate recipe and tech for "..Item.name)
	if CheckMasterTable(Item.name, 1) == Item.name then
		table.insert(ProcessedRepliItems, Item) --Place the item in the "finished" table, so it's easier to keep track of what's been processed.
		local ItemIcon = nil
		local ItemIconSize = 32
		if Item.icon then
			ItemIcon = Item.icon
		end
		local ItemIconSize = 32
		if Item.icon_size then
			ItemIconSize = Item.icon_size
		end
		log("Replication Value for "..Item.name..": "..tostring(CheckMasterTable(Item.name, 3)))
		log("Tech cost for "..Item.name..": "..tostring(round(CheckMasterTable(Item.name, 3)/4)))
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
						scale = ItemIconSize/64,
						shift = {0, 0},
					},
				},
				category = "replication-"..tostring(GetReplicationTier(Item.name)),
				enabled = false,
				energy_required = BaseTimeCost*TierTimeFactor^CheckMasterTable(Item.name, 2),
				ingredients = {
					{type = "fluid", name = "eridium", amount = BaseMatterCost*CheckMasterTable(Item.name, 3) },
				},
				results = {
					{ Item.name, 1 },
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
					count = math.abs(round(CheckMasterTable(Item.name, 3)/4)),
					ingredients = {
						{"tenemut", 4},
					},
					time = BaseTimeCost*TierTimeFactor^CheckMasterTable(Item.name, 2),
				},
				order = "a",
			},
		})
		LSlib.technology.addPrerequisite(Item.name.."-replication-research", "replication-1")
		if CheckMasterTable(Item.name, 2) > 2 then
			LSlib.technology.addIngredient(Item.name.."-replication-research", 3, "dark-matter-scoop")
			LSlib.technology.movePrerequisite(Item.name.."-replication-research", "replication-1", "replication-2")
		end
		if CheckMasterTable(Item.name, 2) > 3 then
			LSlib.technology.removeIngredient(Item.name.."-replication-research", "tenemut")
			LSlib.technology.addIngredient(Item.name.."-replication-research", 1, "dark-matter-scoop")
			LSlib.technology.addIngredient(Item.name.."-replication-research", 2, "dark-matter-transducer")
			LSlib.technology.movePrerequisite(Item.name.."-replication-research", "replication-2", "replication-3")
		end
		if CheckMasterTable(Item.name, 2) > 4 then
			LSlib.technology.addIngredient(Item.name.."-replication-research", 1, "dark-matter-transducer")
			LSlib.technology.addIngredient(Item.name.."-replication-research", 1, "matter-conduit")
			LSlib.technology.movePrerequisite(Item.name.."-replication-research", "replication-3", "replication-4")
		end
		if CheckMasterTable(Item.name, 2) > 5 then
			LSlib.technology.addIngredient(Item.name.."-replication-research", 1, "matter-conduit")
			LSlib.technology.movePrerequisite(Item.name.."-replication-research", "replication-4", "replication-5")
		end
		log("Recipe: "..serpent.block(Item.name.."-replication").."  Tech: "..serpent.block(Item.name.."-replication-research"))
	end
end

local function ApplyRecipePrereqs(Item)
	local prereqtable = { }
	prereqtable = CheckMasterTable(Item, 4)
	if prereqtable then
		for i, prereq in pairs(prereqtable) do
			LSlib.technology.addPrerequisite(Item.."-replication-research", prereq.."-replication-research")
		end
	end
end

--Start by documenting all items and fluids, and ensuring there's a recipe that makes it. Or if it's a resource.
for i, Item in pairs(data.raw.item) do
	if CheckRecipeResultTableValue(Item.name) == true then
		table.insert(RepliItems,Item.name)
	end
end
for i, Fluid in pairs(data.raw.fluid) do
	if CheckRecipeResultTableValue(Item.name) == true then
		table.insert(RepliItems,Item.name)
	end
end

for _, resourceData in pairs(data.raw.resource) do
	--Exclude infinite mining stuff.
	if resourceData.category and stdlib.contains(resourceData.category, "deep") and stdlib.contains(resourceData.category, "mining") or stdlib.contains(resourceData.category, "mine") then

	elseif resourceData.autoplace and resourceData.minable then
		table.insert(RepliOres,data.raw.item[resourceData.minable.result])
		if resourceData.minable.results then
			for _, result in pairs(resourceData.minable.results) do
				if result.type == "fluid" then
					table.insert(RepliOres,data.raw.fluid[result.name])
				else
					table.insert(RepliOres,data.raw.item[result.name])
				end
			end
		end
	end
end
log("Items Table: "..serpent.block(RepliItems))
log("Ores Table: "..serpent.block(RepliOres))
log("Ores Table: "..serpent.block(RepliOresFluids))


--Start recipe generation with ores
for i, Item in pairs(RepliOres) do
	table.insert(RepliTableTable,{ Item, 0, 1 })
end
--Insert wood manually, if it's not already there
if CheckTableValue("wood",RepliTableTable) == false then
	table.insert(RepliTableTable,{ "wood", 0, 1 })
end
--Insert water manually, if it's not already there
if CheckTableValue("water",RepliTableTable) == false then
	table.insert(RepliTableTable,{ "water", 0, 1 })
end
--Calculate item values
for i, Item in pairs(RepliItems) do
	GetRecipeIngredientBreakdown(Item)
end
--Recipe and tech generation with ore
for i, Item in pairs(RepliOres) do
	GenerateRepliRecipeAndTech(Item)
end
--Recipe and tech generation with everything else
for i, Item in pairs(RepliItems) do
	GenerateRepliRecipeAndTech(data.raw.item[Item])
end
--Now that all techs are generated, apply prereqs
for i, Item in pairs(RepliItems) do
	ApplyRecipePrereqs(Item)
end

LogAllItemValues()