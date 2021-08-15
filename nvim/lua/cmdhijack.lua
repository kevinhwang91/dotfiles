local M = {}
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api

local mods_action

function M.do_action()
    if vim.v.event.abort then
        return
    end

    local raw_cmd = fn.getcmdline()
    local com_pat = raw_cmd:gsub('^%s*(%w+).*', '^%1')
    for c, mod in pairs(mods_action) do
        if c:match(com_pat) then
            cmd('let v:event.abort = v:true')
            vim.schedule(function()
                local ok, msg = pcall(cmd, ('%s %s'):format(mod, raw_cmd))
                if not ok then
                    _, _, msg = msg:find([[Vim%(.*%):(.*)$]])
                    api.nvim_err_writeln(msg)
                end
            end)
            break
        end
    end
end

local function init()
    mods_action = {
        ['Man'] = 'tab',
        ['cwindow'] = 'bo',
        ['copen'] = 'bo',
        ['lwindow'] = 'abo',
        ['lopen'] = 'abo'
    }
    cmd([[
        aug CmdHijack
            au!
            au CmdlineLeave : lua require('cmdhijack').do_action()
        aug END
    ]])
end

init()

return M
