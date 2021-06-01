local M = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local git = require('gittool')

function _G.qftf(info)
    local items
    local ret = {}
    git.cd_root(fn.bufname('#'), true)
    if info.quickfix == 1 then
        items = fn.getqflist({id = info.id, items = 0}).items
    else
        items = fn.getloclist(info.winid, {id = info.id, items = 0}).items
    end
    local limit = 27
    local fname_fmt1, fname_fmt2 = '%-' .. limit .. 's', '…%.' .. (limit - 1) .. 's'
    local valid_fmt, unvalid_fmt = '%s |%5d:%-3d|%s %s', '%s'
    for i = info.start_idx, info.end_idx do
        local e = items[i]
        local fname = ''
        local str
        if e.valid == 1 then
            if e.bufnr > 0 then
                fname = fn.bufname(e.bufnr)
                if fname == '' then
                    fname = '[No Name]'
                else
                    fname = fname:gsub('^' .. vim.env.HOME, '~')
                end
                if fn.strwidth(fname) <= limit then
                    fname = fname_fmt1:format(fname)
                else
                    fname = fname_fmt2:format(fname:sub(1 - limit))
                end
            end
            local lnum = e.lnum > 99999 and -1 or e.lnum
            local col = e.col > 999 and -1 or e.col
            local qtype = e.type == '' and '' or ' ' .. e.type:sub(1, 1):upper()
            str = valid_fmt:format(fname, lnum, col, qtype, e.text)
        else
            str = unvalid_fmt:format(e.text)
        end
        table.insert(ret, str)
    end
    return ret
end

local function setup()
    vim.g.qf_disable_statusline = true
    vim.o.qftf = 'v:lua._G.qftf'
end

function M.close()
    local loc_winid = fn.getloclist(0, {winid = 0}).winid
    if loc_winid == 0 then
        cmd('ccl')
    else
        local qf_winid = fn.getqflist({winid = 0}).winid
        if qf_winid == 0 then
            cmd('lcl')
        else
            local prompt = ' ( [q]uickfix,[l]ocation )? '
            local bufnr = api.nvim_create_buf(false, true)
            api.nvim_open_win(bufnr, false, {
                relative = 'cursor',
                width = #prompt,
                height = 1,
                row = 1,
                col = 1,
                style = 'minimal',
                border = 'single'
            })
            api.nvim_buf_set_lines(bufnr, 0, 1, false, {prompt})
            vim.schedule(function()
                local char = fn.getchar()
                if type(char) == 'number' then
                    char = fn.nr2char(char)
                    if char == 'q' then
                        cmd('ccl')
                    elseif char == 'l' then
                        cmd('lcl')
                    end
                end
                cmd(('noa bw %d'):format(bufnr))
            end)
        end
    end
end

function M.detect_bt()
    if vim.v.option_new == 'quickfix' then
        git.cd_root(fn.bufname('#'), true)
    end
end

setup()

return M
