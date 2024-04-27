log(settings.startup["item-collection-type"].value)

if settings.startup["replication-steps-logging"].value then
	log("Starting variable and function initialization")
end

local BaseMatterCost = settings.startup["base-matter-cost"].value * settings.startup["liquid-matter-required"].value * settings.startup["liquid-matter-used"].value --How much matter is used to make 1 piece of ore
local AddedMatterCostDivisor = 1 --How much to divide ingredient values by. It's easier to make the final product directly?
local BaseTimeCost = 5 --How much time is used to make 1 piece of ore, also the tech research time.  --settings.startup["tiberium-damage"].value
local TierTimeFactor = 0.8 --Exponent to make time curve flatter
local ItemTimeFactor = 1.2 --How much the time is increased per unique ore used to make the product normally, unused right now
local MaxTier = settings.startup["replication-max-tier"].value --The max tier that we can generate. Currently only 5 will work, probably.
local TierDivisor = 1 --How many tiers of items are in each tier band. Is calculated by code, not set here.
local TierBands = { 1, 2, 3, 4, 5 }

local RepliOres = { }
local RepliItems = { }
local ProcessedRepliItems = { }
local RepliTableTable = { }
local BadItemList = { "loader", "fast-loader", "express-loader", "rocket-part", "infinity-chest", "electric-energy-interface", "infinity-pipe", "item-unknown", "player-port" }
local BadRecipePreList = { "loader", "fast-loader", "express-loader", "rocket-part", "infinity-chest", "electric-energy-interface", "infinity-pipe", "player-port" }
local GoodRecipeList = { }
local BadRecipeList = { }
local BadRecipeNameList = { }
local BadRecipeCategories = { "forcefield-crafter" }
local Items = { "item", "fluid", "module", "tool", "ammo", "capsule", "armor", "gun", "rail-planner", "repair-tool", "item-with-entity-data", "spidertron-remote" }
local RocketLaunchItems = { }

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

local function GetRecipeCategory(Recipe)
	if Recipe.category then
		return Recipe.category
	else
		return "crafting"
	--[[if Recipe.result then
		if data.raw.item[Recipe.result] then
			return data.raw.item[Recipe.result].subgroup
		end]]
	end
end

local function NotBannedRecipe(Recipe)
	if CheckTableValue(GetRecipeCategory(Recipe),BadRecipeCategories) == true then
		return false
	end
	if CheckTableValue(Recipe,BadRecipeList) == true then
		return false
	end
	if CheckTableValue(Recipe.name,BadRecipeNameList) == true then
		return false
	end
	return true
end
local function CheckRecipeResultTableValue(Item)
	if Item == "item-unknown" then
		return false
	else
		if data.raw.recipe[Item] then
			--log("Found same name recipe for "..Item)
			return true
		else
			--log("Checking for recipe for "..Item)
			for i, recipe in pairs(GoodRecipeList) do
				--log("Checking recipe "..recipe.name.." for "..Item)
				local recipe_data = recipe
				if recipe.normal then
					recipe_data = recipe.normal
				end
				if recipe_data.results then
					--log("Recipe "..recipe.name.." has a result table")
					for j, result in pairs(recipe_data.results) do
						if Item == result.name then
							--log("Found result table production recipe "..recipe.name.." for "..Item)
							return true
						end
					end
				elseif recipe_data.result then
					--log("Recipe "..recipe.name.." has a single result")
					if Item == recipe_data.result then
						--log("Found single-result production recipe "..recipe.name.." for "..Item)
						return true
					end
				end
			end
		end
	end
	return false
end
--Insert bad recipes
if settings.startup["replication-steps-logging"].value then
	log("Starting bad recipe collection")
end
for i, recipe in pairs(BadRecipePreList) do
	table.insert(BadRecipeList, data.raw.recipe[recipe])
	table.insert(BadRecipeNameList, recipe)
end

local function FluidBarrelMatch(Fluid)
	if data.raw.item[Fluid.."-barrel"] then
		return data.raw.item[Fluid.."-barrel"].name
	elseif data.raw.item[Fluid.."-canister"] then
		return data.raw.item[Fluid.."-canister"].name
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
	if RecipeName:find("fp-da", 1, true) then
		--log("Found Fluid Permutation recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	elseif RecipeName:find("barrel", 1, true) or RecipeName:find("canister", 1, true) then
		if RecipeName:find("fill", 1, true) or RecipeName:find("empty", 1, true) then
			if RecipeName == "empty-barrel" then
				return false
			else
				if CheckTableValue(RecipeName,BadRecipeNameList) == false then
					return true
				end
			end
		end
	--[[elseif RecipeName:find("reforming", 1, true) or RecipeName:find("cracking", 1, true) then
		--log("Found cracking recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end]]
	elseif RecipeName:find("liquefaction", 1, true) or RecipeName:find("request-", 1, true) then
		--log("Found liquefaction recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	elseif RecipeName:find("scrap", 1, true) and (not RecipeName:find("skyscraper", 1, true)) then
		--log("Found scrap recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	elseif RecipeName:find("joule", 1, true) then
		--log("Found scrap recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	elseif RecipeName:find("coolant", 1, true) and RecipeName:find("hot", 1, true) or RecipeName:find("cold", 1, true) then
		--log("Found scrap recipe "..RecipeName)
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	elseif RecipeName:find("person", 1, true) then
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	elseif RecipeName:find("lower-bin-tier", 1, true) then
		if CheckTableValue(RecipeName,BadRecipeNameList) == false then
			return true
		end
	end
	return false
end
local function ItemStringMatch(ItemName)
	if ItemName:find("interface", 1, true) or ItemName:find("infinity", 1, true) or ItemName:find("dummy", 1, true) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	elseif ItemName:find("ore", 1, true) and ItemName:find("chunk", 1, true) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	elseif ItemName:find("recycle", 1, true) or ItemName:find("recycling", 1, true) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	elseif ItemName:find("scrap", 1, true) and (not ItemName:find("skyscraper", 1, true)) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	elseif ItemName:find("person", 1, true) or ItemName:find("seed", 1, true) then
		if CheckTableValue(ItemName,BadItemList) == false then
			return true
		end
	end
	return false
end
local function FluidStringMatch(FluidName)
	if FluidName:find("torque", 1, true) or FluidName:find("steam", 1, true) then
		if CheckTableValue(FluidName,BadItemList) == false then
			return true
		end
	elseif FluidName:find("joule", 1, true) then
		if CheckTableValue(FluidName,BadItemList) == false then
			return true
		end
	elseif FluidName:find("coolant", 1, true) and (FluidName:find("hot", 1, true) or FluidName:find("cold", 1, true)) then
		if CheckTableValue(FluidName,BadItemList) == false then
			return true
		end
	end
	return false
end

for i, Item in pairs(data.raw.item) do
	if ItemStringMatch(Item.name) then
		log("Found bad item "..Item.name)
		table.insert(BadItemList, Item.name)
	end
end
for i, Fluid in pairs(data.raw.fluid) do
	if FluidStringMatch(Fluid.name) then
		log("Found bad fluid "..Fluid.name)
		table.insert(BadItemList, Fluid.name)
	end
end
local function RecipeBadnessTest(Recipe)
	local PotentialBadIngredients = { }
	local PotentialBadResults = { }
	local recipe_data = Recipe
	
	--Check if the recipe name contains any specific words and/or combination of words that means bad
	if RecipeStringMatch(Recipe.name) then
		return true
	end
	
	--Use string matching to grab likely bad recipe categories
	if Recipe.category then
		if CheckTableValue(Recipe.category,BadRecipeCategories) == true then
			if CheckTableValue(Recipe,BadRecipeList) == false then
				return true
			end
		elseif Recipe.category:find("deep", 1, true) and Recipe.category:find("mining", 1, true) or Recipe.category:find("mine", 1, true) then
			if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
				table.insert(BadRecipeCategories, Recipe.category)
				return true
			end
		elseif Recipe.category:find("recycle", 1, true) or Recipe.category:find("recycling", 1, true) then
			if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
				table.insert(BadRecipeCategories, Recipe.category)
				return true
			end
		elseif Recipe.category:find("person", 1, true) then
			if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
				table.insert(BadRecipeCategories, Recipe.category)
				return true
			end
		elseif Recipe.category:find("tur_converter", 1, true) then
			if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
				table.insert(BadRecipeCategories, Recipe.category)
				return true
			end
		elseif Recipe.category:find("transport", 1, true) and Recipe.category:find("request", 1, true) then
			if CheckTableValue(Recipe.category,BadRecipeCategories) == false then
				table.insert(BadRecipeCategories, Recipe.category)
				return true
			end
		end
	end
	--[[if Recipe.normal then
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
	end]]

end
if settings.startup["item-collection-type"].value == "items" then
	for i, Recipe in pairs(data.raw.recipe) do
		--log("Checking "..Recipe.name)
		if RecipeBadnessTest(Recipe) then
			log(Recipe.name.." is bad")
			table.insert(BadRecipeList, Recipe)
			table.insert(BadRecipeNameList, Recipe.name)
		end
	end
elseif settings.startup["item-collection-type"].value == "recipes" then
	for i, Recipe in pairs(data.raw.recipe) do
		--log("Checking "..Recipe.name)
		if RecipeBadnessTest(Recipe) then
			--log(Recipe.name.." is bad")
			table.insert(BadRecipeList, Recipe)
			table.insert(BadRecipeNameList, Recipe.name)
		else
			--log(Recipe.name.." is not bad")
			local recipe_data = Recipe
			if Recipe.normal then
				recipe_data = Recipe.normal
			end
			--log(serpent.block(recipe_data))
			if recipe_data.results then
				--log("Recipe has results table: "..serpent.block(recipe_data.results))
				for i, result in pairs(recipe_data.results) do
					local recipeindex = nil
					if result.name then
						recipeindex = result.name
					else
						recipeindex = result[1]
					end
					if recipeindex then
						--log("Item "..recipeindex.." exists")
						if CheckTableValue(recipeindex, BadItemList) == false then
							--log("Item "..recipeindex.." isn't bad item")
							if CheckTableValue(recipeindex, RepliItems) == false then
								--log("Item "..recipeindex.." isn't already on the list")
								table.insert(RepliItems,recipeindex)
							end
						end
					end
				end
			elseif recipe_data.result then
				--log("Recipe has single result: "..serpent.line(recipe_data.result))
				
				if CheckTableValue(recipe_data.result, BadItemList) == false then
					--log("Item "..recipe_data.result.." isn't bad item")
					if CheckTableValue(recipe_data.result, RepliItems) == false then
						--log("Item "..recipe_data.result.." isn't already on the list")
						table.insert(RepliItems,recipe_data.result)
					end
				end
			end
		end
	end
end


--log("Bad Recipe Table: "..serpent.block(BadRecipeList))
--log("Bad Recipe Name Table: "..serpent.block(BadRecipeNameList))
--log("Bad Category Table: "..serpent.block(BadRecipeCategories))
--log("Bad Item Table: "..serpent.block(BadItemList))

for i, recipe in pairs(data.raw.recipe) do
	--log("Good Recipe Candidate: "..serpent.block(recipe))
	if NotBannedRecipe(recipe) == true then
		--log("Good Recipe Inserted: "..recipe.name)
		table.insert(GoodRecipeList, recipe)
	end
end
--log("Good Recipe List: "..serpent.block(GoodRecipeList))

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

local function FindItemRecipe(ItemName)
	local RecipeTable = { }
	if data.raw.recipe[ItemName] then
		if NotBannedRecipe(data.raw.recipe[ItemName]) == true then
			if CheckTableValue(data.raw.recipe[ItemName],RecipeTable) == false then
				table.insert(RecipeTable,data.raw.recipe[ItemName])
			end
		end
	end
	for i, recipe in pairs(GoodRecipeList) do
		if CheckTableValue(recipe,RecipeTable) == false then
			if recipe.main_product == ItemName then
					table.insert(RecipeTable,recipe)
			else
				local recipe_data = recipe
				if recipe.normal then
					recipe_data = recipe.normal
				end
				if recipe_data.results then
					for i, result_data in pairs(recipe_data.results) do
						if (result_data.name or result_data[1]) == ItemName then
							table.insert(RecipeTable,recipe)
						end
					end
				elseif recipe_data.result then
					if recipe_data.result == ItemName then
						table.insert(RecipeTable,recipe)
					end
				end
			end
		end
	end
	for i, r1 in pairs(RecipeTable) do
		for j, r2 in pairs(RecipeTable) do
			if i ~= j then
				if r1 == r2 then
					if RecipeTable[j] then
						RecipeTable[j] = nil
					end
				end
			end
		end
	end
	return RecipeTable
end

local function FindRocketLaunchItem(ItemName)
	local LaunchItem = RocketLaunchItems[ItemName]
	if LaunchItem then
		return LaunchItem
	end
	return nil
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
		energy = 5
	end
	if ore:find("eridium", 1, true) then
		recipeName = "regenerative-matter"
		oreAmount = 4 * settings.startup["liquid-matter-required"].value
		energy = 10
	else
	end
	
	LSlib.recipe.create(recipeName)
	if itemOrFluid == "fluid" and (not ore:find("eridium", 1, true)) then
		LSlib.recipe.addIngredient(recipeName, ore, 25, itemOrFluid)
	else
		LSlib.recipe.addIngredient(recipeName, ore, oreAmount, itemOrFluid)
	end
	LSlib.recipe.addResult(recipeName, "eridium", BaseMatterCost * settings.startup["liquid-matter-generated"].value, "fluid")
	LSlib.recipe.setMainResult(recipeName, "eridium")
	LSlib.recipe.setEnergyRequired(recipeName, energy)
	LSlib.recipe.setOrderstring(recipeName, order)
	LSlib.recipe.enable(recipeName)
	LSlib.recipe.setSubgroup(recipeName, "replication-resources")
	LSlib.recipe.setShowMadeIn(recipeName, true)
	LSlib.recipe.setCraftingCategory(recipeName, "Matter-Converter")
	--[[if data.raw[itemOrFluid][ore].icon then
		local Icons = {
			{
				icon = "__fire-replicators__/graphics/icons/eridium.png",
				icon_size = 32,
			},
			{
				icon = data.raw[itemOrFluid][ore].icon,
				icon_size = data.raw[itemOrFluid][ore].icon_size,
				--scale = data.raw[itemOrFluid][ore].icon_size,
			},
		}
		LSlib.recipe.changeIcons(recipeName, Icons, 32)
	end]]
end

--Basically just determine how many steps from ore the item is by following its ingredients. Look for the shortest appearance of ore.
--Make sure to save it somewhere so we aren't repeating this, cause this is expensive.
local function GetRecipeIngredientBreakdown(Item, PrevRecipeTable)
	--log(Item.." started")
	if Item:find("chip", 1, true) or Item:find("copper-electronic", 1, true) then
		--log(Item.." started")
	end
	local Recipe = FindItemRecipe(Item)[1]
	local RocketLaunchItem = FindRocketLaunchItem(Item)
	if RocketLaunchItem then
		log(Item.." is a rocket launch product")
		local ItemTier = 0 --Item tier determines some multiplicative stuff.
		local IngredientsValue = 0 --How much liquid Matter you need to replicate the item
		if CheckMasterTable(RocketLaunchItem.name, 1) then
			ItemTier = (CheckMasterTable(RocketLaunchItem.name, 2)+1)
			IngredientsValue = (CheckMasterTable(RocketLaunchItem.name, 3)/RocketLaunchItem.rocket_launch_product[2])
		else 
			local ReplicationValues = GetRecipeIngredientBreakdown(RocketLaunchItem.name,PrevRecipeTable)
			ItemTier = ReplicationValues[2]
			IngredientsValue = ReplicationValues[3]/RocketLaunchItem.rocket_launch_product[2]
		end
		table.insert(RepliTableTable,{ Item, ItemTier, IngredientsValue, {RocketLaunchItem.name} })
		return { Item, ItemTier, IngredientsValue }
	elseif Recipe and CheckTableValue(Recipe,PrevRecipeTable) == false then --Check if the recipe exists, cause it might not for whatever reason
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
			local ingredientstable = { }
			if recipe_data.results then
				for i, result in pairs(recipe_data.results) do
					if result.count then
						resultcount = resultcount + result.count
					elseif result.amount then
						resultcount = resultcount + result.amount
					end
				end
			elseif recipe_data.result then
				if recipe_data.result_count then
					resultcount = recipe_data.result_count
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
				table.insert(ingredientstable,ingredientindex)
				--log(ingredientindex.." for "..Recipe.name)
				if CheckMasterTable(ingredientindex, 1) then
					--log(ingredientindex.." present on masterlist")
					if FoundOre == false and i == 1 then
						ItemTier = ItemTier + CheckMasterTable(ingredientindex, 2) + 1
					end
					IngredientsValue = IngredientsValue + ingredientcount/AddedMatterCostDivisor*CheckMasterTable(ingredientindex, 3)
				elseif CheckTableValue(ingredientindex,RepliOres) == true then
					--log(ingredientindex.." not present on masterlist, and is ore")
					FoundOre = true
					if FoundOre == false and i == 1 then
						ItemTier = CheckMasterTable(ingredientindex, 2) + 1
					end
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
								--log("Recipe Loop for "..Item..", aborting")
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
			--log("Recipe ingredients name table for "..Recipe.name.." "..serpent.block(ingredientstable))
			--log(Recipe.name.." completed")
			--log(Item.." matter cost: "..(IngredientsValue/resultcount))
			if CheckTableValue( Item,RepliTableTable,1 ) == false then
				table.insert(RepliTableTable,{ Item, ItemTier+1, IngredientsValue/resultcount, ingredientstable })
				if Item:find("chip", 1, true) or Item:find("copper-electronic", 1, true) then
					--log(serpent.block({ Item, ItemTier+1, IngredientsValue/resultcount, ingredientstable }))
				end
			end
			return { Item, ItemTier+1, IngredientsValue/resultcount }
		end
	end
	--[[else
		log("GetRecipeIngredientBreakdown was passed "..Item.." that isn't in RepliItems")
	end]]
end

local function LogAllItemValues()
	for _, entry in pairs(RepliTableTable) do
		log("Item Values Master Table: "..serpent.line(entry))
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

local function GenerateRepliRecipeAndTech(Item)
	--log("Generate recipe and tech for "..Item.name)
	if CheckMasterTable(Item.name, 1) == Item.name then
		table.insert(ProcessedRepliItems, Item) --Place the item in the "finished" table, so it's easier to keep track of what's been processed.
		local ItemType = nil
		local ItemOrder = "1"
		local ItemIcon = "__core__/graphics/empty.png"
		local ItemIcons = { }
		local ReverseItemIcons = { }
		local ItemIconSize = 1
		local ItemMipMaps = 1
		if Item.order then
			ItemOrder = Item.order
		end
		if Item.type == "fluid" then
			ItemType = "fluid"
		else
			ItemType = "item"
		end
		--Icon stuff
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
		if Item.icons then
			for i, icons in pairs(Item.icons) do
				table.insert(ItemIcons,icons)
			end
		elseif ItemIcon ~= "__core__/graphics/empty.png" then
			table.insert(ItemIcons,
			{
				icon = ItemIcon,
				icon_size = ItemIconSize,
			})
		end
		table.insert(ItemIcons, 
		{
			icon = "__fire-replicators__/graphics/icons/borders/"..GetItemBorder(Item.name)..".png",
			icon_size = 32,
			scale = 1,
			shift = {0, 0},
		})
		for i, icon in pairs(ItemIcons) do
			table.insert(ReverseItemIcons,icon)
		end
		--Tech Name stuff
		local ItemLocalName = ""
		if Item.localised_name then
			ItemLocalName = Item.localised_name
		elseif Item.place_result then
			ItemLocalName = {"entity-name."..Item.place_result}
		--elseif {ItemType.."-name." .. Item.name} then
		else
			ItemLocalName = {"item-name."..Item.name}
		end
		--Reverse Recipes tech and enabling
		local ReverseEnabled = true
		local ReverseTech = true
		--log("Replication Value for "..Item.name..": "..tostring(CheckMasterTable(Item.name, 3)))
		--log("Tech cost for "..Item.name..": "..tostring(round(CheckMasterTable(Item.name, 3)/4)))
		--log("Icon String for "..Item.name..": "..ItemIcon)
		--log("Icon Size for "..Item.name..": "..ItemIconSize)
		--log("Icon Border Scale for "..Item.name..": "..GetBorderSizeScale(ItemIconSize))
		data:extend({
			{
				type = "recipe",
				name = Item.name.."-replication",
				icons = ItemIcons,
				category = "replication-"..tostring(GetReplicationTier(Item.name)),
				enabled = false,
				energy_required = round(BaseTimeCost+2^GetReplicationTier(Item.name)*CheckMasterTable(Item.name, 2)^TierTimeFactor, 1),
				ingredients = {
					{type = "fluid", name = "eridium", amount = round(BaseMatterCost*CheckMasterTable(Item.name, 3)) },
				},
				results = {
					{ name = Item.name, amount = 1, type = ItemType },
				},
				subgroup = "replication-"..tostring(GetReplicationTier(Item.name)),
				order = "a-"..tostring(CheckMasterTable(Item.name, 2)).."-"..tostring(round(BaseMatterCost*CheckMasterTable(Item.name, 3))),
			},
			{
				type = "technology",
				localised_name = { "technology-name.replication-research", ItemLocalName },
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
					count = GetReplicationTier(Item.name)*GetReplicationTier(Item.name)*10,
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
		if settings.startup["matter-converters-melting-research"].value then
			ReverseEnabled = false
		end
		if settings.startup["matter-converters-melting"].value and CheckTableValue(Item.name,RepliOres) == false then
			table.insert(ReverseItemIcons,
			{
				icon = "__fire-replicators__/graphics/icons/eridium.png",
				icon_size = 32,
				scale = 0.5,
				shift = {8, -8},
			})
			data:extend({
				{
					type = "recipe",
					name = Item.name.."-reverse-replication",
					icons = ReverseItemIcons,
					category = "Matter-Converter",
					hidden = true,
					enabled = ReverseEnabled,
					energy_required = round(BaseTimeCost*GetReplicationTier(Item.name), 1),
					ingredients = {
						{ name = Item.name, amount = 1, type = ItemType },
					},
					results = {
						{type = "fluid", name = "eridium", amount = round(BaseMatterCost*CheckMasterTable(Item.name, 3)*0.9) },
					},
					subgroup = "replication-resources",
					order = "z-1",
				},
			})
		end
	end
end

--Apply prereqs so things like Steel replication need iron replication
local function ApplyRecipePrereqs(Item)
	local prereqtable = { }
	prereqtable = CheckMasterTable(Item, 4)
	if prereqtable then
		for i, prereq in pairs(prereqtable) do
			if data.raw.technology[prereq.."-replication-research"] and (not CheckTableValue(data.raw.technology[prereq.."-replication-research"].name,data.raw.technology[Item.."-replication-research"].prerequisites)) then
				LSlib.technology.addPrerequisite(Item.."-replication-research", prereq.."-replication-research")
			end
		end
	end
end

--Start by documenting all items, fluids, modules, and tools, and ensuring there's a recipe that makes it. Or if it's a resource.
if settings.startup["replication-steps-logging"].value then
	log("Starting item collection")
end
if settings.startup["item-collection-type"].value == "items" then
	for i, ItemType in pairs(Items) do
		for j, Item in pairs(data.raw[ItemType]) do
			--log("Checking Item: "..Item.name)
			if CheckTableValue(Item.name, BadItemList) == false then
				--log(Item.name.." isn't banned")
				if CheckRecipeResultTableValue(Item.name) == true then
					--log(Item.name.." has a recipe that makes it")
					table.insert(RepliItems,Item.name)
				end
				if Item.rocket_launch_product then
					--log(Item.name.." has a rocket launch product"..Item.rocket_launch_product[1])
					RocketLaunchItems[Item.rocket_launch_product[1]] = Item
					if CheckTableValue(Item.rocket_launch_product[1], RepliItems) == false then
						table.insert(RepliItems,Item.rocket_launch_product[1])
					end
					table.insert(RepliItems,Item.name)
				end
			end
		end
	end
end
--[[for j, Recipe in pairs(data.raw.recipe) do
	if NotBannedRecipe(Recipe) then
		log(Recipe.name.." isn't banned")
		--Rocket launch products need different handling in the value calculation, unimplemented so far
		if data.raw.item[recipeindex].rocket_launch_product then
			local RocketLaunch = data.raw.item[recipeindex].rocket_launch_product[1]
			if CheckTableValue(RocketLaunch, BadItemList) == false then
				table.insert(RepliItems,recipeindex)
			end
		end
	end
end]]
if settings.startup["replication-steps-logging"].value then
	log("Starting resource collection")
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
end
--Insert water manually, if it's not already there
if CheckTableValue("water",RepliOres) == false then
	table.insert(RepliOres, "water")
end
--Sulfur is a raw resource
if CheckTableValue("sulfur",RepliOres) == false then
	table.insert(RepliOres, "sulfur")
end
--Make sure no ores are in the item table
for i, Item in pairs(RepliItems) do
	if CheckTableValue(Item,RepliOres) == true then
		log(Item.." is actually an ore")
		RepliItems[i] = nil
	end
end

if settings.startup["replication-final-data-logging"].value then
	log("Items Table: "..serpent.block(RepliItems))
	log("Ores Table: "..serpent.block(RepliOres))
end


--Start recipe generation with ores
if settings.startup["replication-steps-logging"].value then
	log("Giving all ores the base values")
end
for i, Item in pairs(RepliOres) do
	table.insert(RepliTableTable,{ Item, 0, 1 })
end
table.insert(RepliTableTable,{ "steam", 1, 2, {"water"} })
if settings.startup["replication-steps-logging"].value then
	log("Starting Matter Conversion recipes")
end


if settings.startup["liquid-matter"].value then
	for i, Item in pairs(RepliOres) do
		addMatterRecipe(Item)
	end
	addMatterRecipe("eridium")
end

--Calculate item values
if settings.startup["replication-steps-logging"].value then
	log("Starting item value calculation")
end
for i, Item in pairs(RepliItems) do
	local PrevRecipeTable = { }
	if CheckTableValue( Item,RepliTableTable,1 ) == false then
		GetRecipeIngredientBreakdown(Item, PrevRecipeTable)
	end
end

--After calculating stuff, extract all the tier values

if settings.startup["replication-steps-logging"].value then
	log("Starting Tier calculation")
end
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
for i, entry in pairs(RepliTableTable) do
	table.insert(TierTable, entry[2])
	if entry[2] > HighestTier[1] then
		table.insert(HighestTier, 1, entry[2])
	end
end
--log("Item tiers extracted and sorted")
--log("Highest Tiers:")
--for _, entry in pairs(HighestTier) do
--	log(serpent.line(entry))
--end
--log("Highest Tiers Mean:"..serpent.line(Mean(HighestTier)))
--log("Highest Tiers Median:"..serpent.line(Median(HighestTier)))
--log("All recipe tier Mean:"..serpent.line(Mean(TierTable)))
--log("All recipe tier Median:"..serpent.line(Median(TierTable)))
table.sort(TierTable)
--Prune the highest tier if it's too high
for i, Tier in pairs(HighestTier) do
	if Tier > (2*Median(TierTable)) then
		if settings.startup["replication-tier-calculation-logging"].value then
			log("Tier "..Tier.." is more than 2x higher than the Median "..tostring(Median(TierTable))..", tossing")
		end
	else
		if settings.startup["replication-tier-calculation-logging"].value then
			log("Tier "..Tier.." is not too high, continuing")
		end
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

if settings.startup["replication-final-data-logging"].value then
	log("Tier Band Width: "..tostring(TierDivisor))
	log("Highest non-outlier Tier: "..tostring(CalculatedTier))
	log("Calculated tier bands: "..serpent.block(TierBands))
	log("Tier band recipe count: "..serpent.block(TierCount))
end

--Recipe and tech generation with ores
if settings.startup["replication-steps-logging"].value then
	log("Starting ore Recipe and Tech Generation")
end
for i, Item in pairs(RepliOres) do
	--log("Item "..Item.." at position: "..tostring(i))
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
	elseif data.raw["repair-tool"][Item] then
		GenerateRepliRecipeAndTech(data.raw["repair-tool"][Item])
	elseif data.raw["item-with-entity-data"][Item] then
		GenerateRepliRecipeAndTech(data.raw["item-with-entity-data"][Item])
	elseif data.raw["spidertron-remote"][Item] then
		GenerateRepliRecipeAndTech(data.raw["spidertron-remote"][Item])
	end
end
--Recipe and tech generation with everything else
if settings.startup["replication-steps-logging"].value then
	log("Starting item Recipe and Tech Generation")
end
for i, Item in pairs(RepliItems) do
	--log("Item "..Item.." at position: "..tostring(i))
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
	elseif data.raw["repair-tool"][Item] then
		GenerateRepliRecipeAndTech(data.raw["repair-tool"][Item])
	elseif data.raw["item-with-entity-data"][Item] then
		GenerateRepliRecipeAndTech(data.raw["item-with-entity-data"][Item])
	elseif data.raw["spidertron-remote"][Item] then
		GenerateRepliRecipeAndTech(data.raw["spidertron-remote"][Item])
	end
end
--Now that all techs are generated, apply prereqs
if settings.startup["replication-steps-logging"].value then
	log("Starting Tech Prereq application")
end
for i, Item in pairs(RepliItems) do
	ApplyRecipePrereqs(Item)
end
--Log the master table
if settings.startup["replication-final-data-logging"].value then
	LogAllItemValues()
end
--Log the bad items table
if settings.startup["replication-final-data-logging"].value then
	log("Starting bad item logging")
	for _, entry in pairs(BadItemList) do
		log(entry.." Item is considered bad")
	end
end
--Log the bad recipes table
if settings.startup["replication-final-data-logging"].value then
	log("Starting bad recipe logging")
	for _, entry in pairs(BadRecipeNameList) do
		log(entry.." recipe is considered bad")
	end
end

--Go through the master table to see if anything is suspicious
if settings.startup["potential-bad-replication-logging"].value then
	--1 returns the item string, 2 returns the tier integer, 3 returns the value integer, 4 returns the prereq table, 5 returns the unlock tech
	log("Starting suspicious item logging")
	for _, entry in pairs(RepliTableTable) do
		if entry[4] == nil and CheckTableValue(entry[1],RepliOres) == false then 
			log(entry[1]..": Item has no requirements, and isn't an Ore")
		end
		if entry[3] == 0 and CheckTableValue(entry[1],RepliOres) == false then 
			log(entry[1]..": Item has no cost")
		end
		if entry[4] then
			for _, Item in pairs(entry[4]) do
				if CheckMasterTable(Item, 1) == false then
					log(entry[1].." Item has requirement "..Item.." that is not calculated")
				end
			end
		end
	end
	log("Ending suspicious item logging")
end


--Unused

--[[if settings.startup["use-existing-master-table"].value then
	MasterTable = require("master-table")
else
	MasterTable = { }
end]]

--Make a checksum for the master table, if we need it
--[[local function MasterTableChecksum()
	local ChecksumTable = { }
	--Log things that we don't need to calculate. Best is more cheaper info over better expensive info, as enough data points will get close enough
	
	--Log the modlist
	
	--Log the items
	
	--Log the recipes
	
	--log the mod settings that actually affect generation
	
	return ChecksumTable
end

local MasterTableChecksumMatch = false

if settings.startup["log-master-table"].value or settings.startup["use-existing-master-table"].value then
	if settings.startup["ignore-master-table-checksum"].value == false then
		if MasterTable[1] == MasterTableChecksum() then
			MasterTableChecksumMatch = true
		end
	end
end
if MasterTable[2] and settings.startup["use-existing-master-table"].value and MasterTableChecksumMatch == true or settings.startup["ignore-master-table-checksum"].value then
	RepliTableTable = MasterTable[2]
else]]