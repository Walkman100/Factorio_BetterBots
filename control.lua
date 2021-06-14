require 'stdlib/game'
require 'stdlib/event/event'
require 'stdlib/string'
require 'stdlib/table'
require 'stdlib/entity/entity'
local mod_gui = require 'mod-gui'
require 'scheduler'

require 'migrations'

local show_gui = settings.global["betterbots-show-gui"].value

function create_flow_button(player)
    if (show_gui) then
        if mod_gui.get_button_flow(player).betterbots_top_btn then
            return
        end

        mod_gui.get_button_flow(player).add{
            type = "sprite-button",
            name = "betterbots_top_btn",
            sprite = "item/roboport",
            style = mod_gui.button_style
        }
    elseif mod_gui.get_button_flow(player).betterbots_top_btn then
        mod_gui.get_button_flow(player).betterbots_top_btn.destroy()
    end
end

Event.register(
    {Event.core_events.init},
    function(event)
        for _, player in pairs(game.players) do
            create_flow_button(player)
        end
    end
)

Event.register(
    {Event.core_events.configuration_changed},
    function(event)
        for _, player in pairs(game.players) do
            create_flow_button(player)
        end
    end
)

Event.register(
    {defines.events.on_player_created},
    function(event)
        local player = game.players[event.player_index]

        for _, player in pairs(game.players) do
            create_flow_button(player)
        end
    end
)

Event.register(
    {defines.events.on_runtime_mod_setting_changed},
    function(event)
        local player = game.players[event.player_index]
        show_gui = settings.global["betterbots-show-gui"].value
        create_flow_button(player)
    end
)

Event.register(
    {defines.events.on_gui_click},
    function(event)
        local gui = event.element
        local player = game.players[event.player_index]
        if not (player and player.valid and gui and gui.valid) then return end

        if gui.name == "betterbots_top_btn" then
            if mod_gui.get_frame_flow(player).betterbots_left then
                mod_gui.get_frame_flow(player).betterbots_left.destroy()
            else
                local main_frame = mod_gui.get_frame_flow(player).add{
                    type = "frame",
                    name = "betterbots_left",
                    direction = "vertical"
                }
                main_frame.add({
                    type = "label",
                    name = "betterbots_left_label",
                    caption = {"betterbots-gui.left_label"},
                    style = "caption_label"
                })
                main_frame.add{
                    type = "button",
                    name = "betterbots_reset_btn",
                    caption = {"betterbots-gui.reset_btn"},
                    direction = "horizontal"
                }
                main_frame.add{
                    type = "label",
                    name = "betterbots_left_label_2",
                    caption = {"betterbots-gui.left_label_2"}
                }
                main_frame.add{
                    type = "label",
                    name = "betterbots_left_label_3",
                    caption = {"betterbots-gui.left_label_3"}
                }
            end
        elseif gui.name == "betterbots_reset_btn" then
            if player.gui.center.betterbots_confirm_box then
                player.gui.center.betterbots_confirm_box.destroy()
                return
            end

            local main_frame = player.gui.center.add{
                type = "frame",
                name = "betterbots_confirm_box",
                direction = "vertical"
            }
            main_frame.add{
                type = "label",
                name = "betterbots_confirm_label",
                caption = {"betterbots-gui.confirm_label"},
                style = "caption_label"
            }
            main_frame.add{
                type = "label",
                name = "betterbots_confirm_notes",
                caption = {"betterbots-gui.confirm_notes"}
            }

            local confirm_flow = main_frame.add{
                type = "flow",
                name = "betterbots_confirm_btn_flow",
                direction = "horizontal"
            }
            confirm_flow.add{
                type = "button",
                name = "betterbots_confirm_yes_btn",
                caption = {"betterbots-gui.confirm_yes_btn"}
            }
            confirm_flow.add{
                type = "button",
                name = "betterbots_confirm_no_btn",
                caption = {"betterbots-gui.confirm_no_btn"}
            }

            -- Register this frame as GUI so it will be closed by usual GUI close controls
            player.opened = main_frame
        elseif gui.name == "betterbots_confirm_yes_btn" then
            local techs = player.force.technologies

            if player.gui.center.betterbots_confirm_box then
                player.gui.center.betterbots_confirm_box.destroy()
            end

            if mod_gui.get_frame_flow(player).betterbots_left then
                mod_gui.get_frame_flow(player).betterbots_left.destroy()
            end

            local techs = player.force.technologies

            for i = 4, 1, -1 do
                techs['roboport-charge-pads'..'-'..i].researched = false
            end

            for i = 2, 1, -1 do
                techs['charting-roboports-'..i].researched = false
            end

            Scheduler.open_queue({"betterbots-gui.reset_roboports_queue"})
            Scheduler.queue_task(set_roboports_charting_range, 0)
            Scheduler.queue_task(reset_roboports, {player, calculate_betterbots_tech_levels(player.force)})
            Scheduler.close_queue()

            Scheduler.open_queue({"betterbots-gui.remove_betterbots_entities"})
            Scheduler.queue_task(remove_bb_entities, {player})
            Scheduler.close_queue()

            Scheduler.open_queue({"betterbots-gui.verify_roboports_queue"})
            Scheduler.queue_task(validate_reset, {player})
            Scheduler.close_queue()
        elseif gui.name == "betterbots_confirm_no_btn" then
            if player.gui.center.betterbots_confirm_box then
                player.gui.center.betterbots_confirm_box.destroy()
            end

            if mod_gui.get_frame_flow(player).betterbots_left then
                mod_gui.get_frame_flow(player).betterbots_left.destroy()
            end
        end
        return
    end
)

script.on_event(
    defines.events.on_gui_closed,
    function(event)
        if event.gui_type == defines.gui_type.custom and event.element and event.element.name == "betterbots_confirm_box" then
            event.element.destroy()
        end
    end
)

function set_roboports_charting_range(tech_level)
    if not tech_level then return end

    global.charting_ports = { }

    table.each(game.surfaces,
        function(surface)
            local ports = surface.find_entities_filtered({type = 'roboport'})

            table.each(ports,
                function(port)
                    if not port.valid then return end

                    if port.name:starts_with("betterbots-roboport") then
                        local port_data = Entity.get_data(port) or { }

                        if tech_level > 0 then
                            if tech_level == 1 then
                                port_data.charting_range = 25
                            elseif tech_level == 2 then
                                port_data.charting_range = 55
                            end

                            table.insert(global.charting_ports, port)
                        else
                            port_data.charting_range = nil
                        end

                        Entity.set_data(port, port_data)
                    end
                end
            )
        end
    )
end

-- Charting code
-- Each second: chart a slice of the charting_ports table to reduce the performance hit of doing it all in one go
-- Every 5 seconds: sanitize check charting_ports array by removing invalid entries and queueing newly added ones
script.on_nth_tick(60,
    function(n)
        if not global.charting_ports then return end

        local tick = n.tick
        local nth_tick = n.nth_tick
        local slice = (tick % 300) / 60

        if slice == 0 then -- 5 seconds
            global.charting_ports = table.filter(global.charting_ports, Game.VALID_FILTER)
            global.slice_size = #global.charting_ports / 5
        end

        if global.slice_size and global.slice_size > 0 then
            local start_i = math.floor((slice * global.slice_size) + 0.5) + 1
            local end_i = math.floor(((slice+1) * global.slice_size) + 0.5)

            for i = start_i, end_i, 1 do
                local e = global.charting_ports[i]
                if e and e.valid then
                    local port_data = Entity.get_data(e)

                    if (port_data and port_data.charting_range and port_data.charting_range > 0) then
                        e.force.chart(e.surface, Position.expand_to_area(e.position, port_data.charting_range))
                    end
                end
            end
        end
    end
)

Event.register(
    {defines.events.on_player_setup_blueprint, defines.events.on_player_configured_blueprint},
    function(event)
        local player = game.players[event.player_index]
        if not player.valid then return end

        local stack = player.blueprint_to_setup
        if not stack.valid or not stack.valid_for_read then
            stack = player.cursor_stack
            if not stack.valid or not stack.valid_for_read then
                return
            end
        end

        if stack.name ~= "blueprint" then return end

        local entities = stack.get_blueprint_entities()
        if not entities then return end

        local modified = false
        for _, entity in pairs (entities) do
            if entity.name:starts_with('betterbots-roboport') then
                entity.name = 'roboport'
                entity.type = 'roboport'
                modified = true
            end
        end

        if modified then
            stack.set_blueprint_entities(entities)
        end
    end
)

Event.register(
    defines.events.on_research_finished,
    function(event)
        local tech_name = event.research.name
        local force = event.research.force

        if tech_name:starts_with('roboport-charge-pads') then
            Scheduler.open_queue({"", {"betterbots-gui.upgrade_roboports_queue"}, " (", event.research.localised_name, ")"})
            Scheduler.queue_task(upgrade_roboports, {force, calculate_betterbots_tech_levels(force)})
            Scheduler.close_queue()
        elseif tech_name:starts_with('charting-roboports') then
            Scheduler.open_queue({"betterbots-gui.charting_roboports_queue"})
            Scheduler.queue_task(set_roboports_charting_range, calculate_betterbots_tech_levels(force).charting_tech_level)
            Scheduler.close_queue()
        end
    end
)

-- ON_TICK event handler
--
-- 1) Manages all modified blueprints swapping any betterbots roboport with vanilla ones
-- 2) Calls player.pipette_entity("roboport") on the player in global.pipette_roboports (second half of the "manually place a roboport over betterbots ghost" procedure)
Event.register(
    {defines.events.on_tick},
    function(event)
        if (not global.modified_bps or #global.modified_bps == 0) and (not global.pipette_roboports) then return end

        -- 1)
        table.each(global.modified_bps,
            function(stack)
                if stack.is_blueprint then
                    local has_ports = false
                    local bp_ent = stack.get_blueprint_entities()

                    for _, ent in pairs (bp_ent) do
                        if ent.name:starts_with("betterbots-roboport") then
                            ent.name = "roboport"
                            has_ports = true
                        end
                    end

                    if has_ports then
                        stack.set_blueprint_entities(bp_ent)
                    end
                end
            end
        )

        -- 2)
        if global.pipette_roboports then
            global.pipette_roboports.pipette_entity("roboport")
        end

        global.modified_bps = { }
        global.pipette_roboports = nil
    end
)

Event.register(
    {defines.events.on_put_item},
    function(event)
        local player = game.get_player(event.player_index)
        local techs = calculate_betterbots_tech_levels(player.force)
        local stack = player.cursor_stack

        if techs.chargepads_tech_level > 0 and stack and stack.valid and stack.valid_for_read and stack.name == "roboport" then
            local e_x = event.position.x
            local e_y = event.position.y

            local ghosts = player.surface.find_entities_filtered({
                ghost_type = 'roboport',
                area = {
                    {e_x - 2, e_y - 2},
                    {e_x + 2, e_y + 2}
                }
            })
            local curs_stack = player.cursor_stack

            table.each(ghosts,
                function(port)
                    if port.ghost_name:starts_with("betterbots-roboport") and (port.position.x == e_x) and (port.position.y == e_y) then
                        curs_stack.count = curs_stack.count - 1

                        player.clean_cursor()
                        port.revive()

                        local newPort = player.surface.find_entities_filtered({type = 'roboport', position = event.position})[1]

                        if not newPort then
                            game.print("Error: not newPort in on_put_item. Please report this on the mod Discussion Board")
                        end

                        manage_port_data(newPort, techs)

                        global.pipette_roboports = player
                    end
                end
            )
        elseif stack and stack.valid and (stack.is_blueprint_book or stack.is_blueprint) then
            local cp_level = techs.chargepads_tech_level
            local bp = stack

            if stack.is_blueprint_book then
                bp = stack.get_inventory(defines.inventory.item_main)[stack.active_index]
            end

            if cp_level > 0 then
                local has_ports = false

                local bp_ent = bp.get_blueprint_entities()

                if bp_ent then
                    if not global.modified_bps then
                        global.modified_bps = { }
                    end

                    for _, ent in pairs (bp_ent) do
                        if ent.name == "roboport" then
                            ent.name = "betterbots-roboport_" .. cp_level
                            has_ports = true
                        end
                    end

                    if has_ports then
                        bp.set_blueprint_entities(bp_ent)
                        table.insert(global.modified_bps, bp)
                    end
                end
            end
        end
    end
)

Event.register(
    {defines.events.on_built_entity, defines.events.on_robot_built_entity},
    function(event)
        local entity = event.created_entity
        local type = entity.type
        local name = entity.name

        local techs = calculate_betterbots_tech_levels(entity.force)
        local chargepads_tech_level = techs.chargepads_tech_level

        if type == 'roboport' and name == 'roboport' then
            if chargepads_tech_level > 0 then
                -- I'd rather have this one be instant... messy, but hopefully it's for the best
                -- Scheduler.queue_task(upgrade_roboport_entity, { entity, techs })
                upgrade_roboport_entity(entity, techs)
            end
        end

        -- MANAGE DUMMY ENTITIES WHEN PLACED VIA ROBOT OVER A GHOSTED betterbots-roboport
        if name:starts_with('betterbots-roboport') then
            manage_port_data(entity, techs)
        end
    end
)

Event.register(
    {defines.events.on_entity_died, defines.events.on_robot_pre_mined, defines.events.on_player_mined_entity},
    function(event)
        local entity = event.entity
        local type = entity.type
        local name = entity.name

        if type == 'roboport' and name:starts_with('betterbots-roboport') then
            local port_data = Entity.set_data(entity, nil)

            if port_data and port_data.dummy_entities then
                table.each(port_data.dummy_entities,
                    function(ent)
                        if ent.valid then ent.destroy() end
                    end
                )
            end
        end
    end
)

function manage_port_data(port, techs)
    if not port or not port.valid then return nil end
    if not techs then return nil end

    local chargepads_tech_level = techs.chargepads_tech_level
    local charting_tech_level = techs.charting_tech_level

    local surface = port.surface
    local force = port.force
    local pos = port.position
    local port_data = Entity.get_data(port)

    if not port_data then
        port_data =  { }
    end

    if not port_data.dummy_entities then
        port_data.dummy_entities = { }
    end

    --[[ if not (port_data.dummy_entities.blueprint_roboport and port_data.dummy_entities.blueprint_roboport.valid) then
        local bp_port = surface.create_entity({ name = 'betterbots-blueprint-roboport', position = pos, force = force })

        Entity.set_frozen(bp_port)
        Entity.set_indestructible(bp_port)
        port_data.dummy_entities.blueprint_roboport = bp_port
    end ]]

    if charting_tech_level > 0 then
        if charting_tech_level == 1 then
            port_data.charting_range = 25
        elseif charting_tech_level == 2 then
            port_data.charting_range = 55
        end

        if not global.charting_ports then
            global.charting_ports = { }
        end

        table.insert(global.charting_ports, port)
    end

    Entity.set_data(port, port_data)

    return port_data
end

-- This is where all the magic happens!
function upgrade_roboport_entity(port, techs)
    if not port or not port.valid then return end

    local chargepads_tech_level = techs.chargepads_tech_level
    local charting_tech_level = techs.charting_tech_level

    local pos = port.position
    local health = port.health
    local dir = port.direction

    local backerName = port.backer_name

    local energy = port.energy
    local surface = port.surface
    local force = port.force
    local port_data = Entity.get_data(port)
    local port_name = 'roboport'

    -- Circuit Network related stuff
    local circuit_network = port.circuit_connection_definitions

    -- The control behavior must be treated like this
    local c_be = port.get_or_create_control_behavior()
    local previous_control_behavior = {
        -- mode_of_operations = c_be.mode_of_operations,
        read_logistics = c_be.read_logistics,
        read_robot_stats = c_be.read_robot_stats,
        available_logistic_output_signal = c_be.available_logistic_output_signal,
        total_logistic_output_signal = c_be.total_logistic_output_signal,
        available_construction_output_signal = c_be.available_construction_output_signal,
        total_construction_output_signal = c_be.total_construction_output_signal,
    }

    if chargepads_tech_level > 0 then
        if not port_data then
            port_data =  { }
        end

        if not port_data.dummy_entities then
            port_data.dummy_entities = { }
        end

        if charting_tech_level == 1 then
            port_data.charting_range = 25
        elseif charting_tech_level == 2 then
            port_data.charting_range = 55
        else
            port_data.charting_range = nil
        end

        port_name = 'betterbots-roboport_' .. chargepads_tech_level
    else
        if port.name == 'roboport' then return end

        if port_data and port_data.dummy_entities then
            table.each(port_data.dummy_entities,
                function(ent)
                    if ent.valid then ent.destroy() end
                end
            )
        end

        port_name = 'roboport'
        port_data = nil
    end

    local newPort = surface.create_entity({
        name = port_name,
        position = pos,
        force = force,
        direction = dir,
        create_build_effect_smoke = false
    })

    newPort.health = health
    newPort.energy = energy
    newPort.backer_name = backerName

    if port_data then
        Entity.set_data(newPort, port_data)
    end

    if (port.get_inventory(1) and port.get_inventory(1).valid) then
        for i = 1, #port.get_inventory(1), 1 do
            newPort.get_inventory(1)[i].set_stack(port.get_inventory(1)[i])
        end
    end

    if (port.get_inventory(2) and port.get_inventory(2).valid) then
        for i = 1, #port.get_inventory(2), 1 do
            newPort.get_inventory(2)[i].set_stack(port.get_inventory(2)[i])
        end
    end

    local n_be = newPort.get_or_create_control_behavior()

    for k, v in pairs(previous_control_behavior) do
        n_be[k] = v
    end

    for _, cc in pairs(circuit_network) do
        newPort.connect_neighbour(cc)
    end

    if charting_tech_level > 0 then
        table.insert(global.charting_ports, newPort)
    end

    port.destroy()
end

-- Upgrade a betterbots-roboport ghost to the correct entity tier, or vanilla if unable
function upgrade_ghost_roboport(port, techs)
    -- TO DO: Try to create the correct ghost if possible preserving all properties
    --        like circuit connections and control behaviour (most prob impossible)
    -- CURRENTLY creates a vanilla roboport ghost over any betterbots-roboport ghost
    if not port or not port.valid or not port.ghost_type == "roboport" then return end

    local c_be = port.get_or_create_control_behavior()
    local previous_control_behavior = {
        -- mode_of_operations = c_be.mode_of_operations,
        read_logistics = c_be.read_logistics,
        read_robot_stats = c_be.read_robot_stats,
        available_logistic_output_signal = c_be.available_logistic_output_signal,
        total_logistic_output_signal = c_be.total_logistic_output_signal,
        available_construction_output_signal = c_be.available_construction_output_signal,
        total_construction_output_signal = c_be.total_construction_output_signal,
    }

    local pos = port.position
    local dir = port.direction
    local backerName = port.backer_name

    local surface = port.surface
    local force = port.force

    local newPort = surface.create_entity({
        name = "entity-ghost",
        position = pos,
        force = force,
        direction = dir,
        create_build_effect_smoke = false,
        ghost_type = "roboport",
        ghost_name = "roboport"
    })

    local n_be = newPort.get_or_create_control_behavior()

    for k, v in pairs(previous_control_behavior) do
        n_be[k] = v
    end

    newPort.backer_name = backerName

    port.destroy()
end

function upgrade_roboports(force, techs)
    if not techs then
        techs = calculate_betterbots_tech_levels(force)
    end

    table.each(game.surfaces,
        function(surface)
            local ports = surface.find_entities_filtered({type = 'roboport'})
            local ghosts = surface.find_entities_filtered({ghost_type = 'roboport'})

            table.each(ports,
                function(port)
                    if not port.valid then return end
                    -- The search below *should* exclude any non-vanilla non-betterbots entity with type='roboport'
                    if port.name:starts_with("betterbots-roboport") or port.name == 'roboport' then
                        Scheduler.queue_task(upgrade_roboport_entity, {port, techs}, true)
                    end
                end
            )

            table.each(ghosts,
                function(ghost)
                    if not ghost.valid then return end

                    if ghost.ghost_name:starts_with("betterbots-roboport") then
                        Scheduler.queue_task(upgrade_ghost_roboport, {ghost, techs}, true)
                    end
                end
            )
        end
    )
end

function reset_roboports(player, techs)
    local force = player.force
    if not techs then
        techs = calculate_betterbots_tech_levels(force)
    end

    Scheduler.queue_task(upgrade_roboports, {force, techs}, true)
end

function remove_bb_entities(player)
    local force = player.force

    table.each(game.surfaces,
        function(surface)
            local dummy_poles = surface.find_entities_filtered({
                name = {"betterbots-dummy-pole", "betterbots-powering-pole"}
            })

            table.each(dummy_poles,
                function(pole)
                    pole.destroy()
                end
            )
        end
    )
end

function validate_reset(player)
    local validation = 0

    table.each(game.surfaces,
        function(surface)
            local ports = surface.find_entities_filtered({type = 'roboport'})
            local dummy_poles = surface.find_entities_filtered({
                name = {"betterbots-dummy-pole", "betterbots-powering-pole"}
            })

            table.each(ports,
                function(port)
                    if port.valid and port.name:starts_with("betterbots-roboport") then
                        validation = validation + 1
                    end
                end
            )

            validation = validation + #dummy_poles
        end
    )

    if validation == 0 then
        player.print{"betterbots-gui.reset_succesful"}
    else
        player.print{"betterbots-gui.reset_error", validation}
    end
end

function calculate_tech_level(force, tech_name, max_levels)
    local techs = force.technologies

    if max_levels == 1 and techs[tech_name] and techs[tech_name].researched then
        return 1
    else
        for i = max_levels, 1, -1 do
            if techs[tech_name..'-'..i] and techs[tech_name..'-'..i].researched then
                return i
            end
        end
    end

    return 0
end

function calculate_betterbots_tech_levels(force)
    return {
        chargepads_tech_level = calculate_tech_level(force, 'roboport-charge-pads', 4),
        charting_tech_level = calculate_tech_level(force, 'charting-roboports', 2)
    }
end
