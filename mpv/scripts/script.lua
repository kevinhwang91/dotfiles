---@diagnostic disable: undefined-global
local show_osc = true

mp.register_script_message('toggle_osc', function()
    if show_osc == true then
        mp.command('script-message osc-visibility always true')
    else
        mp.command('script-message osc-visibility auto true')
    end
    show_osc = not show_osc
end)

local shuffle = true

mp.register_script_message('toggle_shuffle', function()
    if shuffle == true then
        mp.command('playlist-shuffle')
    else
        mp.command('playlist-unshuffle')
    end
    shuffle = not shuffle
end)

mp.register_script_message('toggle_loop', function()
    local loop_file = mp.get_property('loop-file', 'no')
    local loop_playlist = mp.get_property('loop-playlist', 'no')
    if loop_file == 'no' and loop_playlist == 'no' then
        mp.set_property('loop-file', 'inf')
        mp.osd_message('Loop: current')
    elseif loop_file == 'inf' and loop_playlist == 'no' then
        mp.set_property('loop-file', 'no')
        mp.set_property('loop-playlist', 'inf')
        mp.osd_message('Loop: playlist')
    else
        mp.set_property('loop-file', 'no')
        mp.set_property('loop-playlist', 'no')
        mp.osd_message('Loop: none')
    end
end)

mp.observe_property('pause', 'bool', function(name, value)
    local _ = name
    if value == true then
        mp.command('script-message osc-visibility always true')
    else
        mp.command('script-message osc-visibility auto true')
    end
end)
