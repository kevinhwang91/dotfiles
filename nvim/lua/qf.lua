local M = {}
local cmd = vim.cmd
local fn = vim.fn

local git = require('gittool')

local function render(items, i)
    local e = items[i]
    local fname = ''
    if e.bufnr > 0 then
        fname = fn.bufname(e.bufnr)
        if fname == '' then
            fname = '[No Name]'
        end
        if fn.strwidth(fname) <= 25 then
            fname = ('%-25s'):format(fname)
        else
            fname = ('…%.24s'):format(fname:sub(-24, -1))
        end
    end
    local lnum = e.lnum > 99999 and 'inf' or e.lnum
    local col = e.col > 999 and 'inf' or e.col
    local qtype = e.type:sub(1, 1):upper()
    return ('%s |%s%5d:%-3d| %s'):format(fname, qtype, lnum, col, e.text)
end

local function setup()
    vim.g.qf_disable_statusline = true
    if pcall(function()
        -- qftf is porting from upstream
        -- error()
        vim.o.qftf = 'v:lua._G.qftf'
    end) then
        function _G.qftf(info)
            local items
            local ret = {}
            git.cd_root(fn.bufname('#'), true)
            if info.quickfix == 1 then
                items = fn.getqflist({id = info.id, items = 0}).items
            else
                items = fn.getloclist(info.winid, {id = info.id, items = 0}).items
            end
            for i = info.start_idx, info.end_idx do
                table.insert(ret, render(items, i))
            end
            return ret
        end
    else
        cmd([[
        aug QuickFix
            au!
            au OptionSet buftype lua require('qf').detect_bt()
        aug END
        ]])
    end
end

function M.detect_bt()
    if vim.v.option_new == 'quickfix' then
        git.cd_root(fn.bufname('#'), true)
    end
end

setup()

return M
