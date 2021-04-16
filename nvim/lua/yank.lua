local M = {}
local api = vim.api
local fn = vim.fn

local last_wv
local winid

-- TODO, under test
local function setup()
    api.nvim_exec([[
        aug TextYank
            au!
            au TextYankPost * lua require('yank').restore()
        aug END
    ]], false)
end

function M.wrap()
    if api.nvim_get_mode().mode == 'n' then
        M.set_wv()
    else
        last_wv = nil
        winid = nil
    end
    return 'y'
end

function M.set_wv()
    last_wv = fn.winsaveview()
    winid = api.nvim_get_current_win()
end

function M.restore()
    if vim.v.event.operator == 'y' and last_wv and api.nvim_get_current_win() == winid then
        fn.winrestview(last_wv)
    end
    last_wv = nil
    winid = nil
end

setup()

return M
