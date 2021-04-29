local M = {}
local cmd = vim.cmd

local function setup()
    cmd('pa nvim-treesitter')
    cmd('pa nvim-treesitter-textobjects')
    require('nvim-treesitter.configs').setup({
        ensure_installed = 'maintained',
        highlight = {enable = true, disable = {'bash', 'yaml'}},
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
        }
    })
end

setup()

return M
