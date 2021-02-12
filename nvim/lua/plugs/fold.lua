local M = {}
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local anyfold_ft = {'vim', 'python', 'yaml', 'xml', 'html', 'make', 'sql', 'tmux'}
local ts_ft = {
    'c', 'cpp', 'go', 'rust', 'java', 'lua', 'javascript', 'typescript', 'css', 'json', 'sh', 'zsh'
}

local function init()
    cmd('augroup FoldLoad')
    cmd('autocmd!')
    cmd(string.format([[autocmd FileType %s,%s lua require('plugs.fold').defer_load()]],
        table.concat(anyfold_ft, ','), table.concat(ts_ft, ',')))
    cmd('augroup END')

    cmd([[command! -nargs=0 Fold lua require('plugs.fold').do_fold()]])
    _G.foldtext = M.foldtext
end

local function gutter_size()
    local lnum, col = unpack(api.nvim_win_get_cursor(0))
    api.nvim_win_set_cursor(0, {lnum, 0})
    local size = fn.wincol() - 1
    api.nvim_win_set_cursor(0, {lnum, col})
    return size
end

function M.do_fold()
    if vim.tbl_contains(ts_ft, vim.bo.filetype) then
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
    elseif vim.tbl_contains(anyfold_ft, vim.bo.filetype) then
        local fsize = fn.getfsize(fn.bufname('%'))
        if 0 >= fsize or fsize > 524288 then
            return
        end
        cmd('AnyFoldActivate')
    else
        return
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
    local bufnr = tonumber(fn.expand('<abuf>'))
    vim.defer_fn(function()
        if vim.b.loaded_fold or vim.wo.foldmethod == 'diff' then
            return
        end
        local cur_bufnr = api.nvim_get_current_buf()
        if cur_bufnr == bufnr then
            M.do_fold()
        else
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
