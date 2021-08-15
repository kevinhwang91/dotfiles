local M = {}
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local bmap, bunmap = function(...)
    require('remap').bmap(0, ...)
end, function(mode, lhs)
    pcall(api.nvim_buf_del_keymap, 0, mode, lhs)
end

local function app()
    return require('nvimgdb').apps[api.nvim_get_current_tabpage()]
end

local function jump_win(winid)
    if winid and winid > 0 and api.nvim_win_is_valid(winid) then
        api.nvim_set_current_win(winid)
    end
end

function M.switch_win()
    local cur_winid = api.nvim_get_current_win()
    local win_obj = app().win
    local code_winid = win_obj.jump_win
    local client = app().client
    local term_winid = client.win
    local jump_winid = cur_winid == term_winid and code_winid or term_winid
    jump_win(jump_winid)
end

-- alacritty has remaped Control-([1-9]|[0]) to Control-[F1-F10] (F25-F34)
function M.set_keymaps()
    bmap('n', '<F25>', '<Cmd>GdbRun<CR>')
    bmap('n', '<F26>', '<Cmd>GdbContinue<CR>')
    bmap('n', '<F27>',
        [[<Cmd>echo substitute(GdbCustomCommand('info locals'), '\r\n', ' \| ', 'g')<CR>]])
    bmap('n', '<F28>', '<Cmd>GdbDebugStop<CR>')
    bmap('n', '<F29>', '<Cmd>GdbEvalWord<CR>')
    bmap('x', '<F29>', ':GdbEvalRange<CR>')
    bmap('n', '<F30>', '<Cmd>GdbFinish<CR>')
    bmap('n', '<F31>', '<Cmd>GdbStep<CR>')
    bmap('n', '<F32>', '<Cmd>GdbNext<CR>')
    bmap('n', '<F33>', '<Cmd>GdbUntil<CR>')
    bmap('n', '<F34>', '<Cmd>GdbBreakpointToggle<CR>')
    bmap('n', '<C-p>', '<Cmd>GdbFrameUp<CR>')
    bmap('n', '<C-n>', '<Cmd>GdbFrameDown<CR>')
    bmap('n', '<C-t>', [[<Cmd>lua require('plugs.nvimgdb').switch_win()<CR>]])
    bmap('n', '<Leader>dl', '<Cmd>bel GdbCreateWatch info locals<CR>')
    bmap('n', '<Leader>db', '<Cmd>abo GdbLopenBreakpoints<CR>')
    bmap('n', '<Leader>dt', '<Cmd>abo GdbLopenBacktrace<CR>')
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
    bunmap('', '<C-p>')
    bunmap('', '<C-n>')
    bunmap('', '<C-t>')
    bunmap('', '<Leader>dl')
    bunmap('', '<Leader>db')
    bunmap('', '<Leader>dt')
end

function M.set_tkeymaps()
    bmap('t', '<F25>', '<Cmd>GdbRun<CR>')
    bmap('t', '<C-t>', [[<Cmd>lua require('plugs.nvimgdb').switch_win()<CR>]])
end

function M.start()
    fn.sign_undefine('GdbCurrentLine')
    fn.sign_define('GdbCurrentLine', {linehl = 'QuickFixLine'})
    for i = 1, 9 do
        fn.sign_define('GdbBreakpoint' .. i, {texthl = 'ErrorMsg'})
    end
    vim.wo.foldcolumn = '0'
    vim.wo.signcolumn = 'no'
    vim.wo.number = false
    vim.wo.relativenumber = false
end

local function init()
    vim.g.nvimgdb_config_override = {
        -- codewin_command = 'new',
        -- termwin_command = 'bo new',
        codewin_command = 'vnew',
        termwin_command = 'bo vnew',
        sign_breakpoint_priority = 99,
        set_keymaps = 'GdbSetKeymaps',
        unset_keymaps = 'GdbUnsetKeymaps',
        set_tkeymaps = 'GdbSetTKeymaps',
        jump_bottom_gdb_buf = false
    }

    cmd([[
        au User NvimGdbStart lua require('plugs.nvimgdb').start()

        function! GdbSetKeymaps()
            call v:lua.require('plugs.nvimgdb').set_keymaps()
        endfunction

        function! GdbUnsetKeymaps()
            call v:lua.require('plugs.nvimgdb').unset_keymaps()
        endfunction

        function! GdbSetTKeymaps()
            call v:lua.require('plugs.nvimgdb').set_tkeymaps()
        endfunction
    ]])
end

init()

return M
