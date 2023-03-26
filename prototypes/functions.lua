--Generate the "unit" value for a new replication technology
function repl_research(tier, multiplier, time, reps_override)
	--Calculate the base number of research repetitions
	local reps = reps_override or -1
	if reps == -1 then
		reps = tier
		--Because tiers 1 and 5 only have one item each, their repetitions are doubled
		if tier == 1 or tier == 5 then
			reps = reps * 2
		end
	end
	
	--Create a list of required research materialss
	local ing = {}
	if tier == 1 or tier == 2 then
		ing[#ing + 1] = {"tenemut", 1}
	end
	if tier == 2 or tier == 3 then
		ing[#ing + 1] = {"dark-matter-scoop", 1}
	end
	if tier == 3 or tier == 4 then
		ing[#ing + 1] = {"dark-matter-transducer", 1}
	end
	if tier == 4 or tier == 5 then
		ing[#ing + 1] = {"matter-conduit", 1}
	end
	
	--Create and return the research cost table
	return {
		count = reps * multiplier,
		ingredients = ing,
		time = time
	}
end

--Get a field from a recipe result regardless of how that field is stored
function get_recipe_result_part(recipe, single_value, multiple_value, difficulty)
	multiple_value = multiple_value or single_value
	difficulty = difficulty or "normal"
	if recipe[single_value] then
		return recipe[single_value]
	elseif recipe.results and recipe.results[1][multiple_value] then
		return recipe.results[1][multiple_value]
	elseif recipe[difficulty] then
		if recipe[difficulty][single_value] then
			return recipe[difficulty][single_value]
		elseif recipe[difficulty].results and recipe[difficulty].results[1][multiple_value] then
			return recipe[difficulty].results[1][multiple_value]
		end
	end
end

--Table to string functions, for debugging purposes
--The following functions were copied and pasted from http://lua-users.org/wiki/TableUtils
function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end