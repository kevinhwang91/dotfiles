local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local utils = require('kutils')

function M.prefix_timeout(prefix)
    local char = fn.getcharstr(0)
    return char == '' and utils.termcodes['<Ignore>'] or prefix .. char
end

-- once
function M.wipe_empty_buf()
    local bufnr = api.nvim_get_current_buf()
    vim.schedule(function()
        M.wipe_empty_buf = nil
        if api.nvim_buf_is_valid(bufnr) and api.nvim_buf_get_name(bufnr) == '' and
            not vim.bo[bufnr].modified and api.nvim_buf_get_offset(bufnr, 1) <= 0 then
            pcall(api.nvim_buf_delete, bufnr, {})
        end
    end)
end

function M.jump0()
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    local line = api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1]
    local expr
    if line:sub(1, col):match('^%s+$') then
        expr = '0'
    else
        api.nvim_buf_set_mark(0, '`', lnum, col, {})
        expr = '^'
    end
    return expr
end

function M.jumps2qf()
    local locs, pos = unpack(fn.getjumplist())
    local items, idx = {}, 1
    for i = #locs, 1, -1 do
        local loc = locs[i]
        local bufnr, lnum, col = loc.bufnr, loc.lnum, loc.col + 1
        if api.nvim_buf_is_valid(bufnr) then
            local text = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
            text = text and text:match('%C*') or '......'
            table.insert(items, {bufnr = bufnr, lnum = lnum, col = col, text = text})
        end
        if pos + 1 == i then
            idx = #items
        end
    end

    fn.setloclist(0, {}, ' ', {title = 'JumpList', items = items, idx = idx})
    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        cmd('abo lw')
    else
        api.nvim_set_current_win(winid)
    end
end

function M.switch_lastbuf()
    local alter_bufnr = fn.bufnr('#')
    local cur_bufnr = api.nvim_get_current_buf()
    if alter_bufnr ~= -1 and alter_bufnr ~= cur_bufnr then
        cmd('b #')
    else
        local mru_list = require('mru').list()
        local cur_bufname = api.nvim_buf_get_name(cur_bufnr)
        for _, f in ipairs(mru_list) do
            if cur_bufname ~= f then
                cmd(('e %s'):format(fn.fnameescape(f)))
                cmd('sil! norm! `"')
                break
            end
        end
    end
end

function M.split_lastbuf(vertical)
    local sp = vertical and 'vert' or ''
    local binfo = api.nvim_eval(
        [[map(getbufinfo({'buflisted':1}),'{"bufnr": v:val.bufnr, "lastused": v:val.lastused}')]])
    local last_buf_info
    for _, bi in ipairs(binfo) do
        if fn.bufwinnr(bi.bufnr) == -1 then
            if not last_buf_info or last_buf_info.lastused < bi.lastused then
                last_buf_info = bi
            end
        end
    end
    cmd(sp .. ' sb ' .. (last_buf_info and last_buf_info.bufnr or ''))
end

function M.search_wrap()
    if api.nvim_get_mode().mode ~= 'n' then
        return
    end
    local bufnr = api.nvim_get_current_buf()
    local topline = fn.line('w0')
    vim.schedule(function()
        if bufnr == api.nvim_get_current_buf() and topline ~= fn.line('w0') then
            local lnum = fn.line('.') - 1
            utils.highlight(bufnr, 'Reverse', {lnum}, {lnum + 1}, {hl_eol = true}, 350)
        end
    end)
end

-- https://github.com/neovim/neovim/issues/11440
function M.fix_quit()
    local ok, msg = pcall(cmd, 'q')
    if not ok and msg:match(':E5601:') then
        cmd('1only | q')
    end
end

return M
