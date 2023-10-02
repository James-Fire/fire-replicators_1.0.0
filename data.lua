require("__LSlib__/LSlib")
--Load Factorio libraray from core
require('resource-autoplace')
--Load some common functions used by the mod
require('prototypes.functions')

--Load the data for all the mod stuff except for the replications themselves
require('prototypes.raw-resources')
--require('prototypes.matter-plate')
require('prototypes.intermediate-products')
require('prototypes.replicators')
require('prototypes.matter-converters')
require('prototypes.replication-lab')
require('prototypes.eridium')

--itemgroup
require('prototypes.item-groups')

-- add limitation to modules

local intermediate_recipes = {'dark-matter-transducer', 'matter-conduit', 'dark-matter-scoop'}

for _, module in pairs(data.raw.module) do
  if module.effect['productivity'] and module.limitation then
    for _, recipe_name in pairs(intermediate_recipes) do
      table.insert(module.limitation, recipe_name)
    end
  end
end
