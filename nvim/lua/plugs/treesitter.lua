local M = {}
local cmd = vim.cmd
local fn = vim.fn

local do_sy_tbl = {}

local function setup()
    local conf = {
        ensure_installed = 'maintained',
        highlight = {enable = true, disable = {'bash'}},
        textobjects = {
            select = {
                enable = true,
                keymaps = {
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ia'] = '@parameter.inner',
                    ['ac'] = '@conditional.outer',
                    ['ic'] = '@conditional.inner',
                    ['al'] = '@loop.outer',
                    ['il'] = '@loop.inner',
                    ['ak'] = '@class.outer',
                    ['ik'] = '@class.inner'
                }
            },
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
        -- if ft ~= 'qf' then
        vim.bo.syntax = ft
        -- end
    end
end

setup()

return M
