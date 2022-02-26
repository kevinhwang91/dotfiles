local M = {}
local fn = vim.fn

local utils = require('kutils')
local coc = require('plugs.coc')

function M.select(obj, inner, visual)
    if coc.did_init() then
        local symbols = {func = {'Method', 'Function'}, class = {'Interface', 'Struct', 'Class'}}
        if not inner then
            local err, res = coc.a2sync('hasProvider', {'documentSymbol'})
            if not err and res == true then
                err = require('plugs.coc').a2sync('selectSymbolRange', {
                    inner, visual and fn.visualmode() or '', symbols[obj]
                })
                if not err then
                    return
                end
            end
        end
    end
    if obj == 'func' then
        obj = 'function'
    end
    require('plugs.treesitter').do_textobj(obj, inner, visual)
    utils.cool_echo('textobjects: treesitter', 'WarningMsg')
end

return M
