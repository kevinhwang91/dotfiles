local M = {}
local fn = vim.fn
local cmd = vim.cmd

local lush
local dev = require('dev')

-- I only use one dark theme, `hi clear` will increase my burden.
local header = [[
if v:vim_did_enter
    " hi clear
    syntax reset
endif
]]

local colors_path

function M.dump(name)
    local theme_path = ('%s/%s.vim'):format(colors_path, name)

    dev.reload_module('lush_theme')
    local ok, res = pcall(require, 'lush_theme.' .. name)
    if ok then
        local module = res
        ok, res = pcall(lush.compile, module)
        if ok then
            local lines = res
            local fp = assert(io.open(theme_path, 'w+'))
            fp:write(header)
            fp:write(([[let g:colors_name = '%s'%s]]):format(name, '\n'))
            for _, line in ipairs(lines) do
                fp:write(line, '\n')
            end
            fp:close()
            cmd('so ' .. theme_path)
        else
            vim.notify(res, vim.log.levels.ERROR)
        end
    else
        res = type(res) == 'table' and res.res or res:match('[^\n]+')
        vim.notify(res, vim.log.levels.ERROR)
    end
end

function M.write_post()
    local fname = fn.expand('<afile>')
    if fname ~= '' then
        local base = fn.fnamemodify(fname, ':t:r')
        M.dump(base)
    end
end

local function init()
    cmd('pa lush.nvim')
    lush = require('lush')
    colors_path = ('%s/colors'):format(fn.stdpath('config'))
    fn.mkdir(colors_path, 'p')
end

init()

return M
