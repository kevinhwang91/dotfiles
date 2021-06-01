local M = {}
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local default_preview_window
local mru = require('mru')
local cmdhist = require('cmdhist')

local function setup()
    vim.g.fzf_action = {['ctrl-t'] = 'tabedit', ['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit'}
    vim.g.fzf_layout = {window = {width = 0.7, height = 0.7}}
    cmd([[
        function! FzfWrapper(opts) abort
            call fzf#run(fzf#wrap(a:opts))
        endfunction

        aug Fzf
            au!
            au VimResized * lua require('plugs.fzf').resize_preview_layout()
        aug END
    ]])

    vim.g.loaded_fzf = nil
    cmd('pa fzf')
    cmd('pa fzf.vim')
    default_preview_window = {'right:50%,border-left', 'ctrl-/'}
    M.resize_preview_layout()
end

local function run_wrapper(opts)
    local sink = opts['sink*']
    if sink then
        local fzf_wrap = fn['fzf#wrap'](opts)
        fzf_wrap['sink*'] = sink
        fn['fzf#run'](fzf_wrap)
    else
        fn['FzfWrapper'](opts)
    end
end

local function mru_source()
    local list = mru.list()
    if #list > 0 and list[1] == api.nvim_buf_get_name(0) then
        table.remove(list, 1)
    end
    return vim.tbl_map(function(val)
        return fn.fnamemodify(val, ':~:.')
    end, list)
end

local function cmdhist_source()
    return cmdhist.list()
end

local function cmdhist_sink(ret)
    local key, cmdl = unpack(ret)
    fn.histadd(':', cmdl)
    cmdhist.store()
    if key == 'ctrl-e' then
        cmd('redraw')
        api.nvim_feedkeys(api.nvim_replace_termcodes(':<up>', true, false, true), 'n', false)
    else
        api.nvim_feedkeys((':%s%c'):format(cmdl, 0x0d), '', false)
    end
end

function M.mru()
    local preview_args = vim.g.fzf_preview_window or default_preview_window
    local opts = #preview_args == 0 and {'hidden'} or preview_args
    opts = fn['fzf#vim#with_preview'](unpack(opts))
    vim.list_extend(opts.options, {'--prompt', 'MRU> ', '--tiebreak', 'index'})
    opts.name = 'mru-files'
    opts.source = mru_source()
    run_wrapper(opts)
end

function M.cmdhist()
    local opts = {
        name = 'history-command',
        source = cmdhist_source(),
        ['sink*'] = cmdhist_sink,
        options = {'--prompt', 'Hist: ', '--tiebreak', 'index', '--expect', 'ctrl-e'}
    }
    fn['FzfWrapper'](opts)
end

function M.resize_preview_layout()
    pcall(function()
        local layout = vim.g.fzf_layout.window
        if vim.o.columns * layout.width - 2 > 100 then
            vim.g.fzf_preview_window = {'right:50%,border-left'}
        else
            if vim.o.lines * layout.height - 2 > 25 then
                vim.g.fzf_preview_window = {'down:50%,border-top'}
            else
                vim.g.fzf_preview_window = {}
            end
        end
    end)
end

setup()

return M
