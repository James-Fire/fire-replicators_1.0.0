--These are the other mod settings.  They're fairly straightforward.
data:extend({
	
	--[[{ --Master table stuff. Not implemented, may not ever be, as it seems unecessary now
		type = "bool-setting",
		name = "use-existing-master-table",
		setting_type = "startup",
		default_value = false,
		order = "a-1",
	},
	{
		type = "bool-setting",
		name = "ignore-master-table-checksum",
		setting_type = "startup",
		default_value = false,
		order = "a-2",
	},
	{
		type = "bool-setting",
		name = "log-master-table",
		setting_type = "startup",
		default_value = false,
		order = "a-3",
	},]]
	{
		type = "bool-setting",
		name = "item-breakdown-recipes",
		setting_type = "startup",
		default_value = false,
		order = "a-0",
	},
	{
		type = "bool-setting",
		name = "item-breakdown-recipes-research",
		setting_type = "startup",
		default_value = false,
		order = "a-1",
	},
	{
		type = "string-setting",
		name = "item-collection-type",
		setting_type = "startup",
		default_value = "recipes",
		allowed_values =  {"items", "recipes"},
		order = "a-2",
	},
	--Logging settings
	{
		type = "bool-setting",
		name = "replication-steps-logging",
		setting_type = "startup",
		default_value = false,
		order = "b-1",
	},
	{
		type = "bool-setting",
		name = "replication-final-data-logging",
		setting_type = "startup",
		default_value = false,
		order = "b-2",
	},
	{
		type = "bool-setting",
		name = "replication-value-calculation-logging",
		setting_type = "startup",
		default_value = false,
		order = "b-3",
	},
	{
		type = "bool-setting",
		name = "replication-recipe-tech-generation-logging",
		setting_type = "startup",
		default_value = false,
		order = "b-4",
	},
	{
		type = "bool-setting",
		name = "replication-tier-calculation-logging",
		setting_type = "startup",
		default_value = false,
		order = "b-5",
	},
	{
		type = "bool-setting",
		name = "potential-bad-replication-logging",
		setting_type = "startup",
		default_value = false,
		order = "b-6",
	},
	--Replicaiton Settings
	--Settings for:
	--Whether placeable items can be replicated? Buildings and vehicles
	--
	
	{ --Whether to allow replicating science rocket launch products. This includes things like Expanded Rocket Payloads' Probe Data, that is directly used to make science
		type = "bool-setting",
		name = "science-rocket-launch-repli",
		setting_type = "startup",
		default_value = true,
		order = "c-1",
	},
	{ --Whether to allow replicating placeable rocket launch products
		type = "bool-setting",
		name = "placeables-rocket-launch-repli",
		setting_type = "startup",
		default_value = true,
		order = "c-2",
	},
	{ --Whether to allow replicating all non-science and non-placeable rocket launch products
		type = "bool-setting",
		name = "other-rocket-launch-repli",
		setting_type = "startup",
		default_value = true,
		order = "c-3",
	},
	{ --Whether to allow replicating things that require people, does nothing if no mod that adds people is active
		type = "bool-setting",
		name = "people-repli",
		setting_type = "startup",
		default_value = true,
		order = "c-5",
	},
	{ --Whether to allow replicating science packs. This setting overrides all other settings concerning science packs.
		type = "bool-setting",
		name = "science-repli",
		setting_type = "startup",
		default_value = true,
		order = "c-6",
	},
	--Liquid Matter Settings
	{ --Whether to make use liquid matter at all. Also force-disables all settings pertaining to liquid matter.
		type = "bool-setting",
		name = "liquid-matter",
		setting_type = "startup",
		default_value = true,
		order = "d-1",
	},
	{ --Whether to make Matter Converters, which can be used to turn raw resources into liquid matter, and any item if that setting is true
		type = "bool-setting",
		name = "matter-converters",
		setting_type = "startup",
		default_value = true,
		order = "d-2",
	},
	{ --Whether to make Matter Converter recipes to breakdown any item into Liquid Matter
		type = "bool-setting",
		name = "matter-converters-melting",
		setting_type = "startup",
		default_value = true,
		order = "d-3",
	},
	{ --Multiply all liquid matter values by this amount.
		name = "liquid-matter-required",
		type = "double-setting",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.01
		order = "d-5",
	},
	{ --Multiply all liquid matter generation values by this amount.
		name = "liquid-matter-generated",
		type = "double-setting",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.01
		order = "d-6",
	},
	{ --Multiply all replication liquid matter values by this amount.
		name = "liquid-matter-used",
		type = "double-setting",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.01
		order = "d-7",
	},
	--Replicator Settings
	{
		name = "replstats-speed-base",
		type = "double-setting",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.001
		order = "1-1-1",
	},
	{
		name = "replstats-speed-factor",
		type = "double-setting",
		setting_type = "startup",
		default_value = 2,
		minimum_value = 0.001
		order = "1-1-2",
	},
	{
		name = "replstats-energy-base",
		type = "double-setting",
		setting_type = "startup",
		default_value = 256,
		minimum_value = 0.001
		order = "1-2-1",
	},
	{
		name = "replstats-energy-factor",
		type = "double-setting",
		setting_type = "startup",
		default_value = 2.5,
		minimum_value = 0.001
		order = "1-2-2",
	},
	{
		name = "replstats-pollution-base",
		type = "double-setting",
		setting_type = "startup",
		default_value = 5.5,
		minimum_value = 0
		order = "1-3-1",
	},
	{
		name = "replstats-pollution-factor",
		type = "double-setting",
		setting_type = "startup",
		default_value = 2.75,
		minimum_value = 0
		order = "1-3-2",
	},
	{
		name = "replstats-modules-base",
		type = "double-setting",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0
		order = "1-5-1",
	},
	{
		name = "replstats-modules-addend",
		type = "double-setting",
		setting_type = "startup",
		default_value = 0.5
		order = "1-5-3",
	},
})