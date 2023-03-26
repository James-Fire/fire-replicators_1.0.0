--These are the other mod settings.  They're fairly straightforward.
data:extend({
	{
		name = "replstats-speed-base",
		type = "double-setting",
		order = "1-1-1",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.001
	}, {
		name = "replstats-speed-factor",
		type = "double-setting",
		order = "1-1-2",
		setting_type = "startup",
		default_value = 2,
		minimum_value = 0.001
	}, {
		name = "replstats-energy-base",
		type = "double-setting",
		order = "1-2-1",
		setting_type = "startup",
		default_value = 256,
		minimum_value = 0.001
	}, {
		name = "replstats-energy-factor",
		type = "double-setting",
		order = "1-2-2",
		setting_type = "startup",
		default_value = 2.5,
		minimum_value = 0.001
	}, {
		name = "replstats-pollution-base",
		type = "double-setting",
		order = "1-3-1",
		setting_type = "startup",
		default_value = 5.5,
		minimum_value = 0
	}, {
		name = "replstats-pollution-factor",
		type = "double-setting",
		order = "1-3-2",
		setting_type = "startup",
		default_value = 2.75,
		minimum_value = 0
	}, {
		name = "replstats-size-base",
		type = "double-setting",
		order = "1-4-1",
		setting_type = "startup",
		default_value = 2,
		minimum_value = 1
	}, {
		name = "replstats-size-addend",
		type = "double-setting",
		order = "1-4-3",
		setting_type = "startup",
		default_value = 0
	}, {
		name = "replstats-modules-base",
		type = "double-setting",
		order = "1-5-1",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0
	}, {
		name = "replstats-modules-addend",
		type = "double-setting",
		order = "1-5-3",
		setting_type = "startup",
		default_value = 0.5
	}, {
		name = "replresearch-item-multiplier",
		type = "double-setting",
		order = "3-1-1",
		setting_type = "startup",
		default_value = 25,
		minimum_value = 0.001
	}, {
		name = "replresearch-item-time",
		type = "double-setting",
		order = "3-1-2",
		setting_type = "startup",
		default_value = 5,
		minimum_value = 0.001
	}, {
		name = "replresearch-tier-multiplier",
		type = "double-setting",
		order = "3-2-1",
		setting_type = "startup",
		default_value = 50,
		minimum_value = 0.001
	}, {
		name = "replresearch-tier-time",
		type = "double-setting",
		order = "3-2-2",
		setting_type = "startup",
		default_value = 1,
		minimum_value = 0.001
	}, {
		name = "replication-penalty",
		type = "double-setting",
		order = "4-1",
		setting_type = "startup",
		default_value = 0.5,
		minimum_value = 0
	}, {
		name = "replication-fluid-quantity",
		type = "int-setting",
		order = "4-2",
		setting_type = "startup",
		default_value = 25,
		minimum_value = 1
	}
})