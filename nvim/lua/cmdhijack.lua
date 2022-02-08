local M = {}
local fn = vim.fn
local cmd = vim.cmd

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
                local ok, res = pcall(cmd, ('%s %s'):format(mod, raw_cmd))
                if not ok then
                    local _
                    _, _, res = res:find([[Vim%(.*%):(.*)$]])
                    vim.notify(res, vim.log.levels.ERROR)
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
            au CmdlineEnter : set nosmartcase
            au CmdlineLeave : set smartcase
        aug END
    ]])
end

init()

return M
