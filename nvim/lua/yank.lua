local M = {}
local api = vim.api
local fn = vim.fn

local last_wv

local function init()
    api.nvim_exec([[
        aug TextYank
            au!
            au TextYankPost * lua require('yank').restore()
        aug END
    ]], false)
end

function M.wrap()
    local m = api.nvim_get_mode().mode
    if m == 'n' then
        last_wv = fn.winsaveview()
    else
        last_wv = nil
    end
    return 'y'
end

function M.set_wv()
    last_wv = fn.winsaveview()
end

function M.restore()
    if vim.v.event.operator == 'y' and last_wv then
        fn.winrestview(last_wv)
    end
    last_wv = nil
end

init()

return M
