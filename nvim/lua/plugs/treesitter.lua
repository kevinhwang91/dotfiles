local M = {}
local cmd = vim.cmd

local function setup()
    cmd([[
        hi link TSPunctBracket Delimiter
        hi link TSVariable NONE
        hi link TSConstant NONE
        hi link TSKeyword Keyword
        hi link TSInclude Keyword
        hi link TSConstBuiltin SpecialChar
        hi link TSParameter Parameter
        hi link TSVariableBuiltin SpecialChar
    ]])

    cmd('pa nvim-treesitter')
    cmd('pa nvim-treesitter-textobjects')
    require('nvim-treesitter.configs').setup({
        ensure_installed = 'maintained',
        ignore_install = {'comment'},
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
        matchup = {enable = true}
    })
end

setup()

return M
