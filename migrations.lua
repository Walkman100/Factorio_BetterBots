--[[
This is a dirty way to track migrations, because the global table is not available during the migration
scripts stage, so I can't access the entity data if I have to...

From the API:
on_configuration_changed:
Register a function to be run when mod configuration changes. This is called any time the game
version changes, prototypes change, startup mod settings change, and any time mod versions change
including adding or removing mods.
--]]
Event.register({Event.core_events.init, Event.core_events.configuration_changed}, function(event)
    if not global._migrations then 
        global._migrations = { }
    end
    
    -- 1.0.3 to 1.1.0
    if global._migrations and not global._migrations.migrated_dummy_bps then
        game.print("BetterBots - migrating 1.0.3 to 1.1.0")
        global._migrations.migrated_dummy_bps = true

        for _, surface in pairs(game.surfaces) do
            local ports = surface.find_entities_filtered({type = 'roboport'})

            for _, port in pairs(ports) do
                if port.name:starts_with("betterbots-roboport") then
                    local port_data = Entity.get_data(port)
                    
                    if port_data and port_data.blueprint_roboport then
                        local bp_port = port_data.blueprint_roboport

                        if not port_data.dummy_entities then port_data.dummy_entities = { } end
                        if port_data.dummy_entities.blueprint_roboport and port_data.dummy_entities.blueprint_roboport.valid and not Entity._are_equal(port_data.blueprint_roboport, port_data.dummy_entities.blueprint_roboport) then
                            port_data.dummy_entities.blueprint_roboport.destroy()
                        end

                        port_data.dummy_entities.blueprint_roboport = bp_port
                        port_data.blueprint_roboport = nil
                        
                        Entity.set_data(port, port_data)
                    end
                end
            end
        end
    end
    
    -- 1.2.0 to 1.3.0
    if global._migrations and not global._migrations.migrated_charting_code then
        game.print("BetterBots - migrating 1.2.0 to 1.3.0")
        global._migrations.migrated_charting_code = true
        
        global.charting_ports = { }
        
        table.each(game.surfaces, function(surface)
            local ports = surface.find_entities_filtered({type = 'roboport'})

            table.each(ports, function(port)
                if not port.valid then return end

                if port.name:starts_with("betterbots-roboport") then
                    local port_data = Entity.get_data(port) or { }
                    
                    if port_data and port_data.charting_range and port_data.charting_range > 0 then
                        table.insert(global.charting_ports, port)
                    end
                end
            end)
        end)
    end
    
    -- 1.3.0 to 1.3.1
    if global._migrations and not global._migrations.migrated_dummy_blueprint_roboport then
        game.print("Betterbots - migrating 1.3.0 to 1.3.1 - Dummy blueprintable entities destroyed")
        
        global._migrations.migrated_dummy_blueprint_roboport = true
    end
end)
