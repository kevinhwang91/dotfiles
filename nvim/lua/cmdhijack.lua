local M = {}
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api

local mods_action
local hijacked

function M.do_action()
    if vim.v.event.abort then
        return
    end

    if hijacked then
        hijacked = false
        api.nvim_echo({{'', ''}}, false, {})
        return
    end

    local raw_cmd = fn.getcmdline()
    local com_pat = raw_cmd:gsub('^%s*(%w+).*', '^%1')
    for c, mod in pairs(mods_action) do
        if c:match(com_pat) then
            cmd('let v:event.abort = v:true')
            local wrapped_cmd = (':%s %s<CR>'):format(mod, raw_cmd)
            local w_cmd = api.nvim_replace_termcodes(wrapped_cmd, true, false, true)
            api.nvim_feedkeys(w_cmd, 't', true)
            hijacked = true
            break
        end
    end
end

local function init()
    hijacked = false
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
