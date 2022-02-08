local M = {}
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local uv = vim.loop

local utils = require('kutils')

local bl_ft
local coc_loaded_ft
local anyfold_prefer_ft

local function find_win_except_float(bufnr)
    local winid = fn.bufwinid(bufnr)
    if fn.win_gettype(winid) == 'popup' then
        local f_winid = winid
        winid = 0
        for _, wid in ipairs(api.nvim_list_wins()) do
            if f_winid ~= wid and api.nvim_win_get_buf(wid) == bufnr then
                winid = wid
                break
            end
        end
    end
    return winid
end

function M.use_anyfold(bufnr, force)
    local filename = api.nvim_buf_get_name(bufnr)
    local st = uv.fs_stat(filename)
    if st then
        local fsize = st.size
        if force or 0 < fsize and fsize < 131072 then
            if fn.bufwinid(bufnr) == -1 then
                cmd(('au FoldLoad BufEnter <buffer=%d> ++once %s'):format(bufnr,
                    ([[lua require('plugs.fold').use_anyfold(%d)]]):format(bufnr)))
            else
                api.nvim_buf_call(bufnr, function()
                    utils.cool_echo(('bufnr: %d is using anyfold'):format(bufnr), 'WarningMsg')
                    cmd('AnyFoldActivate')
                end)
            end
        end
    end
    vim.b[bufnr].loaded_fold = 'anyfold'
end

local function apply_fold(bufnr, ranges)
    api.nvim_buf_call(bufnr, function()
        vim.wo.foldmethod = 'manual'
        cmd('norm! zE')
        local fold_cmd = {}
        for _, f in ipairs(ranges) do
            table.insert(fold_cmd, ('%d,%d:fold'):format(f.startLine + 1, f.endLine + 1))
        end
        cmd(table.concat(fold_cmd, '|'))
        vim.wo.foldenable = true
        vim.wo.foldlevel = 99
    end)
end

function M.update_fold(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    require('plugs.coc').run_command('kvs.fold.foldingRange', {bufnr}, function(e, r)
        if e == vim.NIL and type(r) == 'table' then
            apply_fold(bufnr, r)
        end
    end)
end

function M.attach(bufnr, force)
    bufnr = bufnr or api.nvim_get_current_buf()
    if not api.nvim_buf_is_valid(bufnr) or not force and vim.b[bufnr].loaded_fold then
        return
    end

    if vim.g.coc_service_initialized == 1 and not vim.tbl_contains(anyfold_prefer_ft, vim.bo.ft) then
        require('plugs.coc').run_command('kvs.fold.foldingRange', {bufnr}, function(e, r)
            if not force and vim.b[bufnr].loaded_fold then
                return
            end
            if e == vim.NIL and type(r) == 'table' then
                -- language servers may need time to parser buffer
                if #r == 0 then
                    local ft = vim.bo[bufnr].ft
                    local loaded = coc_loaded_ft[ft]
                    if not loaded then
                        vim.defer_fn(function()
                            coc_loaded_ft[ft] = true
                            M.attach(bufnr)
                        end, 2000)
                        return
                    end
                end
                local winid = fn.bufwinid(bufnr)
                if winid == -1 then
                    cmd(('au FoldLoad BufEnter <buffer=%d> ++once %s'):format(bufnr,
                        [[lua require('plugs.fold').update_fold()]]))
                else
                    apply_fold(bufnr, r)
                end
                vim.b[bufnr].loaded_fold = 'coc'
                cmd(('au FoldLoad BufWritePost <buffer=%d> %s'):format(bufnr,
                    [[lua require('plugs.fold').update_fold()]]))
                cmd(('au FoldLoad BufRead <buffer=%d> %s'):format(bufnr,
                    [[lua vim.defer_fn(require('plugs.fold').update_fold, 100)]]))

            else
                M.use_anyfold(bufnr, force)
            end
        end)
    else
        M.use_anyfold(bufnr, force)
    end
    cmd(('au! FoldLoad * <buffer=%d>'):format(bufnr))
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
    vim.wo.foldtext = [[v:lua.require'plugs.fold'.foldtext()]]
end

function M.defer_attach(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    local bo = vim.bo[bufnr]
    if vim.b[bufnr].loaded_fold or vim.tbl_contains(bl_ft, bo.ft) or bo.bt ~= '' then
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
        M.attach(bufnr)
    end, 1000)
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
    fs_line = utils.expandtab(fs_line, vim.bo.ts)
    local winid = api.nvim_get_current_win()
    local textoff = fn.getwininfo(winid)[1].textoff
    local width = api.nvim_win_get_width(0) - textoff
    local fold_info = (' %d lines %s +- '):format(1 + fe - fs, vim.v.foldlevel)
    local padding = pad:rep(width - #fold_info - api.nvim_strwidth(fs_line))
    return fs_line .. padding .. fold_info
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

function M.with_highlight(c)
    local cnt = vim.v.count1
    local fostart = fn.foldclosed('.')
    local foend
    if fostart > 0 then
        foend = fn.foldclosedend('.')
    end

    local ok = pcall(cmd, ('norm! %dz%s'):format(cnt, c))
    if ok then
        if fn.foldclosed('.') == -1 and fostart > 0 and foend > fostart then
            utils.highlight(0, 'Visual', fostart - 1, foend, nil, 400)
        end
    end
end

local function init()
    vim.g.anyfold_fold_display = 0
    vim.g.anyfold_identify_comments = 0
    vim.g.anyfold_motion = 0

    bl_ft = {'', 'man', 'markdown', 'git', 'floggraph'}
    coc_loaded_ft = {}
    anyfold_prefer_ft = {'vim'}
    cmd([[
        aug FoldLoad
            au!
            au FileType * lua require('plugs.fold').defer_attach(tonumber(vim.fn.expand('<abuf>')))
        aug END
    ]])

    cmd([[com! -nargs=0 Fold lua require('plugs.fold').attach(nil, true)]])
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        M.defer_attach(bufnr)
    end
end

init()

return M
