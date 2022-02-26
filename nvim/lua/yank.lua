local M = {}
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local last_wv
local winid
local bufnr
local report

function M.wrap(suffix)
    if api.nvim_get_mode().mode == 'n' then
        M.set_wv()
    else
        M.clear_wv()
    end
    return type(suffix) == 'string' and ('y' .. suffix) or 'y'
end

function M.set_wv()
    last_wv = fn.winsaveview()
    winid = api.nvim_get_current_win()
    bufnr = api.nvim_get_current_buf()
    report = vim.o.report
    -- skip `update_topline_redraw` in `op_yank_reg` caller
    vim.o.report = 65535
end

function M.clear_wv()
    last_wv = nil
    winid = nil
    bufnr = nil
    if report then
        vim.o.report = report
        report = nil
    end
end

function M.restore()
    if vim.v.event.operator == 'y' and last_wv and api.nvim_get_current_win() == winid and
        api.nvim_get_current_buf() == bufnr then
        fn.winrestview(last_wv)
    end
    M.clear_wv()
end

function M.yank_reg(regname, context, level, opts)
    fn.setreg(regname, context)
    vim.notify(context, level, opts)
end

local function init()
    cmd([[
        aug TextYank
            au!
            au TextYankPost * lua require('yank').restore()
        aug END
    ]])
end

init()

return M
