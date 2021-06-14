require("circuit-connector-sprites")

local roboports = { }

local pads_offsets = {
    {{-1.5, -0.5}, {1.5, -0.5}, {1.5, 1.5}, {-1.5, 1.5}, {0, 2}},
    {{-1.5, -0.5}, {1.5, -0.5}, {1.5, 1.5}, {-1.5, 1.5}, {0, 2}, {0, -1}},
    {{-1.5, -0.5}, {1.5, -0.5}, {1.5, 1.5}, {-1.5, 1.5}, {0, 2}, {0, -1}, {-2, 0.5}},
    {{-1.5, -0.5}, {1.5, -0.5}, {1.5, 1.5}, {-1.5, 1.5}, {0, 2}, {0, -1}, {-2, 0.5}, {2, 0.5}}
}

for robopads_tech = 1, 4 do
    local port = table.deepcopy(data.raw['roboport']['roboport'])

    local port_name = 'betterbots-roboport_' .. robopads_tech
    port.charging_offsets = pads_offsets[robopads_tech]
    port.charging_energy = 1000 + 200 * robopads_tech .. "kW"

    local buffer_rate = 1000 + (1000 + 200 * robopads_tech) * (robopads_tech + 4)
    port.energy_source.input_flow_limit = buffer_rate .. "kW"

    --[[

    Buffer_capacity is calculated to give 25 seconds of full energy flow to bots when disconnected from
    the power line, like vanilla roboports, but doing so results in a huge power spike when upgrading all the roboports
    together, especially on the last tier of research. I preferred to keep it disabled for this reason. Anyway, it
    should only be noticeable when there's a shortage of electricity, since the max possible drain from all charge pads
    is always less than the max energy input.

    port.energy_source.buffer_capacity = 25 * (buffer_rate - 1000) .. "kJ"

    --]]

    local energy_use = 50 * robopads_tech -- + (50 * robopads_tech * adv_robo_tech * 3)
    port.localised_name = {"entity-name.roboport"}

    port.name = port_name -- .. '_' .. adv_robo_tech
    port.energy_usage = energy_use .. "kW"
    port.placeable_by = {item = "roboport", count = 1}
    port.minable = {mining_time = 0.1, result = "roboport", count = 1}
    port.icon = "__BetterBotsWLK__/graphics/icons/roboport_" .. robopads_tech .. ".png"
    port.icon_size = 32

    table.insert(roboports, port)
end

data:extend(roboports)
