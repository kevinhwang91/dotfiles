local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

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

function M.split_lastbuf(vertical)
    local sp = vertical and 'vert' or ''
    local buf_info = api.nvim_eval(
        [[map(getbufinfo({'buflisted':1}),'{"bufnr": v:val.bufnr, "lastused": v:val.lastused}')]])
    local last_buf_info
    for _, info in ipairs(buf_info) do
        if fn.bufwinnr(info.bufnr) == -1 then
            if not last_buf_info or last_buf_info.lastused < info.lastused then
                last_buf_info = info
            end
        end
    end
    cmd(sp .. ' sb ' .. (last_buf_info and last_buf_info.bufnr or ''))
end

return M
