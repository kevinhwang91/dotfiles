local show_osc = true
function toggle_osc()
    if show_osc == true then
        mp.command('script-message osc-visibility always true')
    else
        mp.command('script-message osc-visibility auto true')
    end
    show_osc = not show_osc
end

mp.register_script_message('toggle_osc', toggle_osc)

local shuffle = true
function toggle_shuffle()
    if shuffle == true then
        mp.command('playlist-shuffle')
    else
        mp.command('playlist-unshuffle')
    end
    shuffle = not shuffle
end

mp.register_script_message('toggle_shuffle', toggle_shuffle)

function toggle_loop()
    local loop_file = mp.get_property('loop-file', 'no')
    local loop_playlist = mp.get_property('loop-playlist', 'no')
    if loop_file == 'no' and loop_playlist == 'no' then
        mp.set_property('loop-file', 'yes')
        mp.osd_message('Loop: current')
    elseif loop_file == 'yes' and loop_playlist == 'no' then
        mp.set_property('loop-file', 'no')
        mp.set_property('loop-playlist', 'yes')
        mp.osd_message('Loop: playlist')
    else
        mp.set_property('loop-file', 'no')
        mp.set_property('loop-playlist', 'no')
        mp.osd_message('Loop: none')
    end
end

mp.register_script_message('toggle_loop', toggle_loop)

function on_playlist_change(name, value)
    mp.command('script-message osc-playlist 3')
end

mp.observe_property('playlist', nil, on_playlist_change)

function on_pause_change(name, value)
    if value == true then
        mp.command('script-message osc-visibility always true')
    else
        mp.command('script-message osc-visibility auto true')
    end
end

mp.observe_property('pause', 'bool', on_pause_change)
