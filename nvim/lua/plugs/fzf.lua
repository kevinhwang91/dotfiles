local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local mru = require('mru')

local function init()
    vim.env.FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS .. ' --reverse --info=inline --border'
    vim.env.BAT_STYLE = 'numbers'
    vim.g.fzf_layout = {window = {width = 0.7, height = 0.7}}
    api.nvim_exec([[
        function! FzfMruFiles(name, opts) abort
            call fzf#run(fzf#wrap(a:name, a:opts, 0))
        endfunction
    ]], false)

    api.nvim_exec([[
        augroup Fzf
            autocmd!
            autocmd VimResized * lua require('plugs.fzf').resize_preview_layout()
        augroup END
    ]], false)

    vim.g.loaded_fzf = nil
    cmd('packadd fzf')
    cmd('packadd fzf.vim')
    M.resize_preview_layout()
end

local function mru_source()
    local mru_list = mru.list()
    if #mru_list > 0 and mru_list[1] == fn.expand('%:p') then
        table.remove(mru_list, 1)
    end
    return vim.tbl_map(function(val)
        return fn.fnamemodify(val, ':~:.')
    end, mru_list)
end

function M.mru()
    local preview_args = vim.g.fzf_preview_window or {'right', 'ctrl-/'}
    local opts = #preview_args == 0 and {'hidden'} or preview_args
    opts = fn['fzf#vim#with_preview'](unpack(opts))
    vim.list_extend(opts.options, {'--prompt', 'MRU> ', '--tiebreak', 'index'})
    opts.source = mru_source()
    fn['FzfMruFiles']('mru-files', opts)
end

function M.resize_preview_layout()
    pcall(function()
        local layout = vim.g.fzf_layout.window
        if vim.o.columns * layout.width[false] - 2 > 100 then
            vim.g.fzf_preview_window = {'right:50%'}
        else
            if vim.o.lines * layout.height[false] - 2 > 25 then
                vim.g.fzf_preview_window = {'down:50%'}
            else
                vim.g.fzf_preview_window = {}
            end
        end
    end)
end

init()

return M
