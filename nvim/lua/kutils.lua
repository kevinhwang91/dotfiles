local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

function M.follow_symlink(fname)
    fname = fname and fn.fnamemodify(fname, ':p') or fn.expand('%:p')
    if fn.getftype(fname) ~= 'link' then
        return
    end
    cmd(string.format('keepalt file %s', fn.fnameescape(fn.resolve(fname))))
end

function M.clean_empty_buf()
    local bufnrs = {}
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if not vim.bo[bufnr].modified and api.nvim_buf_get_name(bufnr) == '' then
            table.insert(bufnrs, bufnr)
        end
    end
    if #bufnrs > 0 then
        cmd(string.format('bwipeout %s', table.concat(bufnrs, ' ')))
    end
end

function M.zz()
    local lnum1, lcount = api.nvim_win_get_cursor(0)[1], api.nvim_buf_line_count(0)
    if lnum1 == lcount then
        fn.execute(string.format('keepjumps normal! %dzb', lnum1))
        return
    end
    cmd('normal! zvzz')
    lnum1 = api.nvim_win_get_cursor(0)[1]
    cmd('normal! L')
    local lnum2 = api.nvim_win_get_cursor(0)[1]
    if lnum2 + fn.getwinvar(0, '&scrolloff') >= lcount then
        fn.execute(string.format('keepjumps normal! %dzb', lnum2))
    end
    if lnum1 ~= lnum2 then
        cmd('keepjumps normal! ``')
    end
end

function M.nav_fold(forward, cnt)
    local wv = fn.winsaveview()
    cmd([[normal! m']])
    local cur_l, cur_c
    while cnt > 0 do
        if forward then
            cmd('keepjumps normal! ]z')
        else
            cmd('keepjumps normal! zk')
        end
        cur_l, cur_c = unpack(api.nvim_win_get_cursor(0))
        if forward then
            cmd('keepjumps normal! zj_')
        else
            cmd('keepjumps normal! [z_')
        end
        cnt = cnt - 1
    end

    local cur_l1, cur_c1 = unpack(api.nvim_win_get_cursor(0))
    if cur_l == cur_l1 and cur_c == cur_c1 then
        fn.winrestview(wv)
    else
        cmd([[normal! m']])
    end
end

return M
