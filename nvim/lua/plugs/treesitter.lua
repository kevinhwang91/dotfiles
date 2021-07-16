local M = {}
local cmd = vim.cmd
local fn = vim.fn

local map = require('remap').map

local do_sy_tbl = {}
local queries

function M.do_textobject(obj, inner, visual)
    local ret = false
    if queries.has_query_files(vim.bo.ft, 'textobjects') then
        require('nvim-treesitter.textobjects.select').select_textobject(
            ('@%s.%s'):format(obj, inner and 'inner' or 'outer'), visual and 'x' or 'o')
        ret = true
    end
    return ret
end

function M.hijack_synset()
    local ft = fn.expand('<amatch>')
    if not do_sy_tbl[ft] then
        vim.bo.syntax = ft
    end
end

local function init()
    local conf = {
        ensure_installed = {
            'bash', 'cpp', 'css', 'cuda', 'dart', 'dockerfile', 'go', 'gomod', 'html', 'java',
            'javascript', 'jsdoc', 'json', 'jsonc', 'julia', 'kotlin', 'lua', 'php', 'python',
            'query', 'ruby', 'rust', 'scss', 'teal', 'toml', 'tsx', 'typescript', 'vue', 'yaml',
            'zig'
        },

        highlight = {enable = true, disable = {'bash'}},
        textobjects = {
            select = {
                enable = true,
                keymaps = {
                    ['ia'] = '@parameter.inner'
                    -- ['af'] = '@function.outer',
                    -- ['if'] = '@function.inner',
                    -- ['ac'] = '@class.outer',
                    -- ['ic'] = '@class.inner'
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
    queries = require 'nvim-treesitter.query'
end

init()

return M
