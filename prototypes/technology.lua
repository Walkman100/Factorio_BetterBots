-- ROBOPORT RELATED TECHNOLOGIES
data:extend({
    -- Advanced roboports
    {
        type = "technology",
        name = "roboport-charge-pads-1",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/roboport-charge-pads.png",
        effects = { },
        prerequisites = { 
            "logistic-robotics",
            "construction-robotics"
        },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
            },
            time = 30
        },
        upgrade = true,
        order = "c-k-f-a",
    },
    {
        type = "technology",
        name = "roboport-charge-pads-2",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/roboport-charge-pads.png",
        effects = { },
        prerequisites = { 
            "roboport-charge-pads-1"
        },
        unit = {
            count = 150,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1},
            },
            time = 30
        },
        upgrade = true,
        order = "c-k-f-b",
    },
    {
        type = "technology",
        name = "roboport-charge-pads-3",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/roboport-charge-pads.png",
        effects = { },
        prerequisites = {
            "roboport-charge-pads-2"
        },
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
            },
            time = 60
        },
        upgrade = true,
        order = "c-k-f-c",
    },
    {
        type = "technology",
        name = "roboport-charge-pads-4",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/roboport-charge-pads.png",
        effects = { },
        prerequisites = {
            "roboport-charge-pads-3"
        },
        unit = {
            count = 350,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1}
            },
            time = 60
        },
        upgrade = true,
        order = "c-k-f-d",
    },

    -- Wired Roboports
    {
        type = "technology",
        name = "wired-roboports",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/wired-roboports.png",
        effects = { },
        prerequisites = {
            "roboport-charge-pads-2",
            "electric-energy-distribution-2",
            "modules"
        },
        unit =
        {
            count = 250,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
            },
            time = 30
        },
        --upgrade = true,
        order = "c-k-f-e",
    },
    {
        type = "technology",
        name = "roboport-power-field",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/wired-roboports.png",
        effects = { },
        prerequisites = {
            "wired-roboports",
        },
        unit =
        {
            count = 450,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1}
            },
            time = 30
        },
        --upgrade = true,
        order = "c-k-f-f",
    },
    
    -- Roboport Sensor Array
    {
        type = "technology",
        name = "charting-roboports-1",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/charting-roboports.png",
        effects = { },
        prerequisites = {
            "roboport-charge-pads-1",
            --"electric-energy-distribution-2",
            "modules"
        },
        unit =
        {
            count = 200,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
            },
          time = 30
        },
        upgrade = true,
        order = "c-k-f-g",
    },
    {
        type = "technology",
        name = "charting-roboports-2",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/charting-roboports.png",
        effects = { },
        prerequisites = {
            "charting-roboports-1",
            "roboport-charge-pads-4"
        },
        unit =
        {
            count = 500,
            ingredients =
            {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1}
            },
          time = 30
        },
        upgrade = true,
        order = "c-k-f-h",
    }
})

-- BOTS RELATED TECHNOLOGIES
data:extend({  
    -- Worker Robot Power Cells
    {
        type = "technology",
        name = "worker-robots-battery-1",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/worker-robots-battery.png",
        effects = {
            { type = "worker-robot-battery", modifier = 0.15 }
        },
        prerequisites = { "robotics" },
        unit = {
            count = 50,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        },
        upgrade = true,
        order = "c-k-f-a",
    },
    {
        type = "technology",
        name = "worker-robots-battery-2",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/worker-robots-battery.png",
        effects = {
            { type = "worker-robot-battery", modifier = 0.2 }
        },
        prerequisites = { "worker-robots-battery-1" },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        },
        upgrade = true,
        order = "c-k-f-b"
    },
    {
        type = "technology",
        name = "worker-robots-battery-3",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/worker-robots-battery.png",
        effects = {
            { type = "worker-robot-battery", modifier = 0.25 }
        },
        prerequisites = { "worker-robots-battery-2" },
        unit = {
            count = 150,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 60
        },
        upgrade = true,
        order = "c-k-f-c"
    },
    {
        type = "technology",
        name = "worker-robots-battery-4",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/worker-robots-battery.png",
        effects = {
            { type = "worker-robot-battery", modifier = 0.35 }
        },
        prerequisites = {"worker-robots-battery-3"},
        unit = {
            count = 250,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 60
        },
        upgrade = true,
        order = "c-k-f-d"
    },
    {
        type = "technology",
        name = "worker-robots-battery-5",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/worker-robots-battery.png",
        effects = {
            { type = "worker-robot-battery", modifier = 0.35 }
        },
        prerequisites = {"worker-robots-battery-4"},
        unit = {
            count = 500,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 60
        },
        upgrade = true,
        order = "c-k-f-e"
    },
    {
        type = "technology",
        name = "worker-robots-battery-6",
        icon_size = 128,
        icon = "__BetterBots__/graphics/technology/worker-robots-battery.png",
        effects = {
            { type = "worker-robot-battery", modifier = 0.45 }
        },
        prerequisites = {"worker-robots-battery-5"},
        unit = {
            count_formula = "2^(L-6)*1000",
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"space-science-pack", 1}
            },
            time = 60
        },
        max_level = "infinite",
        upgrade = true,
        order = "c-k-f-e"
    },
})
