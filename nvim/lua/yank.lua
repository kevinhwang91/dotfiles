local M = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local last_wv
local winid
local bufnr

-- TODO, under test
local function setup()
    cmd([[
        aug TextYank
            au!
            au TextYankPost * lua require('yank').restore()
        aug END
    ]])
end

function M.wrap()
    if api.nvim_get_mode().mode == 'n' then
        M.set_wv()
    else
        M.clear_wv()
    end
    return 'y'
end

function M.set_wv()
    last_wv = fn.winsaveview()
    winid = api.nvim_get_current_win()
    bufnr = api.nvim_get_current_buf()
end

function M.clear_wv()
    last_wv = nil
    winid = nil
    bufnr = nil
end

function M.restore()
    if vim.v.event.operator == 'y' and last_wv and api.nvim_get_current_win() == winid and
        api.nvim_get_current_buf() == bufnr then
        fn.winrestview(last_wv)
    end
    M.clear_wv()
end

setup()

return M
