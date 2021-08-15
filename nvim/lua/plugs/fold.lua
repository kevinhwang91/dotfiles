local M = {}
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local utils = require('kutils')

local bl_ft
local anyfold_prefer_ft

local function find_win_except_float(bufnr)
    local winid = fn.bufwinid(bufnr)
    if fn.win_gettype(winid) == 'popup' then
        local f_winid = winid
        winid = 0
        for _, wid in pairs(api.nvim_list_wins()) do
            if f_winid ~= wid and api.nvim_win_get_buf(wid) == bufnr then
                winid = wid
                break
            end
        end
    end
    return winid
end

local function use_anyfold(filename)
    local fsize = fn.getfsize(filename)
    if 0 < fsize and fsize < 131072 then
        cmd('AnyFoldActivate')
    end
end

function M.do_fold()
    local bufnr = api.nvim_get_current_buf()
    local filename = api.nvim_buf_get_name(bufnr)
    if vim.g.coc_service_initialized == 1 and not vim.tbl_contains(anyfold_prefer_ft, vim.bo.ft) then
        fn.CocActionAsync('hasProvider', 'foldingRange', function(e, r)
            if e == vim.NIL and r then
                fn.CocActionAsync('fold', '', function(e1, r1)
                    if e1 ~= vim.NIL or not r1 then
                        use_anyfold(filename)
                    else
                        pcall(api.nvim_buf_set_var, bufnr, 'loaded_fold', 'coc')
                        cmd(('au FoldLoad BufWritePost <buffer=%d> %s'):format(bufnr,
                            [[call CocActionAsync('fold')]]))
                    end
                end)
            else
                use_anyfold(filename)
            end
        end)
    else
        use_anyfold(filename)
    end
    cmd(('au! FoldLoad * <buffer=%d>'):format(bufnr))
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
    vim.wo.foldtext = 'v:lua.foldtext()'
    vim.b.loaded_fold = 'anyfold'
end

function M.defer_load(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    local bo = vim.bo[bufnr]
    if vim.tbl_contains(bl_ft, bo.ft) or bo.bt ~= '' then
        return
    end

    local ok, loadby = pcall(function()
        return api.nvim_buf_get_var(bufnr, 'loaded_fold')
    end)
    if ok then
        if loadby == 'coc' then
            vim.defer_fn(function()
                if bufnr == api.nvim_get_current_buf() then
                    fn.CocActionAsync('fold')
                end
            end, 100)
        end
        return
    end

    local winid = find_win_except_float(bufnr)
    if winid == 0 or not api.nvim_win_is_valid(winid) then
        return
    end
    local wo = vim.wo[winid]
    if wo.foldmethod == 'diff' then
        return
    end

    wo.foldmethod = 'manual'
    vim.defer_fn(function()
        if fn.buflisted(bufnr) == 1 then
            winid = fn.bufwinid(bufnr)
            if api.nvim_win_is_valid(winid) and vim.wo[winid].foldmethod == 'manual' then
                if not pcall(function()
                    return api.nvim_buf_get_var(bufnr, 'loaded_fold')
                end) then
                    local cur_bufnr = api.nvim_get_current_buf()
                    if cur_bufnr == bufnr then
                        M.do_fold()
                    else
                        cmd(('au FoldLoad BufEnter <buffer=%d> ++once %s'):format(bufnr,
                            [[lua require('plugs.fold').do_fold()]]))
                    end
                end
            end
        end
    end, 1500)
end

function M.foldtext()
    local fs, fe = vim.v.foldstart, vim.v.foldend
    local fs_lines = api.nvim_buf_get_lines(0, fs - 1, fe - 1, false)
    local fs_line = fs_lines[1]
    for _, line in ipairs(fs_lines) do
        if line:match('%w') then
            fs_line = line
            break
        end
    end
    local pad = ' '
    fs_line = utils.expandtab(fs_line)
    local gutter_size = fn.screenpos(0, api.nvim_win_get_cursor(0)[1], 1).curscol -
                            fn.win_screenpos(0)[2]
    local width = api.nvim_win_get_width(0) - gutter_size
    local fold_info = (' %d lines %s +- '):format(1 + fe - fs, vim.v.foldlevel)
    local spaces = pad:rep(width - #fold_info - api.nvim_strwidth(fs_line))
    return fs_line .. spaces .. fold_info
end

function M.nav_fold(forward)
    local cnt = vim.v.count1
    local wv = fn.winsaveview()
    cmd([[norm! m`]])
    local cur_l, cur_c
    while cnt > 0 do
        if forward then
            cmd('keepj norm! ]z')
        else
            cmd('keepj norm! zk')
        end
        cur_l, cur_c = unpack(api.nvim_win_get_cursor(0))
        if forward then
            cmd('keepj norm! zj_')
        else
            cmd('keepj norm! [z_')
        end
        cnt = cnt - 1
    end

    local cur_l1, cur_c1 = unpack(api.nvim_win_get_cursor(0))
    if cur_l == cur_l1 and cur_c == cur_c1 then
        if forward or fn.foldclosed(cur_l) == -1 then
            fn.winrestview(wv)
        end
    end
end

function M.toggle_fold(c)
    local cnt = vim.v.count1
    local ok = pcall(cmd, ('norm! m`V%dz%s%c'):format(cnt, c, 0x1b))
    if ok and fn.foldclosed('.') == -1 then
        cmd(('norm! %c'):format(0x1b))
        local t
        t = api.nvim_buf_get_mark(0, '<')
        local start = {t[1] - 1, t[2]}
        t = api.nvim_buf_get_mark(0, '>')
        local finish = {t[1] - 1, t[2]}

        utils.highlight(0, 'Visual', start, finish, 500)

        cmd('norm! ``')
    end
end

local function init()
    vim.g.anyfold_fold_display = 0
    vim.g.anyfold_identify_comments = 0
    vim.g.anyfold_motion = 0

    bl_ft = {'', 'man', 'markdown', 'git', 'floggraph'}
    anyfold_prefer_ft = {'vim'}
    cmd([[
        aug FoldLoad
            au!
            au FileType * lua require('plugs.fold').defer_load(tonumber(vim.fn.expand('<abuf>')))
        aug END
    ]])

    cmd([[com! -nargs=0 Fold lua require('plugs.fold').do_fold()]])
    _G.foldtext = M.foldtext
    for _, bufnr in pairs(api.nvim_list_bufs()) do
        if fn.buflisted(bufnr) == 1 then
            M.defer_load(bufnr)
        end
    end
end

init()

return M
