require 'mod-gui'
require 'stdlib/event/event'

Scheduler = { }

local show_scheduler_gui = settings.global["betterbots-show-scheduler-gui"].value
local n_tpt = settings.global["betterbots-scheduler-tasks-per-tick"].value

Event.register({defines.events.on_runtime_mod_setting_changed}, function(event)
    local player = game.players[event.player_index]

    show_scheduler_gui = settings.global["betterbots-show-scheduler-gui"].value
    n_tpt = settings.global["betterbots-scheduler-tasks-per-tick"].value
    
    if not show_scheduler_gui then
        local main_frame = mod_gui.get_frame_flow(player).scheduler_summary_frame
        if main_frame and main_frame.valid then main_frame.destroy() end
    end
end)

function Scheduler._draw_gui()
    if show_scheduler_gui then
        for i, player in pairs(game.connected_players) do
            local main_frame = mod_gui.get_frame_flow(player).scheduler_summary_frame
            
            if main_frame then 
                main_frame.destroy()
            end

            if not global.scheduler_queues or (#global.scheduler_queues == 0) then return end
            
            main_frame = mod_gui.get_frame_flow(player).add({ type = "frame", name = "scheduler_summary_frame", direction = "vertical" })
            main_frame.add({ type = "label", name = "scheduler_summary_label", caption = "Scheduled Actions", style = "bold_label" })
            
            for i, queue in pairs(global.scheduler_queues) do
                local queue_flow = main_frame.add({ type = "flow", name = "scheduler_queue_flow_"..i, direction = "horizontal" })
                local style = "label"
                local caption

                if type(queue.label) == "string" then
                    caption = { "", queue.label }
                else
                    caption = table.deepcopy(queue.label)
                end
                
                table.insert(caption, 2, i..") ")
                
                if i == 1 then
                    style = "caption_label"
                end

                queue_flow.add({ type = "label", name = "scheduler_summary_label_"..i, caption = caption, style = style })

                if (#queue.tasks > 5) then
                    queue_flow.add({ type = "label", name = "scheduler_summary_n_tasks_"..i, caption = #queue.tasks })
                end
            end
        end
    end
end 

function Scheduler._remove_queue(position)
    position = position or 1
    
    return table.remove(global.scheduler_queues, position)
end

function Scheduler._tick(event)
    Scheduler._draw_gui()

    if not global.scheduler_queues or (#global.scheduler_queues == 0) then return end

    if not global.scheduler_queues[1].tasks or (#global.scheduler_queues[1].tasks == 0) then
        Scheduler._remove_queue()
        return
    end

    local n_tasks = #global.scheduler_queues[1].tasks
    local tpt = n_tpt or 3

    for i = 1, tpt, 1 do
        local t = table.remove(global.scheduler_queues[1].tasks, 1)     
        if not t then break end
        local a
        
        if t.args then
            if type(t.args) == "table" then
                t.func(unpack(t.args))
            else
                t.func(t.args)
            end
        end
    end
end

function Scheduler.queue_task(f, p, in_queue)
    if not global.scheduler_queues then
        global.scheduler_queues = { }
    end

    local queue = 1
    
    if not in_queue then
        if not Scheduler._open_queue then
            Scheduler.open_queue('Other tasks')
        end
        
        queue = Scheduler._open_queue
    end
    
    table.insert(global.scheduler_queues[queue].tasks, { func = f, args = p })
end

function Scheduler.open_queue(label)
    if not global.scheduler_queues then
        global.scheduler_queues = { }
    end
    
    if Scheduler._open_queue then Scheduler.close_queue() end

    table.insert(global.scheduler_queues, { label = label, tasks = { }})
    Scheduler._open_queue = #global.scheduler_queues
end

function Scheduler.close_queue()
    if not global.scheduler_queues or not Scheduler._open_queue then return end
    
    Scheduler._open_queue = nil
end
    

Event.register({defines.events.on_tick}, Scheduler._tick)
