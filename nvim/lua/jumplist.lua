local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

function M.jumps2qf()
    local items, idx = {}, -1
    local jump_ctx = fn.msgpackparse(api.nvim_get_context({types = {'jumps'}}).jumps)
    local cur_bufnr = api.nvim_get_current_buf()
    local cur_l = api.nvim_win_get_cursor(0)[1]
    for i = #jump_ctx, 4, -4 do
        local ctx = jump_ctx[i]
        local fname, lnum, col = ctx.f, ctx.l or 1, ctx.c or 0
        local bufnr = fn.bufnr(fname)
        local text = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
        if not text then
            text = '......'
        end
        table.insert(items, {bufnr = bufnr, lnum = lnum, col = col + 1, text = text})
        if idx == -1 and cur_bufnr == bufnr and cur_l == lnum then
            idx = #items
        end
    end
    idx = idx == -1 and 1 or idx
    fn.setloclist(0, {}, ' ', {title = 'JumpList', items = items, idx = idx})
    local winid = fn.getloclist(0, {winid = 0}).winid
    if winid == 0 then
        cmd('aboveleft lwindow')
    else
        api.nvim_set_current_win(winid)
    end
end
return M
