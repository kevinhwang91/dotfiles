local M = {}
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local parsers = require('nvim-treesitter.parsers')

local bl_ft
local anyfold_prefer_ft

local function setup()
    bl_ft = {'man', 'help', 'markdown'}
    anyfold_prefer_ft = {'python'}
    cmd([[
        aug FoldLoad
            au!
            au FileType * lua require('plugs.fold').defer_load()
        aug END
    ]])

    cmd([[com! -nargs=0 Fold lua require('plugs.fold').do_fold()]])
    _G.foldtext = M.foldtext
    M.defer_load()
end

function M.do_fold()
    local ret = false
    local fsize
    local bufname = api.nvim_buf_get_name(0)
    if vim.tbl_contains(anyfold_prefer_ft, vim.bo.filetype) then
        fsize = fn.getfsize(bufname)
        if 0 < fsize and fsize < 524288 then
            cmd('AnyFoldActivate')
            ret = true
        end
    end
    if not ret then
        if parsers.has_parser() then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
        elseif not fsize then
            fsize = fn.getfsize(bufname)
            if 0 < fsize and fsize < 524288 then
                cmd('AnyFoldActivate')
            end
        end
    end
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
    vim.wo.foldtext = 'v:lua.foldtext()'
    vim.b.loaded_fold = true
end

function M.defer_load()
    if vim.b.loaded_fold or vim.wo.foldmethod == 'diff' then
        return
    end
    local bt = vim.bo.bt
    if bt == 'terminal' or bt == 'quickfix' then
        return
    end
    if vim.tbl_contains(bl_ft, vim.bo.filetype) then
        return
    end
    vim.wo.foldmethod = 'manual'
    local bufnr = tonumber(fn.expand('<abuf>')) or api.nvim_get_current_buf()
    vim.defer_fn(function()
        if vim.b.loaded_fold or vim.wo.foldmethod == 'diff' then
            return
        end
        local cur_bufnr = api.nvim_get_current_buf()
        if cur_bufnr == bufnr then
            M.do_fold()
        elseif api.nvim_buf_is_valid(bufnr) then
            cmd(('au FoldLoad BufEnter <buffer=%d> ++once %s'):format(bufnr,
                [[lua require('plugs.fold').do_fold()]]))
        end
    end, 1500)
end

function M.foldtext()
    local fs, fe = vim.v.foldstart, vim.v.foldend
    local fs_line = api.nvim_buf_get_lines(0, fs - 1, fs, false)[1]
    while not fs_line:match('%w') do
        fs = fn.nextnonblank(fs + 1)
        fs_line = api.nvim_buf_get_lines(0, fs - 1, fs, false)[1]
    end

    local pad = ' '
    local line = fs_line:gsub('\t', pad:rep(vim.bo.tabstop))
    local gutter_size = fn.screenpos(0, api.nvim_win_get_cursor(0)[1], 1).curscol -
                            fn.win_screenpos(0)[2]
    local width = api.nvim_win_get_width(0) - gutter_size
    local fold_info = (' %d lines %s'):format(1 + fe - fs, (' + '):rep(vim.v.foldlevel))
    local spaces = pad:rep(width - fn.strwidth(fold_info .. line))
    return line .. spaces .. fold_info
end

setup()

return M
