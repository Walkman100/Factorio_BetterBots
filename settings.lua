data:extend{
    -- Startup Settings (loaded before the prototype stage)
    --[[
    {
        type = "bool-setting",
        name = "betterbots-enable-charting-roboports",
        setting_type = "startup",
        default_value = false,
        --order = "
    },
    --]]

    -- Global settings (loaded before the control stage)
    {
        type = "bool-setting",
        name = "betterbots-show-gui",
        setting_type = "runtime-global",
        default_value = true,
        order = "a-a"
    },
    {
        type = "bool-setting",
        name = "betterbots-show-scheduler-gui",
        setting_type = "runtime-global",
        default_value = true,
        order = "b-a"
    },
    {
        type = "int-setting",
        name = "betterbots-scheduler-tasks-per-tick",
        setting_type = "runtime-global",
        default_value = 3,
        allowed_values = {1, 2, 3, 4, 5},
        order = "b-b"
    }
}
