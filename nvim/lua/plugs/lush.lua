local M = {}
local fn = vim.fn
local api = vim.api
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

local function setup()
    cmd('pa lush.nvim')
    lush = require('lush')
    colors_path = ('%s/colors'):format(fn.stdpath('config'))
    fn.mkdir(colors_path, 'p')
end

function M.dump(name)
    local theme_path = ('%s/%s.vim'):format(colors_path, name)

    dev.reload_module('lush_theme')
    local ok, msg = pcall(require, 'lush_theme.' .. name)
    if ok then
        local module = msg
        ok, msg = pcall(lush.compile, module)
        if ok then
            local lines = msg
            local fp = assert(io.open(theme_path, 'w+'))
            fp:write(header)
            fp:write(([[let g:colors_name = '%s'%s]]):format(name, '\n'))
            for _, line in ipairs(lines) do
                fp:write(line, '\n')
            end
            fp:close()
            cmd('so ' .. theme_path)
        else
            api.nvim_err_writeln(msg)
        end
    else
        api.nvim_err_writeln(msg:sub(1, msg:find('\n') - 1))
    end
end

function M.write_post()
    local fname = fn.expand('<afile>')
    if fname ~= '' then
        local base = fn.fnamemodify(fname, ':t:r')
        M.dump(base)
    end
end

setup()

return M
