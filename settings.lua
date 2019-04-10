data:extend{
  {
		type = "bool-setting",
		name = "railborders-place-poles",
		setting_type = "runtime-global",
		default_value = true,
		order = "railborders-1-place-poles",
	},
  {
		type = "string-setting",
		name = "railborders-pole-wires",
		setting_type = "runtime-global",
		default_value = "both",
    allowed_values = {"none", "red", "green", "both"},
		order = "railborders-2-pole-wires",
	}

}
