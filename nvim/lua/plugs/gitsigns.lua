local M = {}
local cmd = vim.cmd

local config
local bmap = require('remap').bmap

function M.toggle_deleted()
    require('gitsigns').toggle_deleted()
    vim.notify(('Gitsigns %s show_deleted'):format(config.show_deleted and 'enable' or 'disable'))
end

local function mappings(bufnr)
    bmap(bufnr, 'n', ']c', [[&diff ? ']c' : '<Cmd>Gitsigns next_hunk<CR>']],
        {noremap = true, expr = true})
    bmap(bufnr, 'n', '[c', [[&diff ? '[c' : '<Cmd>Gitsigns prev_hunk<CR>']],
        {noremap = true, expr = true})

    bmap(bufnr, 'n', '<Leader>hs', '<Cmd>Gitsigns stage_hunk<CR>')
    bmap(bufnr, 'x', '<Leader>hs', ':Gitsigns stage_hunk<CR>')
    bmap(bufnr, 'n', '<Leader>hS', '<Cmd>Gitsigns undo_stage_hunk<CR>')
    bmap(bufnr, 'n', '<Leader>hu', '<Cmd>Gitsigns reset_hunk<CR>')
    bmap(bufnr, 'x', '<Leader>hu', ':Gitsigns reset_hunk<CR>')
    bmap(bufnr, 'n', '<Leader>hp', '<Cmd>Gitsigns preview_hunk<CR>')
    bmap(bufnr, 'n', '<Leader>hv', [[<Cmd>lua require('plugs.gitsigns').toggle_deleted()<CR>]])
    bmap(bufnr, 'o', 'ih', ':<C-u>Gitsigns select_hunk<CR>')
    bmap(bufnr, 'x', 'ih', ':<C-u>Gitsigns select_hunk<CR>')
end

function M.setup()
    require('gitsigns').setup({
        signs = {
            add = {hl = 'GitSignsAdd', text = '│', numhl = 'Constant', linehl = 'GitSignsAddLn'},
            change = {
                hl = 'GitSignsChange',
                text = '│',
                numhl = 'Type',
                linehl = 'GitSignsChangeLn'
            },
            delete = {
                hl = 'GitSignsDelete',
                text = '_',
                numhl = 'Identifier',
                linehl = 'GitSignsDeleteLn'
            },
            topdelete = {
                hl = 'GitSignsDelete',
                text = '‾',
                numhl = 'ErrorMsg',
                linehl = 'GitSignsDeleteLn'
            },
            changedelete = {
                hl = 'GitSignsChange',
                text = '~',
                numhl = 'Number',
                linehl = 'GitSignsChangeLn'
            }
        },
        signcolumn = false,
        numhl = true,
        linehl = false,
        word_diff = true,
        watch_gitdir = {interval = 2000, follow_files = true},
        on_attach = function(bufnr)
            mappings(bufnr)
        end,
        attach_to_untracked = true,
        current_line_blame = false,
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
            border = 'rounded',
            style = 'minimal',
            relative = 'cursor',
            noautocmd = true,
            row = 0,
            col = 1
        },
        show_deleted = false,
        trouble = false,
        yadm = {enable = false}
    })
    config = require('gitsigns.config').config
end

local function init()
    cmd('pa plenary.nvim')
    cmd([[
        hi link GitSignsChangeLn DiffText
        hi link GitSignsAddInline GitSignsAddLn
        hi link GitSignsDeleteInline GitSignsDeleteLn
        hi link GitSignsChangeInline GitSignsChangeLn
    ]])
    M.setup()
end

init()

return M
