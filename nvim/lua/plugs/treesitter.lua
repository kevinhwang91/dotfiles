local M = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local map = require('remap').map

local ft_enabled
local queries
local parsers
local configs

function M.has_textobj(ft)
    return queries.get_query(parsers.ft_to_lang(ft), 'textobjects') ~= nil and true or false
end

function M.do_textobj(obj, inner, visual)
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
    local bufnr = tonumber(fn.expand('<abuf>'))
    local lcount = api.nvim_buf_line_count(bufnr)
    local bytes = api.nvim_buf_get_offset(bufnr, lcount)

    -- bytes / lcount < 500 LGTM :)
    if bytes / lcount < 500 then
        if ft_enabled[ft] then
            configs.reattach_module('highlight', bufnr)
            vim.defer_fn(function()
                configs.reattach_module('textobjects.move', bufnr)
            end, 300)
        else
            vim.bo.syntax = ft
        end
    end
end

local function init()
    local conf = {
        ensure_installed = {
            'bash', 'c', 'cpp', 'cmake', 'css', 'dart', 'dockerfile', 'go', 'gomod', 'html', 'java',
            'javascript', 'json', 'jsonc', 'kotlin', 'lua', 'make', 'markdown', 'python', 'query',
            'ruby', 'rust', 'scss', 'teal', 'toml', 'tsx', 'typescript', 'vim', 'vue', 'yaml'
        },

        highlight = {enable = true, disable = {'html', 'comment'}},
        textobjects = {
            select = {enable = true, disable = {'comment'}},
            move = {
                enable = true,
                disable = {'comment'},
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

    configs = require('nvim-treesitter.configs')
    parsers = require('nvim-treesitter.parsers')
    configs.setup(conf)
    cmd('au! NvimTreesitter FileType *')

    cmd('pa iswap.nvim')
    require('iswap').setup {
        grey = 'disable',
        hl_snipe = 'IncSearch',
        hl_selection = 'MatchParen',
        autoswap = true
    }
    map('n', '<Leader>sp', '<Cmd>ISwap<CR>')

    queries = require('nvim-treesitter.query')
    local hl_disabled = conf.highlight.disable
    ft_enabled = {}
    for _, lang in ipairs(conf.ensure_installed) do
        if not vim.tbl_contains(hl_disabled, lang) then
            local parser = parsers.list[lang]
            local used_by, filetype = parser.used_by, parser.filetype
            if used_by then
                for _, ft in ipairs(used_by) do
                    ft_enabled[ft] = true
                end
            end
            ft_enabled[filetype or lang] = true
        end
    end
end

init()

return M
