local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local bmap, bunmap = function(...)
    require('remap').bmap(0, unpack({...}))
end, function(mode, lhs)
    api.nvim_buf_del_keymap(0, mode, lhs)
end

function M.manual_init(args)
    api.nvim_exec([[
        aug NvimGdb
            au User NvimGdbStart lua require('plugs.nvimgdb').start()
        aug end

        function! GdbSetKeymaps()
            call v:lua.require('plugs.nvimgdb').set_keymaps()
        endfunction

        function! GdbUnsetKeymaps()
            call v:lua.require('plugs.nvimgdb').unset_keymaps()
        endfunction

        function! GdbSetTKeymaps()
            call v:lua.require('plugs.nvimgdb').set_tkeymaps()
        endfunction
    ]], false)

    vim.schedule(function()
        cmd('delf! GdbInit')
        cmd('so ' .. vim.g.loaded_remote_plugins)
        fn['GdbInit'](unpack(args))
    end)

    M.manual_init = nil
end

-- alacritty has remaped Control-([1-9]|[0]) to Control-[F1-F10] (F25-F34)
function M.set_keymaps()
    bmap('n', '<F25>', '<Cmd>GdbRun<CR>')
    bmap('n', '<F26>', '<Cmd>GdbContinue<CR>')
    bmap('n', '<F27>',
        [[<Cmd>echo substitute(GdbCustomCommand('info locals'), '\r\n', ' \| ', 'g')<CR>]])
    bmap('n', '<F28>', '<Cmd>GdbDebugStop<CR>')
    bmap('n', '<F29>', '<Cmd>GdbEvalWord<CR>')
    bmap('x', '<F29>', '<Cmd>GdbEvalRange<CR>')
    bmap('n', '<F30>', '<Cmd>GdbFinish<CR>')
    bmap('n', '<F31>', '<Cmd>GdbStep<CR>')
    bmap('n', '<F32>', '<Cmd>GdbNext<CR>')
    bmap('n', '<F33>', '<Cmd>GdbUntil<CR>')
    bmap('n', '<F34>', '<Cmd>GdbBreakpointToggle<CR>')
    bmap('n', '<C-P>', '<Cmd>GdbFrameUp<CR>')
    bmap('n', '<C-N>', '<Cmd>GdbFrameDown<CR>')
    bmap('n', '<Leader>wl', '<Cmd>GdbCreateWatch info locals<CR>')
end

function M.unset_keymaps()
    bunmap('', '<F25>')
    bunmap('', '<F26>')
    bunmap('', '<F27>')
    bunmap('', '<F28>')
    bunmap('', '<F29>')
    bunmap('', '<F30>')
    bunmap('', '<F31>')
    bunmap('', '<F32>')
    bunmap('', '<F33>')
    bunmap('', '<F34>')
    bunmap('', '<C-P>')
    bunmap('', '<C-N>')
    bunmap('', '<Leader>wl')
end

function M.set_tkeymaps()
    bmap('t', '<C-t>', [[<C-\><C-n>:winc p<CR>]])
end

function M.start()
    fn.sign_undefine('GdbCurrentLine')
    fn.sign_define('GdbCurrentLine', {numhl = 'Operator'})
    for i = 1, 9 do
        fn.sign_define('GdbBreakpoint' .. i, {texthl = 'WarningMsg'})
    end
    vim.wo.foldcolumn = '0'
    vim.wo.signcolumn = 'no'
    vim.wo.number = false
    vim.wo.relativenumber = false
end

return M
