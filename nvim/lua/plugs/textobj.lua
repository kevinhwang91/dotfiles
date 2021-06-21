local M = {}
local fn = vim.fn

local utils = require('kutils')

function M.action(obj, inner, visual)
    if vim.g.coc_service_initialized == 1 and not inner then
        local coc = require('plugs.coc')
        local symbols = {func = {'Method', 'Function'}, class = {'Interface', 'Struct', 'Class'}}
        local err = coc.a2sync('hasProvider', {'documentSymbol'})
        if not err then
            err = require('plugs.coc').a2sync('selectSymbolRange', {
                inner, visual and fn.visualmode() or '', symbols[obj]
            })
            if not err then
                return
            end
        end
        if obj == 'func' then
            obj = 'function'
        end
        if require('plugs.treesitter').do_textobject(obj, inner, visual) then
            utils.cool_echo([[textobjects: treesitter]], 'WarningMsg')
        end
    else
        if obj == 'func' then
            obj = 'function'
        end
        require('plugs.treesitter').do_textobject(obj, inner, visual)
    end
end

return M
