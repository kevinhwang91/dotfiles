local M = {}
local cmd = vim.cmd
local fn = vim.fn

local map = require('remap').map

local do_sy_tbl = {}

local function setup()
    local conf = {
        ensure_installed = 'maintained',
        highlight = {enable = true, disable = {'bash'}},
        textobjects = {
            select = {enable = true, keymaps = {['ia'] = '@parameter.inner'}},
            move = {
                enable = true,
                goto_next_start = {[']m'] = '@function.outer'},
                goto_next_end = {[']M'] = '@function.outer', [']f'] = '@function.outer'},
                goto_previous_start = {['[m'] = '@function.outer', ['[f'] = '@function.outer'},
                goto_previous_end = {['[M'] = '@function.outer'}
            }
        },
        matchup = {enable = false}
    }
    cmd([[
        hi! link TSVariable NONE
        hi! link TSParameter Parameter
        hi! link TSConstructor NONE
    ]])

    cmd('pa nvim-treesitter')
    cmd('pa nvim-treesitter-textobjects')

    require('nvim-treesitter.configs').setup(conf)

    cmd('pa iswap.nvim')
    require('iswap').setup {grey = 'disable', hl_snipe = 'IncSearch', hl_selection = 'MatchParen'}
    map('n', '<Leader>sp', '<Cmd>ISwap<CR>')

    local parsers = require('nvim-treesitter.parsers')
    local hl_disabled = conf.highlight.disable
    for lang in pairs(parsers.list) do
        if not vim.tbl_contains(hl_disabled, lang) then
            do_sy_tbl[lang] = true
        end
    end
end

function M.hijack_synset()
    local ft = fn.expand('<amatch>')
    if not do_sy_tbl[ft] then
        vim.bo.syntax = ft
    end
end

setup()

return M
