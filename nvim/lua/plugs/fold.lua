local M = {}
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local parsers = require('nvim-treesitter.parsers')

local bl_ft = {'man', 'help', 'markdown'}
local anyfold_prefer_ft = {'python'}

local function init()
    api.nvim_exec([[
        augroup FoldLoad
            autocmd!
            autocmd FileType * lua require('plugs.fold').defer_load()
        augroup END
    ]], false)

    cmd([[command! -nargs=0 Fold lua require('plugs.fold').do_fold()]])
    _G.foldtext = M.foldtext
    M.defer_load()
end

local function gutter_size()
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    api.nvim_win_set_cursor(0, {lnum, 0})
    local size = fn.wincol() - 1
    api.nvim_win_set_cursor(0, {lnum, col})
    return size
end

function M.do_fold()
    local ret = false
    local fsize
    if vim.tbl_contains(anyfold_prefer_ft, vim.bo.filetype) then
        fsize = fn.getfsize(fn.bufname('%'))
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
            fsize = fn.getfsize(fn.bufname('%'))
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
    if vim.bo.buftype == 'terminal' or vim.bo.buftype == 'quickfix' then
        return
    end
    if vim.tbl_contains(bl_ft, vim.bo.filetype) then
        return
    end
    local bufnr = tonumber(fn.expand('<abuf>')) or api.nvim_get_current_buf()
    vim.defer_fn(function()
        if vim.b.loaded_fold or vim.wo.foldmethod == 'diff' then
            return
        end
        local cur_bufnr = api.nvim_get_current_buf()
        if cur_bufnr == bufnr then
            M.do_fold()
        elseif api.nvim_buf_is_valid(bufnr) then
            cmd(string.format('autocmd FoldLoad BufEnter <buffer=%d> ++once %s', bufnr,
                [[lua require('plugs.fold').do_fold()]]))
        end
    end, 1500)
end

function M.foldtext()
    local fs = vim.v.foldstart
    local fs_line = api.nvim_buf_get_lines(0, fs - 1, fs, false)[1]
    while not fs_line:match('%w') do
        fs = fn.nextnonblank(fs + 1)
        fs_line = api.nvim_buf_get_lines(0, fs - 1, fs, false)[1]
    end

    local line
    if fs > vim.v.foldend then
        line = api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, false)[1]
    else
        line = fs_line:gsub('\t', string.rep(' ', vim.bo.tabstop))
    end
    local g_size = gutter_size()
    local width = api.nvim_win_get_width(0) - g_size
    local fold_info = string.format(' %d lines %s', 1 + vim.v.foldend - vim.v.foldstart,
        string.rep(' + ', vim.v.foldlevel))
    local spaces = string.rep(' ', width - fn.strwidth(fold_info .. line))
    return line .. spaces .. fold_info
end

init()

return M
